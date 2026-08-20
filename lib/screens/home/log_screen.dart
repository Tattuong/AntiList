import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/antilist.dart';
import '../../providers/antilist_provider.dart';

class LogScreen extends StatelessWidget {
  const LogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final list = context.watch<AntiListProvider>();
    return ColoredBox(
      color: AppColors.page(context),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppStrings.t(context, 'triggerLog'), style: GoogleFonts.blackOpsOne(fontSize: 32, color: AppColors.accentDeep, height: 1)),
                  const SizedBox(height: 4),
                  Text(AppStrings.t(context, 'triggerLogSub'), style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.muted(context))),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _FilterRow(habits: list.habits),
            Expanded(child: _LogList(logs: list.logs)),
            _TotalBar(minutes: list.replacementMinutes),
          ],
        ),
      ),
    );
  }
}

class _FilterRow extends StatefulWidget {
  final List<AvoidHabit> habits;
  const _FilterRow({required this.habits});

  @override
  State<_FilterRow> createState() => _FilterRowState();
}

class _FilterRowState extends State<_FilterRow> {
  String? _id;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _chip(context, null, AppStrings.t(context, 'filterAll')),
          for (final h in widget.habits) _chip(context, h.id, h.name.split(' ').first),
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, String? id, String label) {
    final on = _id == id;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label, style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 12, color: on ? Colors.white : AppColors.ink(context))),
        selected: on,
        selectedColor: AppColors.accentDeep,
        backgroundColor: AppColors.card(context),
        onSelected: (_) {
          setState(() => _id = id);
          LogFilter.active.value = id;
        },
      ),
    );
  }
}

class LogFilter {
  static final active = ValueNotifier<String?>(null);
}

class _LogList extends StatelessWidget {
  final List<TriggerEntry> logs;
  const _LogList({required this.logs});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: LogFilter.active,
      builder: (context, filter, _) {
        final rows = filter == null ? logs : logs.where((e) => e.habitId == filter).toList();
        if (rows.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Text(AppStrings.t(context, 'emptyLog'), style: GoogleFonts.nunito(color: AppColors.muted(context))),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          itemCount: rows.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) => _LogTile(entry: rows[i]),
        );
      },
    );
  }
}

class _LogTile extends StatelessWidget {
  final TriggerEntry entry;
  const _LogTile({required this.entry});

  Color get _urgeColor {
    if (entry.urge >= 8) return AppColors.error;
    if (entry.urge >= 5) return const Color(0xFFF97316);
    return AppColors.accent;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line(context)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.situation, maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.ink(context))),
                Text(DateFormat('h:mm a').format(entry.at), style: GoogleFonts.nunito(fontSize: 11, color: AppColors.muted(context))),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: _urgeColor, shape: BoxShape.circle),
            child: Text('${entry.urge}', style: GoogleFonts.blackOpsOne(color: Colors.white, fontSize: 16)),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.replacement, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.accentDeep)),
                Text(AppStrings.t(context, 'minutesShort', {'n': '${entry.replacementMinutes}'}), style: GoogleFonts.nunito(fontSize: 11, color: AppColors.muted(context))),
              ],
            ),
          ),
          Icon(Icons.check_circle, color: AppColors.accent, size: 20),
        ],
      ),
    );
  }
}

class _TotalBar extends StatelessWidget {
  final int minutes;
  const _TotalBar({required this.minutes});

  @override
  Widget build(BuildContext context) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return Container(
      color: AppColors.accentDeep,
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            const Icon(Icons.timer_outlined, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(AppStrings.t(context, 'totalReplacement'), style: GoogleFonts.nunito(fontWeight: FontWeight.w800, color: Colors.white70, fontSize: 11, letterSpacing: 0.6)),
            ),
            Text('${h}h ${m.toString().padLeft(2, '0')}m', style: GoogleFonts.blackOpsOne(fontSize: 22, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

class LogComposer {
  static Future<void> show(BuildContext context, {required AvoidHabit habit}) async {
    final list = context.read<AntiListProvider>();
    var situation = habit.situations.first;
    var replacement = list.replacementsFor(habit).first;
    var urge = 7;
    var minutes = 10;
    const outcomes = ['outcomePassed', 'outcomeBetter', 'outcomeSlipped'];
    var outcome = 'outcomePassed';

    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.sheet(context),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + MediaQuery.of(ctx).viewInsets.bottom),
        child: StatefulBuilder(
          builder: (ctx, setSt) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(AppStrings.t(ctx, 'addLog'), style: GoogleFonts.blackOpsOne(fontSize: 22, color: AppColors.accentDeep)),
                const SizedBox(height: 4),
                Text(habit.name, style: GoogleFonts.nunito(fontWeight: FontWeight.w800, color: AppColors.muted(ctx))),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: situation,
                  decoration: InputDecoration(labelText: AppStrings.t(ctx, 'situation')),
                  items: [for (final s in habit.situations) DropdownMenuItem(value: s, child: Text(s))],
                  onChanged: (v) => setSt(() => situation = v ?? situation),
                ),
                const SizedBox(height: 8),
                Text(AppStrings.t(ctx, 'urgeLevel')),
                Slider(value: urge.toDouble(), min: 1, max: 10, divisions: 9, label: '$urge', onChanged: (v) => setSt(() => urge = v.round())),
                DropdownButtonFormField<String>(
                  value: replacement,
                  decoration: InputDecoration(labelText: AppStrings.t(ctx, 'replacement')),
                  items: [for (final s in list.replacementsFor(habit)) DropdownMenuItem(value: s, child: Text(s))],
                  onChanged: (v) => setSt(() => replacement = v ?? replacement),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: outcome,
                  decoration: InputDecoration(labelText: AppStrings.t(ctx, 'whatHappened')),
                  items: [for (final k in outcomes) DropdownMenuItem(value: k, child: Text(AppStrings.t(ctx, k)))],
                  onChanged: (v) => setSt(() => outcome = v ?? outcome),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(AppStrings.t(ctx, 'save')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (ok == true) {
      await list.addLog(TriggerEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        habitId: habit.id,
        at: DateTime.now(),
        situation: situation,
        urge: urge,
        replacement: replacement,
        replacementMinutes: minutes,
        outcome: AppStrings.t(context, outcome),
      ));
    }
  }
}
