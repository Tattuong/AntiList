import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../models/garden.dart';
import '../core/services/storage_service.dart';
import 'shop_provider.dart';

class GardenProvider extends ChangeNotifier {
  static const _onboardKey = 'gg_onboarding_done';
  static const _bedsKey = 'gg_beds';
  static const _tasksKey = 'gg_tasks';
  static const _seedsKey = 'gg_seeds';
  static const _suppliesKey = 'gg_supplies';
  static const _harvestKey = 'gg_harvests';
  static const _notesKey = 'gg_journal';
  static const _climateKey = 'gg_climate';
  static const _activeBedKey = 'gg_active_bed';

  ShopProvider? _shop;
  bool _onboardingComplete = false;
  String _climate = 'Temperate Maritime';
  String _activeBedId = 'bed1';
  List<GardenBed> _beds = [];
  List<PlantingTask> _tasks = [];
  List<SeedLot> _seeds = [];
  List<SupplyItem> _supplies = [];
  List<HarvestEntry> _harvests = [];
  List<JournalNote> _notes = [];

  bool get onboardingComplete => _onboardingComplete;
  String get climate => _climate;
  List<GardenBed> get beds => List.unmodifiable(_beds);
  List<PlantingTask> get tasks => List.unmodifiable(_tasks);
  List<SeedLot> get seeds => List.unmodifiable(_seeds);
  List<SupplyItem> get supplies => List.unmodifiable(_supplies);
  List<HarvestEntry> get harvests => List.unmodifiable(_harvests);
  List<JournalNote> get notes => List.unmodifiable(_notes);

  int get bedCap => _shop?.hasBedPack == true ? 8 : 2;

  GardenBed get activeBed {
    for (final b in _beds) {
      if (b.id == _activeBedId) return b;
    }
    return _beds.isEmpty
        ? const GardenBed(id: 'empty', name: 'Bed', rows: 3, cols: 3, cells: [])
        : _beds.first;
  }

  List<PlantingTask> get openTasks {
    final list = _tasks.where((t) => !t.done).toList()..sort((a, b) => a.due.compareTo(b.due));
    return list;
  }

  double get totalYieldKg => _harvests.fold(0, (n, h) => n + h.kg);
  double get totalHarvestValue => _harvests.fold(0, (n, h) => n + h.value);

  Map<int, double> yieldByMonth() {
    final map = <int, double>{};
    for (final h in _harvests) {
      map[h.date.month] = (map[h.date.month] ?? 0) + h.kg;
    }
    return map;
  }

  void bindShop(ShopProvider shop) => _shop = shop;

  Future<void> init() async {
    _onboardingComplete = await StorageService.instance.getBool(_onboardKey) ?? false;
    _climate = await StorageService.instance.getString(_climateKey) ?? 'Temperate Maritime';
    _activeBedId = await StorageService.instance.getString(_activeBedKey) ?? 'bed1';
    _beds = await _loadList(_bedsKey, GardenBed.fromJson);
    _tasks = await _loadList(_tasksKey, PlantingTask.fromJson);
    _seeds = await _loadList(_seedsKey, SeedLot.fromJson);
    _supplies = await _loadList(_suppliesKey, SupplyItem.fromJson);
    _harvests = await _loadList(_harvestKey, HarvestEntry.fromJson);
    _notes = await _loadList(_notesKey, JournalNote.fromJson);
    if (_beds.isEmpty) {
      _seedSeason();
      await _persist();
    }
    notifyListeners();
  }

  Future<List<T>> _loadList<T>(String key, T Function(Map<String, dynamic>) parse) async {
    final raw = await StorageService.instance.getString(key);
    if (raw == null || raw.isEmpty) return [];
    try {
      return (jsonDecode(raw) as List<dynamic>)
          .map((e) => parse(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  void _seedSeason() {
    const ids = ['lettuce', 'spinach', 'radish', 'carrot', 'tomato', 'basil', 'onion', 'pea', 'marigold'];
    _beds = [
      GardenBed(
        id: 'bed1',
        name: 'Bed 1A',
        companionHint: 'Marigolds help repel nematodes and keep tomatoes happier.',
        notes: 'South sun. Water in the morning.',
        rows: 3,
        cols: 3,
        cells: [for (final id in ids) BedCell(cropId: id)],
      ),
    ];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    _tasks = [
      PlantingTask(id: 't1', title: 'Sow Lettuce', cropId: 'lettuce', place: 'Indoor', due: today, indoor: true),
      PlantingTask(id: 't2', title: 'Transplant Tomatoes', cropId: 'tomato', place: 'Bed 1A', due: today.add(const Duration(days: 7))),
      PlantingTask(id: 't3', title: 'Direct Sow Carrots', cropId: 'carrot', place: 'Bed 1A', due: today.add(const Duration(days: 10))),
      PlantingTask(id: 't4', title: 'Sow Kale', cropId: 'kale', place: 'Indoor', due: today.add(const Duration(days: 3)), indoor: true),
      PlantingTask(id: 't5', title: 'Direct Sow Beans', cropId: 'bean', place: 'Bed 1A', due: today.add(const Duration(days: 14))),
    ];
    _seeds = [
      SeedLot(id: 's1', cropId: 'lettuce', variety: 'Buttercrunch', grams: 2.5, price: 1.80, lastSown: today.subtract(const Duration(days: 2))),
      SeedLot(id: 's2', cropId: 'tomato', variety: 'Cherokee Purple', grams: 1.2, price: 3.40, lastSown: today.subtract(const Duration(days: 18))),
      SeedLot(id: 's3', cropId: 'carrot', variety: 'Nantes', grams: 4.0, price: 2.10),
      SeedLot(id: 's4', cropId: 'basil', variety: 'Genovese', grams: 1.0, price: 1.50),
      SeedLot(id: 's5', cropId: 'kale', variety: 'Lacinato', grams: 2.0, price: 2.20),
      SeedLot(id: 's6', cropId: 'pepper', variety: 'California Wonder', grams: 0.8, price: 2.90, lastSown: today.subtract(const Duration(days: 20))),
      SeedLot(id: 's7', cropId: 'cucumber', variety: 'Marketmore', grams: 1.5, price: 1.90),
      SeedLot(id: 's8', cropId: 'bean', variety: 'Provider', grams: 8.0, price: 2.40),
      SeedLot(id: 's9', cropId: 'garlic', variety: 'Music', grams: 12.0, price: 4.50),
      SeedLot(id: 's10', cropId: 'marigold', variety: 'French', grams: 0.6, price: 1.20),
    ];
    _supplies = const [
      SupplyItem(id: 'u1', name: 'Potting mix', qty: '2 bags'),
      SupplyItem(id: 'u2', name: 'Row cover', qty: '1 roll'),
    ];
    _harvests = [
      HarvestEntry(id: 'h1', cropId: 'lettuce', variety: 'Buttercrunch', kg: 1.8, value: 6.40, date: today.subtract(const Duration(days: 3))),
      HarvestEntry(id: 'h2', cropId: 'radish', variety: 'Cherry Belle', kg: 0.9, value: 3.20, date: today.subtract(const Duration(days: 8))),
      HarvestEntry(id: 'h3', cropId: 'spinach', variety: 'Bloomsdale', kg: 1.2, value: 5.10, date: today.subtract(const Duration(days: 12))),
    ];
    _notes = [
      JournalNote(id: 'n1', title: 'First lettuce cut', body: 'Buttercrunch filled Bed 1A. Next sowing in 10 days.', at: today.subtract(const Duration(days: 3))),
    ];
  }

  Future<void> _persist() async {
    await StorageService.instance.saveString(_bedsKey, jsonEncode(_beds.map((e) => e.toJson()).toList()));
    await StorageService.instance.saveString(_tasksKey, jsonEncode(_tasks.map((e) => e.toJson()).toList()));
    await StorageService.instance.saveString(_seedsKey, jsonEncode(_seeds.map((e) => e.toJson()).toList()));
    await StorageService.instance.saveString(_suppliesKey, jsonEncode(_supplies.map((e) => e.toJson()).toList()));
    await StorageService.instance.saveString(_harvestKey, jsonEncode(_harvests.map((e) => e.toJson()).toList()));
    await StorageService.instance.saveString(_notesKey, jsonEncode(_notes.map((e) => e.toJson()).toList()));
    await StorageService.instance.saveString(_climateKey, _climate);
    await StorageService.instance.saveString(_activeBedKey, _activeBedId);
  }

  Future<void> completeOnboarding() async {
    _onboardingComplete = true;
    await StorageService.instance.saveBool(_onboardKey, true);
    notifyListeners();
  }

  Future<void> setClimate(String value) async {
    _climate = value;
    await _persist();
    notifyListeners();
  }

  Future<void> setActiveBed(String id) async {
    _activeBedId = id;
    await _persist();
    notifyListeners();
  }

  Future<void> setCell(int index, String cropId) async {
    final bed = activeBed;
    if (index < 0 || index >= bed.cells.length) return;
    final cells = [...bed.cells];
    cells[index] = cells[index].copyWith(cropId: cropId);
    _beds = _beds.map((b) => b.id == bed.id ? b.copyWith(cells: cells) : b).toList();
    await _shop?.rewardForJobSave();
    await _persist();
    notifyListeners();
  }

  Future<void> setBedNotes(String notes) async {
    final bed = activeBed;
    _beds = _beds.map((b) => b.id == bed.id ? b.copyWith(notes: notes) : b).toList();
    await _persist();
    notifyListeners();
  }

  Future<bool> addBed(String name, {BedLayout layout = BedLayout.raised}) async {
    if (_beds.length >= bedCap) return false;
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    _beds = [
      ..._beds,
      GardenBed(
        id: id,
        name: name,
        rows: layout.rows,
        cols: layout.cols,
        cells: BedLayout.emptyCells(layout.rows, layout.cols),
        companionHint: 'Rotate leafy greens after fruiting crops.',
      ),
    ];
    _activeBedId = id;
    await _persist();
    notifyListeners();
    return true;
  }

  Future<void> setBedLayout(BedLayout layout) async {
    final bed = activeBed;
    final cells = BedLayout.fitCells(bed.cells, layout.rows, layout.cols, oldRows: bed.rows, oldCols: bed.cols);
    _beds = _beds
        .map((b) => b.id == bed.id ? b.copyWith(rows: layout.rows, cols: layout.cols, cells: cells) : b)
        .toList();
    await _shop?.rewardForJobSave();
    await _persist();
    notifyListeners();
  }

  Future<void> toggleTask(String id) async {
    _tasks = _tasks.map((t) => t.id == id ? t.copyWith(done: !t.done) : t).toList();
    await _persist();
    notifyListeners();
  }

  Future<void> addTask(PlantingTask task) async {
    _tasks = [task, ..._tasks];
    await _shop?.rewardForJobSave();
    await _persist();
    notifyListeners();
  }

  Future<void> deleteTask(String id) async {
    _tasks = _tasks.where((t) => t.id != id).toList();
    await _persist();
    notifyListeners();
  }

  Future<void> upsertSeed(SeedLot lot) async {
    final exists = _seeds.any((s) => s.id == lot.id);
    _seeds = exists ? _seeds.map((s) => s.id == lot.id ? lot : s).toList() : [lot, ..._seeds];
    await _persist();
    notifyListeners();
  }

  Future<void> deleteSeed(String id) async {
    _seeds = _seeds.where((s) => s.id != id).toList();
    await _persist();
    notifyListeners();
  }

  Future<void> addHarvest(HarvestEntry entry) async {
    _harvests = [entry, ..._harvests]..sort((a, b) => b.date.compareTo(a.date));
    await _shop?.rewardForJobSave();
    await _persist();
    notifyListeners();
  }

  Future<void> deleteHarvest(String id) async {
    _harvests = _harvests.where((h) => h.id != id).toList();
    await _persist();
    notifyListeners();
  }

  Future<void> upsertNote(JournalNote note) async {
    final exists = _notes.any((n) => n.id == note.id);
    _notes = exists ? _notes.map((n) => n.id == note.id ? note : n).toList() : [note, ..._notes];
    await _persist();
    notifyListeners();
  }

  Future<void> deleteNote(String id) async {
    _notes = _notes.where((n) => n.id != id).toList();
    await _persist();
    notifyListeners();
  }
}
