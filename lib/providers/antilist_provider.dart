import 'package:flutter/foundation.dart';

import '../core/constants/iap_constants.dart';
import '../core/services/storage_service.dart';
import '../models/antilist.dart';
import 'shop_provider.dart';

class AntiListProvider extends ChangeNotifier {
  static const _onboardKey = 'al_onboarding_done';
  static const _holdsKey = 'al_holds';
  static const _logsKey = 'al_logs';
  static const _noteKey = 'al_relapse_note';
  static const _weekStartKey = 'al_week_start';

  ShopProvider? _shop;
  bool _onboardingComplete = false;
  bool _ready = false;
  List<DayHold> _holds = [];
  List<TriggerEntry> _logs = [];
  String _relapseNote = '';
  DateTime _weekStart = _mondayOf(DateTime.now());

  bool get onboardingComplete => _onboardingComplete;
  bool get ready => _ready;
  List<TriggerEntry> get logs => _logs;
  String get relapseNote => _relapseNote;
  DateTime get weekStart => _weekStart;

  List<AvoidHabit> get habits {
    final extra = _shop?.hasHabitPack == true;
    return AvoidHabit.all.where((h) => extra || !h.premium).toList();
  }

  List<String> replacementsFor(AvoidHabit habit) {
    final extra = _shop?.hasReplacementPack == true;
    if (extra) return habit.replacements;
    return habit.replacements.take(2).toList();
  }

  String get todayKey => _dateKey(DateTime.now());

  DayHold get todayHold {
    for (final h in _holds) {
      if (h.date == todayKey) return h;
    }
    return DayHold(date: todayKey, heldIds: {});
  }

  bool isHeldToday(String habitId) => todayHold.heldIds.contains(habitId);

  int get streakDays {
    var n = 0;
    var cursor = DateTime.now();
    while (n < 365) {
      final hold = _holdOn(_dateKey(cursor));
      if (hold == null || hold.heldIds.isEmpty) break;
      n++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return n;
  }

  List<bool> get weekMarks {
    final now = DateTime.now();
    final monday = _mondayOf(now);
    return List.generate(7, (i) {
      final day = monday.add(Duration(days: i));
      if (day.isAfter(now)) return false;
      final key = _dateKey(day);
      return _holdOn(key)?.heldIds.isNotEmpty == true;
    });
  }

  int get timeReclaimedMinutes {
    var mins = 0;
    for (final hold in _holds) {
      for (final id in hold.heldIds) {
        mins += AvoidHabit.byId(id).minutesCost;
      }
    }
    for (final log in _logs) {
      mins += log.replacementMinutes;
    }
    return mins;
  }

  double get moneySaved {
    var sum = 0.0;
    for (final hold in _holds) {
      for (final id in hold.heldIds) {
        sum += AvoidHabit.byId(id).moneyCost;
      }
    }
    return sum;
  }

  int get urgesResisted => _logs.where((e) => e.rescued || e.outcome.isNotEmpty).length +
      _holds.fold<int>(0, (a, h) => a + h.heldIds.length);

  int get replacementMinutes => _logs.fold<int>(0, (a, e) => a + e.replacementMinutes);

  Map<String, List<int>> heatmap() {
    final map = <String, List<int>>{};
    for (final h in habits) {
      map[h.id] = List.filled(7, 0);
    }
    for (final log in _logs) {
      if (!map.containsKey(log.habitId)) continue;
      map[log.habitId]![log.at.weekday - 1]++;
    }
    return map;
  }

  Map<String, int> topReplacements() {
    final map = <String, int>{};
    for (final log in _logs) {
      if (log.replacement.isEmpty) continue;
      map[log.replacement] = (map[log.replacement] ?? 0) + log.replacementMinutes;
    }
    return map;
  }

  void bindShop(ShopProvider shop) => _shop = shop;

  Future<void> init() async {
    _onboardingComplete = await StorageService.instance.getBool(_onboardKey) ?? false;
    _relapseNote = await StorageService.instance.getString(_noteKey) ?? '';
    final week = await StorageService.instance.getString(_weekStartKey);
    _weekStart = DateTime.tryParse(week ?? '') ?? _mondayOf(DateTime.now());

    final holdRows = await StorageService.instance.getDataList(_holdsKey);
    _holds = holdRows?.map(DayHold.fromJson).toList() ?? [];

    final logRows = await StorageService.instance.getDataList(_logsKey);
    _logs = logRows?.map(TriggerEntry.fromJson).toList() ?? [];
    _logs.sort((a, b) => b.at.compareTo(a.at));

    await _purgeScreenshotSeed();

    _ready = true;
    notifyListeners();
  }

  Future<void> _purgeScreenshotSeed() async {
    const key = 'al_cleared_screenshot_seed';
    if (await StorageService.instance.getBool(key) ?? false) return;
    _holds = [];
    _logs = [];
    _relapseNote = '';
    await StorageService.instance.saveDataList(_holdsKey, []);
    await StorageService.instance.saveDataList(_logsKey, []);
    await StorageService.instance.saveString(_noteKey, '');
    await StorageService.instance.saveBool(key, true);
  }

  Future<void> completeOnboarding() async {
    _onboardingComplete = true;
    await StorageService.instance.saveBool(_onboardKey, true);
    notifyListeners();
  }

  Future<void> toggleHeld(String habitId) async {
    final today = todayHold;
    final next = {...today.heldIds};
    if (!next.add(habitId)) next.remove(habitId);
    _holds.removeWhere((h) => h.date == todayKey);
    _holds.add(DayHold(date: todayKey, heldIds: next));
    await _saveHolds();
    notifyListeners();
    if (next.contains(habitId)) {
      await _shop?.rewardForJobSave();
    }
  }

  Future<void> addLog(TriggerEntry entry) async {
    _logs.insert(0, entry);
    await StorageService.instance.saveDataList(_logsKey, _logs.map((e) => e.toJson()).toList());
    if (entry.rescued) {
      final today = todayHold;
      final next = {...today.heldIds, entry.habitId};
      _holds.removeWhere((h) => h.date == todayKey);
      _holds.add(DayHold(date: todayKey, heldIds: next));
      await _saveHolds();
      await _shop?.rewardForLevelComplete(IapConstants.rescueReward);
    }
    notifyListeners();
  }

  Future<void> setRelapseNote(String note) async {
    _relapseNote = note;
    await StorageService.instance.saveString(_noteKey, note);
    notifyListeners();
  }

  Future<void> resetWeek() async {
    _weekStart = _mondayOf(DateTime.now());
    await StorageService.instance.saveString(_weekStartKey, _weekStart.toIso8601String());
    notifyListeners();
  }

  Future<void> _saveHolds() async {
    await StorageService.instance.saveDataList(_holdsKey, _holds.map((e) => e.toJson()).toList());
  }

  DayHold? _holdOn(String key) {
    for (final h in _holds) {
      if (h.date == key) return h;
    }
    return null;
  }

  static String _dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static DateTime _mondayOf(DateTime d) {
    final day = DateTime(d.year, d.month, d.day);
    return day.subtract(Duration(days: day.weekday - 1));
  }
}
