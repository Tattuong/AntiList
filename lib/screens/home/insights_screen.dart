import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/antilist_provider.dart';
import '../../widgets/app_toast.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final list = context.watch<AntiListProvider>();
    final time = list.timeReclaimedMinutes;
    final h = time ~/ 60;
    final m = time % 60;
    final heat = list.heatmap();
    final tops = list.topReplacements().entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return ColoredBox(
      color: AppColors.page(context),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
          children: [
            Text(AppStrings.t(context, 'insights'), style: GoogleFonts.blackOpsOne(fontSize: 34, color: AppColors.display(context), height: 1)),
            const SizedBox(height: 4),
            Text(AppStrings.t(context, 'insightsSub'), style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.muted(context))),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(child: _Stat(icon: Icons.schedule, label: AppStrings.t(context, 'timeReclaimed'), value: '${h}h ${m}m')),
                const SizedBox(width: 8),
                Expanded(child: _Stat(icon: Icons.attach_money, label: AppStrings.t(context, 'moneySaved'), value: '\$${list.moneySaved.round()}')),
                const SizedBox(width: 8),
                Expanded(child: _Stat(icon: Icons.bolt, label: AppStrings.t(context, 'urgesResisted'), value: '${list.urgesResisted}')),
              ],
            ),
            const SizedBox(height: 18),
            Text(AppStrings.t(context, 'triggerHeatmap').toUpperCase(), style: GoogleFonts.nunito(fontWeight: FontWeight.w800, color: AppColors.navMark(context), letterSpacing: 0.8, fontSize: 12)),
            const SizedBox(height: 8),
            _Heatmap(heat: heat, labels: list.habits.map((e) => e.name.split(' ').first).toList(), ids: list.habits.map((e) => e.id).toList()),
            const SizedBox(height: 18),
            Text(AppStrings.t(context, 'topReplacements').toUpperCase(), style: GoogleFonts.nunito(fontWeight: FontWeight.w800, color: AppColors.navMark(context), letterSpacing: 0.8, fontSize: 12)),
            const SizedBox(height: 8),
            if (tops.isEmpty)
              Text(AppStrings.t(context, 'emptyReplace'), style: GoogleFonts.nunito(color: AppColors.muted(context)))
            else
              for (final e in tops.take(4))
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(child: Text(e.key, style: GoogleFonts.nunito(fontWeight: FontWeight.w800, color: AppColors.ink(context)))),
                      Text('${e.value}m', style: GoogleFonts.nunito(fontWeight: FontWeight.w800, color: AppColors.accentDeep)),
                    ],
                  ),
                ),
            const SizedBox(height: 16),
            Text(AppStrings.t(context, 'relapseNotes').toUpperCase(), style: GoogleFonts.nunito(fontWeight: FontWeight.w800, color: AppColors.navMark(context), letterSpacing: 0.8, fontSize: 12)),
            const SizedBox(height: 8),
            _NoteBox(initial: list.relapseNote, onSave: list.setRelapseNote),
            const SizedBox(height: 16),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.accent, foregroundColor: Colors.black, minimumSize: const Size.fromHeight(48)),
              onPressed: () async {
                await list.resetWeek();
                if (context.mounted) AppToast.show(context, title: AppStrings.t(context, 'resetWeek'));
              },
              child: Text(AppStrings.t(context, 'resetWeek'), style: GoogleFonts.blackOpsOne(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoteBox extends StatefulWidget {
  final String initial;
  final Future<void> Function(String) onSave;
  const _NoteBox({required this.initial, required this.onSave});

  @override
  State<_NoteBox> createState() => _NoteBoxState();
}

class _NoteBoxState extends State<_NoteBox> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initial);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _ctrl,
      maxLines: 3,
      decoration: InputDecoration(
        hintText: AppStrings.t(context, 'relapseHint'),
        filled: true,
        fillColor: AppColors.card(context),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppColors.line(context))),
      ),
      onChanged: widget.onSave,
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _Stat({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 14, 10, 14),
      decoration: BoxDecoration(color: AppColors.card(context), borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.line(context))),
      child: Column(
        children: [
          Icon(icon, color: AppColors.navMark(context), size: 22),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.blackOpsOne(fontSize: 18, color: AppColors.display(context))),
          const SizedBox(height: 4),
          Text(label, textAlign: TextAlign.center, maxLines: 2, style: GoogleFonts.nunito(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.muted(context), height: 1.15)),
        ],
      ),
    );
  }
}

class _Heatmap extends StatelessWidget {
  final Map<String, List<int>> heat;
  final List<String> labels;
  final List<String> ids;
  const _Heatmap({required this.heat, required this.labels, required this.ids});

  Color _cell(BuildContext context, int n) {
    final light = Theme.of(context).brightness == Brightness.light;
    if (n <= 0) return light ? const Color(0xFFE8F5E9) : const Color(0xFF1F3A24);
    if (n == 1) return const Color(0xFF4ADE80);
    if (n == 2) return const Color(0xFFF5C400);
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return Column(
      children: [
        Row(
          children: [
            const SizedBox(width: 72),
            for (final d in days)
              Expanded(child: Text(d, textAlign: TextAlign.center, style: GoogleFonts.nunito(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.muted(context)))),
          ],
        ),
        const SizedBox(height: 6),
        for (var r = 0; r < ids.length; r++)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                SizedBox(width: 72, child: Text(labels[r], maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.nunito(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.ink(context)))),
                for (var c = 0; c < 7; c++)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: DecoratedBox(
                          decoration: BoxDecoration(color: _cell(context, (heat[ids[r]] ?? const [0, 0, 0, 0, 0, 0, 0])[c]), borderRadius: BorderRadius.circular(4)),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
