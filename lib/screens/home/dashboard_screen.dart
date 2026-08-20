import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/navigation/app_navigator.dart';
import '../../models/garden.dart';
import '../../providers/garden_provider.dart';
import '../../widgets/coin_balance_chip.dart';
import '../../widgets/crop_picker.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const _climates = [
    ('Temperate Maritime', 'climateMaritimeBlurb'),
    ('Continental', 'climateContinentalBlurb'),
    ('Mediterranean', 'climateMedBlurb'),
    ('Subtropical', 'climateSubtropicalBlurb'),
  ];

  @override
  Widget build(BuildContext context) {
    final garden = context.watch<GardenProvider>();
    final green = AppColors.brand(context);
    final season = _season(context);
    final tasks = garden.openTasks;
    final preview = tasks.take(3).toList();
    return ColoredBox(
      color: AppColors.page(context),
      child: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 96),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: FittedBox(
                        alignment: Alignment.centerLeft,
                        fit: BoxFit.scaleDown,
                        child: Text(
                          AppStrings.t(context, 'dashboard'),
                          maxLines: 1,
                          style: GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.w700, color: green, height: 1),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    CoinBalanceChip(variant: CoinChipVariant.header, onTap: AppTabs.goShop),
                    const SizedBox(width: 6),
                    _RoundIcon(icon: Icons.eco_rounded, onTap: AppTabs.goGarden),
                    const SizedBox(width: 6),
                    _RoundIcon(icon: Icons.settings_outlined, onTap: AppTabs.goMore),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _SeasonCard(name: season.$1, range: season.$2)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ClimateCard(
                        name: garden.climate,
                        blurb: AppStrings.t(context, _blurbKey(garden.climate)),
                        onChange: () => _pickClimate(context, garden),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: Text(AppStrings.t(context, 'plantingTasks'), style: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.w700, color: green)),
                    ),
                    GestureDetector(
                      onTap: () => _showAllTasks(context, garden),
                      child: Text(AppStrings.t(context, 'viewAll'), style: GoogleFonts.nunito(fontWeight: FontWeight.w800, color: AppColors.accent)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _WhiteCard(
                  child: preview.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(AppStrings.t(context, 'noTasks'), style: GoogleFonts.nunito(color: AppColors.muted(context))),
                        )
                      : Column(
                          children: [
                            for (var i = 0; i < preview.length; i++) ...[
                              if (i > 0) Divider(height: 1, color: AppColors.line(context)),
                              _TaskRow(task: preview[i], onToggle: () => garden.toggleTask(preview[i].id)),
                            ],
                          ],
                        ),
                ),
                const SizedBox(height: 22),
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
                        color: green,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                AppStrings.t(context, 'upcomingSchedule'),
                                style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                              ),
                            ),
                            const Icon(Icons.calendar_month_outlined, color: Colors.white, size: 20),
                          ],
                        ),
                      ),
                      ColoredBox(
                        color: AppColors.card(context),
                        child: tasks.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(AppStrings.t(context, 'noTasks'), style: GoogleFonts.nunito(color: AppColors.muted(context))),
                              )
                            : Column(
                                children: [
                                  for (var i = 0; i < tasks.length; i++) ...[
                                    if (i > 0) Divider(height: 1, indent: 16, endIndent: 16, color: AppColors.line(context)),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 68,
                                            child: Text(DateFormat('MMM d').format(tasks[i].due), style: GoogleFonts.nunito(fontWeight: FontWeight.w800, color: green)),
                                          ),
                                          Expanded(
                                            child: Text(tasks[i].title, style: GoogleFonts.nunito(fontWeight: FontWeight.w700, color: AppColors.ink(context))),
                                          ),
                                          Text(tasks[i].place, style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.muted(context))),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              right: 18,
              bottom: 14,
              child: Material(
                color: AppColors.accent,
                shape: const CircleBorder(),
                elevation: 4,
                shadowColor: AppColors.accent.withValues(alpha: 0.45),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => _addTask(context, garden),
                  child: const SizedBox(width: 44, height: 44, child: Icon(Icons.add, color: Colors.white, size: 22)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _blurbKey(String climate) {
    for (final c in _climates) {
      if (c.$1 == climate) return c.$2;
    }
    return 'climateMaritimeBlurb';
  }

  static (String, String) _season(BuildContext context) {
    final m = DateTime.now().month;
    if (m >= 3 && m <= 5) return (AppStrings.t(context, 'seasonSpring'), AppStrings.t(context, 'rangeSpring'));
    if (m >= 6 && m <= 8) return (AppStrings.t(context, 'seasonSummer'), AppStrings.t(context, 'rangeSummer'));
    if (m >= 9 && m <= 11) return (AppStrings.t(context, 'seasonAutumn'), AppStrings.t(context, 'rangeAutumn'));
    return (AppStrings.t(context, 'seasonWinter'), AppStrings.t(context, 'rangeWinter'));
  }

  Future<void> _showAllTasks(BuildContext context, GardenProvider garden) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.sheet(context),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        final list = garden.openTasks;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(AppStrings.t(ctx, 'plantingTasks'), style: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.brand(context))),
                const SizedBox(height: 8),
                if (list.isEmpty) Text(AppStrings.t(ctx, 'noTasks')),
                for (final t in list) _TaskRow(task: t, onToggle: () => garden.toggleTask(t.id)),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickClimate(BuildContext context, GardenProvider garden) async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.sheet(context),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(AppStrings.t(ctx, 'climateProfile'), style: GoogleFonts.playfairDisplay(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.brand(context))),
              const SizedBox(height: 8),
              for (final o in _climates)
                ListTile(
                  title: Text(o.$1, style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
                  subtitle: Text(AppStrings.t(ctx, o.$2)),
                  onTap: () => Navigator.pop(ctx, o.$1),
                ),
            ],
          ),
        ),
      ),
    );
    if (picked != null) garden.setClimate(picked);
  }

  Future<void> _addTask(BuildContext context, GardenProvider garden) async {
    CropKind crop = CropKind.lettuce;
    final title = TextEditingController(text: 'Sow Lettuce');
    final place = TextEditingController(text: garden.activeBed.name);
    var indoor = true;
    var due = DateTime.now().add(const Duration(days: 1));
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.sheet(context),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + MediaQuery.of(ctx).viewInsets.bottom),
        child: StatefulBuilder(
          builder: (ctx, setSt) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(AppStrings.t(ctx, 'addTask'), style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w700, fontSize: 22, color: AppColors.brand(context))),
              TextField(controller: title, decoration: InputDecoration(labelText: AppStrings.t(ctx, 'itemName'))),
              TextField(controller: place, decoration: InputDecoration(labelText: AppStrings.t(ctx, 'place'))),
              const SizedBox(height: 8),
              CropPickTile(
                crop: crop,
                onTap: () async {
                  final picked = await CropPicker.show(ctx, selected: crop);
                  if (picked != null) {
                    setSt(() {
                      crop = picked;
                      indoor = picked.startIndoor;
                      title.text = '${picked.startIndoor ? 'Sow' : 'Direct sow'} ${picked.name}';
                    });
                  }
                },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(AppStrings.t(ctx, 'indoor')),
                value: indoor,
                onChanged: (v) => setSt(() => indoor = v),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_month_outlined),
                title: Text(DateFormat.yMMMd().format(due)),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: due,
                    firstDate: DateTime.now().subtract(const Duration(days: 1)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) setSt(() => due = picked);
                },
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(AppStrings.t(ctx, 'save')),
              ),
            ],
          ),
        ),
      ),
    );
    if (ok == true && title.text.trim().isNotEmpty) {
      await garden.addTask(PlantingTask(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title.text.trim(),
        cropId: crop.id,
        place: place.text.trim(),
        due: due,
        indoor: indoor,
      ));
    }
    title.dispose();
    place.dispose();
  }
}

class _RoundIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 1,
      shadowColor: const Color(0x33000000),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(width: 34, height: 34, child: Icon(icon, color: AppColors.brand(context), size: 18)),
      ),
    );
  }
}

class _WhiteCard extends StatelessWidget {
  final Widget child;
  const _WhiteCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: const Color(0xFF3A2410).withValues(alpha: 0.07), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: child,
    );
  }
}

class _SeasonCard extends StatelessWidget {
  final String name;
  final String range;
  const _SeasonCard({required this.name, required this.range});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 168,
      padding: const EdgeInsets.fromLTRB(14, 14, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: const Color(0xFF3A2410).withValues(alpha: 0.07), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppStrings.t(context, 'currentSeason'), style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.muted(context))),
              const SizedBox(height: 8),
              Text(name, style: GoogleFonts.playfairDisplay(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.brand(context), height: 1)),
              const SizedBox(height: 4),
              Text(range, style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.muted(context))),
            ],
          ),
          const Positioned(right: 0, bottom: 0, child: Text('🌿', style: TextStyle(fontSize: 42))),
        ],
      ),
    );
  }
}

class _ClimateCard extends StatelessWidget {
  final String name;
  final String blurb;
  final VoidCallback onChange;
  const _ClimateCard({required this.name, required this.blurb, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 168,
      padding: const EdgeInsets.fromLTRB(14, 14, 12, 10),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: const Color(0xFF3A2410).withValues(alpha: 0.07), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.t(context, 'climateProfile'), style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.muted(context))),
          const SizedBox(height: 8),
          const Text('⛅', style: TextStyle(fontSize: 26)),
          const SizedBox(height: 4),
          Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.ink(context))),
          Text(blurb, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.nunito(fontSize: 11, color: AppColors.muted(context))),
          const Spacer(),
          GestureDetector(
            onTap: onChange,
            child: Row(
              children: [
                Icon(Icons.edit_outlined, size: 14, color: AppColors.brand(context)),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(AppStrings.t(context, 'changeProfile'), style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.brand(context))),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  final PlantingTask task;
  final VoidCallback onToggle;
  const _TaskRow({required this.task, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final days = DateTime(task.due.year, task.due.month, task.due.day).difference(today).inDays;
    final sub = task.indoor
        ? AppStrings.t(context, 'indoor')
        : (days <= 0 ? AppStrings.t(context, 'today') : AppStrings.t(context, 'inDays', {'n': '$days'}));
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: task.crop.color.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(14)),
            child: Text(task.crop.emoji, style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.title, style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.ink(context))),
                Text(sub, style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.muted(context))),
              ],
            ),
          ),
          Icon(Icons.calendar_month_outlined, size: 16, color: AppColors.muted(context)),
          const SizedBox(width: 4),
          Text(DateFormat('MMM d').format(task.due), style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.muted(context))),
          const SizedBox(width: 10),
          InkWell(
            onTap: onToggle,
            customBorder: const CircleBorder(),
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.brand(context), width: 2),
                color: task.done ? AppColors.brand(context) : Colors.transparent,
              ),
              child: task.done ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
            ),
          ),
        ],
      ),
    );
  }
}
