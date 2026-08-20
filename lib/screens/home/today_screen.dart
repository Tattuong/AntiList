import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/navigation/app_navigator.dart';
import '../../models/antilist.dart';
import '../../providers/antilist_provider.dart';
import '../../widgets/coin_balance_chip.dart';
import 'log_screen.dart';
import 'rescue_screen.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final list = context.watch<AntiListProvider>();
    return ColoredBox(
      color: AppColors.page(context),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppStrings.t(context, 'notToDo'), style: GoogleFonts.blackOpsOne(fontSize: 34, color: AppColors.headline(context), height: 1, letterSpacing: -0.5)),
                      const SizedBox(height: 4),
                      Text(AppStrings.t(context, 'notToDoSub'), style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.muted(context))),
                    ],
                  ),
                ),
                CoinBalanceChip(variant: CoinChipVariant.header, onTap: AppTabs.goShop),
              ],
            ),
            const SizedBox(height: 18),
            for (final habit in list.habits)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _AvoidCard(
                  habit: habit,
                  held: list.isHeldToday(habit.id),
                  onHeld: () => list.toggleHeld(habit.id),
                  onRescue: () => RescueScreen.open(context, habit),
                  onLog: () => LogComposer.show(context, habit: habit),
                ),
              ),
            const SizedBox(height: 8),
            _StreakCard(days: list.streakDays, marks: list.weekMarks),
            const SizedBox(height: 14),
            _RescueBanner(onTap: () => RescueScreen.open(context, list.habits.first)),
          ],
        ),
      ),
    );
  }
}

class _AvoidCard extends StatelessWidget {
  final AvoidHabit habit;
  final bool held;
  final VoidCallback onHeld;
  final VoidCallback onRescue;
  final VoidCallback onLog;

  const _AvoidCard({
    required this.habit,
    required this.held,
    required this.onHeld,
    required this.onRescue,
    required this.onLog,
  });

  @override
  Widget build(BuildContext context) {
    final light = Theme.of(context).brightness == Brightness.light;
    return Material(
      color: AppColors.avoidCard(context),
      elevation: light ? 1 : 0,
      shadowColor: const Color(0x33000000),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: light ? AppColors.line(context) : Colors.transparent),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onLog,
        onLongPress: onHeld,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: light ? const Color(0xFFF4EFE6) : const Color(0xFFE8DFD2), borderRadius: BorderRadius.circular(14)),
                child: Icon(habit.icon, color: AppColors.parchmentInk, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(habit.name, style: GoogleFonts.blackOpsOne(fontSize: 16, color: AppColors.parchmentInk, height: 1.1)),
                    const SizedBox(height: 2),
                    Text(habit.blurb, style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF6B6560))),
                    if (held)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(AppStrings.t(context, 'heldToday').toUpperCase(), style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.successDeep)),
                      ),
                  ],
                ),
              ),
              IconButton(
                tooltip: AppStrings.t(context, 'rescueTitle'),
                onPressed: onRescue,
                icon: const Icon(Icons.close_rounded, color: AppColors.error, size: 36),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  final int days;
  final List<bool> marks;
  const _StreakCard({required this.days, required this.marks});

  static const _labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_fire_department, color: AppColors.error, size: 22),
              const SizedBox(width: 8),
              Text(AppStrings.t(context, 'avoidStreak'), style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.muted(context), letterSpacing: 0.8)),
              const Spacer(),
              Text(AppStrings.t(context, 'days', {'n': '$days'}), style: GoogleFonts.blackOpsOne(fontSize: 20, color: AppColors.navMark(context))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < 7; i++)
                Column(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: marks.length > i && marks[i] ? AppColors.accent : AppColors.wash(context),
                      ),
                      child: marks.length > i && marks[i]
                          ? const Icon(Icons.check, size: 16, color: AppColors.successDeep)
                          : Text(_labels[i], style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.muted(context))),
                    ),
                    const SizedBox(height: 4),
                    Text(_labels[i], style: GoogleFonts.nunito(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.muted(context))),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RescueBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _RescueBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.error,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Row(
            children: [
              const Icon(Icons.bolt_rounded, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppStrings.t(context, 'rescueTitle'), style: GoogleFonts.blackOpsOne(fontSize: 16, color: Colors.white)),
                    Text(AppStrings.t(context, 'rescueSub'), style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white70)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
