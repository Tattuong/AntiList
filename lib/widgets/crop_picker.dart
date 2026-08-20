import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../models/garden.dart';

class CropPicker {
  CropPicker._();

  static Future<CropKind?> show(
    BuildContext context, {
    CropKind? selected,
    bool allowEmpty = false,
  }) {
    return showModalBottomSheet<CropKind>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: AppColors.sheet(context),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => _CropPickerSheet(selected: selected, allowEmpty: allowEmpty),
    );
  }
}

class _CropPickerSheet extends StatefulWidget {
  final CropKind? selected;
  final bool allowEmpty;
  const _CropPickerSheet({this.selected, required this.allowEmpty});

  @override
  State<_CropPickerSheet> createState() => _CropPickerSheetState();
}

class _CropPickerSheetState extends State<_CropPickerSheet> {
  String _query = '';
  CropGroup? _group;

  List<CropKind> get _items {
    final q = _query.trim().toLowerCase();
    return [
      if (widget.allowEmpty) CropKind.empty,
      ...CropKind.plantable,
    ].where((c) {
      if (c.isEmpty) return q.isEmpty && _group == null;
      if (_group != null && c.group != _group) return false;
      if (q.isEmpty) return true;
      return c.name.toLowerCase().contains(q) || c.groupLabel.toLowerCase().contains(q) || c.sowWindow.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final green = AppColors.brand(context);
    final height = MediaQuery.sizeOf(context).height * 0.78;
    return SizedBox(
      height: height,
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(4))),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(AppStrings.t(context, 'pickCrop'), style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w800, color: green)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: AppStrings.t(context, 'searchCrops'),
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: AppColors.page(context),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(AppStrings.t(context, 'cropGroupAll')),
                    selected: _group == null,
                    onSelected: (_) => setState(() => _group = null),
                  ),
                ),
                for (final g in CropKind.groups)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(CropKind.plantable.firstWhere((c) => c.group == g).groupLabel),
                      selected: _group == g,
                      onSelected: (_) => setState(() => _group = g),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _items.isEmpty
                ? Center(child: Text(AppStrings.t(context, 'noCropsFound'), style: GoogleFonts.nunito(color: AppColors.muted(context))))
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.92,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: _items.length,
                    itemBuilder: (ctx, i) {
                      final c = _items[i];
                      final on = widget.selected?.id == c.id;
                      return Material(
                        color: on ? AppColors.brandSoft(context) : AppColors.page(context),
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => Navigator.pop(context, c),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(c.emoji, style: const TextStyle(fontSize: 26)),
                                const SizedBox(height: 4),
                                Text(c.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 12, color: green)),
                                if (!c.isEmpty)
                                  Text(
                                    '${c.daysToHarvest}d · ${c.sowWindow}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.nunito(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.muted(context)),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class CropPickTile extends StatelessWidget {
  final CropKind crop;
  final VoidCallback onTap;
  const CropPickTile({super.key, required this.crop, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.page(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.line(context)),
        ),
        child: Row(
          children: [
            Text(crop.emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(crop.name, style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
                  Text(
                    crop.isEmpty ? AppStrings.t(context, 'pickCrop') : '${crop.groupLabel} · ${crop.daysToHarvest} days · ${crop.sowWindow}',
                    style: GoogleFonts.nunito(fontSize: 12, color: AppColors.muted(context)),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.muted(context)),
          ],
        ),
      ),
    );
  }
}
