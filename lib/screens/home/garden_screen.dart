import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/garden.dart';
import '../../providers/garden_provider.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/crop_picker.dart';
import '../../widgets/garden_plot.dart';

class GardenScreen extends StatelessWidget {
  const GardenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final garden = context.watch<GardenProvider>();
    final bed = garden.activeBed;
    final green = AppColors.brand(context);
    final layout = BedLayout.matching(bed.rows, bed.cols);
    return ColoredBox(
      color: AppColors.page(context),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            Row(
              children: [
                Expanded(child: Text(AppStrings.t(context, 'gardenGrid'), style: GoogleFonts.nunito(fontSize: 26, fontWeight: FontWeight.w800, color: green))),
                DropdownButton<String>(
                  value: garden.beds.any((b) => b.id == bed.id) ? bed.id : null,
                  underline: const SizedBox.shrink(),
                  items: [
                    for (final b in garden.beds) DropdownMenuItem(value: b.id, child: Text(b.name)),
                  ],
                  onChanged: (id) {
                    if (id != null) garden.setActiveBed(id);
                  },
                ),
                IconButton(
                  tooltip: AppStrings.t(context, 'newBed'),
                  onPressed: () => _addBed(context, garden),
                  icon: const Icon(Icons.add_box_outlined),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${layout.name} · ${layout.sizeLabel}',
                    style: GoogleFonts.nunito(fontWeight: FontWeight.w700, color: AppColors.muted(context)),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _pickLayout(context, garden, selected: layout),
                  icon: const Icon(Icons.grid_view_rounded, size: 18),
                  label: Text(AppStrings.t(context, 'changeLayout')),
                ),
              ],
            ),
            const SizedBox(height: 8),
            GardenPlot(bed: bed, onTapCell: (i) => _pickCrop(context, garden, i)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.card(context),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE8D5B0)),
                boxShadow: [BoxShadow(color: const Color(0xFF3A2410).withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: AppColors.brandSoft(context), borderRadius: BorderRadius.circular(14)),
                    child: const Text('🌼', style: TextStyle(fontSize: 26)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          CropKind.companionForBed(bed.cells),
                          style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
                        ),
                        if (bed.cells.any((c) => !c.crop.isEmpty))
                          Text(
                            bed.cells.where((c) => !c.crop.isEmpty).map((c) => c.crop.name).toSet().join(' · '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.nunito(fontSize: 12, color: AppColors.muted(context)),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () async {
                final ctrl = TextEditingController(text: bed.notes);
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(AppStrings.t(ctx, 'bedNotes')),
                    content: TextField(controller: ctrl, maxLines: 4),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppStrings.t(ctx, 'cancel'))),
                      FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(AppStrings.t(ctx, 'save'))),
                    ],
                  ),
                );
                if (ok == true) await garden.setBedNotes(ctrl.text.trim());
                ctrl.dispose();
              },
              icon: const Icon(Icons.notes_outlined),
              label: Text(AppStrings.t(context, 'bedNotes')),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickCrop(BuildContext context, GardenProvider garden, int index) async {
    final current = garden.activeBed.cells.length > index ? garden.activeBed.cells[index].crop : CropKind.empty;
    final picked = await CropPicker.show(context, selected: current, allowEmpty: true);
    if (picked != null) garden.setCell(index, picked.id);
  }

  Future<void> _pickLayout(BuildContext context, GardenProvider garden, {required BedLayout selected}) async {
    final picked = await showModalBottomSheet<BedLayout>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.sheet(context),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => _LayoutSheet(selected: selected),
    );
    if (picked == null) return;
    await garden.setBedLayout(picked);
  }

  Future<void> _addBed(BuildContext context, GardenProvider garden) async {
    var layout = BedLayout.raised;
    final name = TextEditingController(text: 'Bed ${garden.beds.length + 1}');
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) {
          final maxH = MediaQuery.sizeOf(ctx).height * 0.55;
          return AlertDialog(
            title: Text(AppStrings.t(ctx, 'newBed')),
            content: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxH, maxWidth: 400),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(controller: name, decoration: InputDecoration(labelText: AppStrings.t(ctx, 'itemName'))),
                    const SizedBox(height: 12),
                    Text(AppStrings.t(ctx, 'bedLayout'), style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final l in BedLayout.all)
                          ChoiceChip(
                            visualDensity: VisualDensity.compact,
                            label: Text('${l.name} ${l.sizeLabel}'),
                            selected: layout.id == l.id,
                            onSelected: (_) => setSt(() => layout = l),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppStrings.t(ctx, 'cancel'))),
              FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(AppStrings.t(ctx, 'save'))),
            ],
          );
        },
      ),
    );
    if (ok == true) {
      final added = await garden.addBed(name.text.trim().isEmpty ? 'Bed' : name.text.trim(), layout: layout);
      if (!added && context.mounted) AppToast.show(context, title: AppStrings.t(context, 'bedCap'));
    }
    name.dispose();
  }
}

class _LayoutSheet extends StatelessWidget {
  final BedLayout selected;
  const _LayoutSheet({required this.selected});

  @override
  Widget build(BuildContext context) {
    final green = AppColors.brand(context);
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(4)))),
            const SizedBox(height: 14),
            Text(AppStrings.t(context, 'bedLayout'), style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w800, color: green)),
            const SizedBox(height: 4),
            Text(AppStrings.t(context, 'layoutKeepsPlants'), style: GoogleFonts.nunito(fontSize: 13, color: AppColors.muted(context))),
            const SizedBox(height: 14),
            for (final l in BedLayout.all)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: selected.id == l.id ? AppColors.brandSoft(context) : AppColors.page(context),
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => Navigator.pop(context, l),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          _MiniGrid(rows: l.rows, cols: l.cols, active: selected.id == l.id),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${l.name}  ${l.sizeLabel}', style: GoogleFonts.nunito(fontWeight: FontWeight.w800, color: green)),
                                Text(l.blurb, style: GoogleFonts.nunito(fontSize: 12, color: AppColors.muted(context))),
                              ],
                            ),
                          ),
                          if (selected.id == l.id) Icon(Icons.check_circle, color: green),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      ),
    );
  }
}

class _MiniGrid extends StatelessWidget {
  final int rows;
  final int cols;
  final bool active;
  const _MiniGrid({required this.rows, required this.cols, required this.active});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF6B4F32),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: active ? AppColors.brand(context) : const Color(0xFFC4A574), width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            children: [
              for (var r = 0; r < rows; r++)
                Expanded(
                  child: Row(
                    children: [
                      for (var c = 0; c < cols; c++)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(1),
                            child: DecoratedBox(
                              decoration: BoxDecoration(color: const Color(0xFF8B6A42), borderRadius: BorderRadius.circular(2)),
                            ),
                          ),
                        ),
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
