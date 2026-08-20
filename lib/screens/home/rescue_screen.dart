import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/antilist.dart';
import '../../providers/antilist_provider.dart';

class RescueScreen extends StatefulWidget {
  final AvoidHabit habit;
  const RescueScreen({super.key, required this.habit});

  static Future<void> open(BuildContext context, AvoidHabit habit) {
    return Navigator.of(context).push(MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) => RescueScreen(habit: habit),
    ));
  }

  @override
  State<RescueScreen> createState() => _RescueScreenState();
}

class _RescueScreenState extends State<RescueScreen> with SingleTickerProviderStateMixin {
  static const _seconds = 90;
  late final AnimationController _ctrl;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: _seconds))
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed && mounted) _finish();
      });
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    if (_done) return;
    _done = true;
    final list = context.read<AntiListProvider>();
    await list.addLog(TriggerEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      habitId: widget.habit.id,
      at: DateTime.now(),
      situation: 'Rescue · ${widget.habit.name}',
      urge: 8,
      replacement: '90-second rescue',
      replacementMinutes: 2,
      outcome: AppStrings.t(context, 'outcomePassed'),
      rescued: true,
    ));
    if (!mounted) return;
    setState(() {});
  }

  int get _left => (_seconds * (1 - _ctrl.value)).ceil();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.trueBlack,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (context, _) {
              return Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white70),
                    ),
                  ),
                  const Spacer(),
                  Text(widget.habit.name, style: GoogleFonts.blackOpsOne(fontSize: 18, color: AppColors.accent)),
                  const SizedBox(height: 12),
                  Text(
                    _done ? AppStrings.t(context, 'rescueDone') : AppStrings.t(context, 'rescueRide'),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                  const SizedBox(height: 36),
                  SizedBox(
                    width: 220,
                    height: 220,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: _done ? 1 : _ctrl.value,
                          strokeWidth: 10,
                          color: _done ? AppColors.success : AppColors.error,
                          backgroundColor: const Color(0xFF2A2A2A),
                        ),
                        Text(
                          _done ? 'OK' : '$_left',
                          style: GoogleFonts.blackOpsOne(fontSize: 64, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (_done)
                    FilledButton(
                      onPressed: () => Navigator.pop(context),
                      style: FilledButton.styleFrom(backgroundColor: AppColors.accent, foregroundColor: Colors.black),
                      child: Text(AppStrings.t(context, 'heldToday').toUpperCase()),
                    )
                  else
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(AppStrings.t(context, 'rescueAbort'), style: GoogleFonts.nunito(color: Colors.white54, fontWeight: FontWeight.w700)),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
