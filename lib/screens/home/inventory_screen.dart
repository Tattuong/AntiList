import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/garden.dart';
import '../../providers/garden_provider.dart';
import '../../widgets/crop_picker.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final garden = context.watch<GardenProvider>();
    final green = AppColors.brand(context);
    return DefaultTabController(
      length: 3,
      child: ColoredBox(
        color: AppColors.page(context),
        child: SafeArea(
          child: Builder(
          builder: (context) => Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 8, 0),
                child: Row(
                  children: [
                    Expanded(child: Text(AppStrings.t(context, 'inventoryHarvest'), style: GoogleFonts.nunito(fontSize: 24, fontWeight: FontWeight.w800, color: green))),
                    IconButton(
                      onPressed: () => _add(context, garden),
                      icon: const Icon(Icons.add_circle, color: AppColors.accent, size: 32),
                    ),
                  ],
                ),
              ),
              TabBar(
                labelColor: green,
                unselectedLabelColor: AppColors.muted(context),
                indicatorColor: green,
                tabs: [
                  Tab(text: AppStrings.t(context, 'tabSeeds')),
                  Tab(text: AppStrings.t(context, 'tabSupplies')),
                  Tab(text: AppStrings.t(context, 'tabHarvest')),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _SeedsTab(garden: garden),
                    _SuppliesTab(garden: garden),
                    _HarvestTab(garden: garden),
                  ],
                ),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }

  Future<void> _add(BuildContext context, GardenProvider garden) async {
    final tab = DefaultTabController.of(context).index;
    if (tab == 2) {
      await _addHarvest(context, garden);
    } else {
      await _addSeed(context, garden);
    }
  }

  Future<void> _addSeed(BuildContext context, GardenProvider garden) async {
    CropKind crop = CropKind.lettuce;
    final variety = TextEditingController();
    final grams = TextEditingController(text: '2.0');
    final price = TextEditingController(text: '1.50');
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + MediaQuery.of(ctx).viewInsets.bottom),
        child: StatefulBuilder(
          builder: (ctx, setSt) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(AppStrings.t(ctx, 'addSeed'), style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 18)),
              CropPickTile(
                crop: crop,
                onTap: () async {
                  final picked = await CropPicker.show(ctx, selected: crop);
                  if (picked != null) setSt(() => crop = picked);
                },
              ),
              TextField(controller: variety, decoration: InputDecoration(labelText: AppStrings.t(ctx, 'variety'))),
              TextField(controller: grams, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: AppStrings.t(ctx, 'grams'))),
              TextField(controller: price, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: AppStrings.t(ctx, 'price'))),
              FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(AppStrings.t(ctx, 'save'))),
            ],
          ),
        ),
      ),
    );
    if (ok == true) {
      await garden.upsertSeed(SeedLot(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        cropId: crop.id,
        variety: variety.text.trim().isEmpty ? crop.name : variety.text.trim(),
        grams: double.tryParse(grams.text) ?? 0,
        price: double.tryParse(price.text) ?? 0,
        lastSown: DateTime.now(),
      ));
    }
    variety.dispose();
    grams.dispose();
    price.dispose();
  }

  Future<void> _addHarvest(BuildContext context, GardenProvider garden) async {
    CropKind crop = CropKind.lettuce;
    final variety = TextEditingController();
    final kg = TextEditingController(text: '1.0');
    final value = TextEditingController(text: '4.00');
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + MediaQuery.of(ctx).viewInsets.bottom),
        child: StatefulBuilder(
          builder: (ctx, setSt) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(AppStrings.t(ctx, 'addHarvest'), style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 18)),
              CropPickTile(
                crop: crop,
                onTap: () async {
                  final picked = await CropPicker.show(ctx, selected: crop);
                  if (picked != null) setSt(() => crop = picked);
                },
              ),
              TextField(controller: variety, decoration: InputDecoration(labelText: AppStrings.t(ctx, 'variety'))),
              TextField(controller: kg, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'kg')),
              TextField(controller: value, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: AppStrings.t(ctx, 'price'))),
              FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(AppStrings.t(ctx, 'save'))),
            ],
          ),
        ),
      ),
    );
    if (ok == true) {
      await garden.addHarvest(HarvestEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        cropId: crop.id,
        variety: variety.text.trim().isEmpty ? crop.name : variety.text.trim(),
        kg: double.tryParse(kg.text) ?? 0,
        value: double.tryParse(value.text) ?? 0,
        date: DateTime.now(),
      ));
    }
    variety.dispose();
    kg.dispose();
    value.dispose();
  }
}

class _SeedsTab extends StatelessWidget {
  final GardenProvider garden;
  const _SeedsTab({required this.garden});

  @override
  Widget build(BuildContext context) {
    if (garden.seeds.isEmpty) {
      return Center(child: Text(AppStrings.t(context, 'seedsEmpty')));
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final s in garden.seeds)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: AppColors.card(context),
              borderRadius: BorderRadius.circular(14),
              child: ListTile(
                leading: CircleAvatar(backgroundColor: s.crop.color.withValues(alpha: 0.2), child: Text(s.crop.emoji)),
                title: Text('${s.crop.name}  ${s.variety}', style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
                subtitle: Text('${s.grams}g · \$${s.price.toStringAsFixed(2)}${s.lastSown == null ? '' : ' · ${AppStrings.t(context, 'lastSown')} ${DateFormat.MMMd().format(s.lastSown!)}'}'),
                trailing: IconButton(onPressed: () => garden.deleteSeed(s.id), icon: const Icon(Icons.delete_outline)),
              ),
            ),
          ),
      ],
    );
  }
}

class _SuppliesTab extends StatelessWidget {
  final GardenProvider garden;
  const _SuppliesTab({required this.garden});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final s in garden.supplies)
          ListTile(
            leading: const Icon(Icons.inventory_2_outlined),
            title: Text(s.name, style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
            subtitle: Text(s.qty),
          ),
      ],
    );
  }
}

class _HarvestTab extends StatelessWidget {
  final GardenProvider garden;
  const _HarvestTab({required this.garden});

  @override
  Widget build(BuildContext context) {
    final byMonth = garden.yieldByMonth();
    final months = [3, 4, 5, 6, 7];
    final maxV = months.map((m) => byMonth[m] ?? 0).fold<double>(0, (a, b) => a > b ? a : b);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(child: _Stat(AppStrings.t(context, 'totalYield'), '${garden.totalYieldKg.toStringAsFixed(1)} kg')),
            const SizedBox(width: 10),
            Expanded(child: _Stat(AppStrings.t(context, 'totalValue'), '\$${garden.totalHarvestValue.toStringAsFixed(2)}')),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 140,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final m in months)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: FractionallySizedBox(
                              heightFactor: maxV <= 0 ? 0.08 : ((byMonth[m] ?? 0) / maxV).clamp(0.08, 1),
                              child: Container(decoration: BoxDecoration(color: AppColors.brand(context), borderRadius: BorderRadius.circular(6))),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(DateFormat.MMM().format(DateTime(2026, m)), style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(AppStrings.t(context, 'recentHarvests'), style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.brand(context))),
        if (garden.harvests.isEmpty) Text(AppStrings.t(context, 'harvestEmpty')),
        for (final h in garden.harvests)
          ListTile(
            leading: const Icon(Icons.menu_book_outlined),
            title: Text('${h.crop.name} ${h.variety}', style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
            subtitle: Text('${h.kg.toStringAsFixed(1)} kg · ${DateFormat.MMMd().format(h.date)}'),
            trailing: IconButton(onPressed: () => garden.deleteHarvest(h.id), icon: const Icon(Icons.delete_outline)),
          ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.card(context), borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.line(context))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.nunito(fontSize: 12, color: AppColors.muted(context), fontWeight: FontWeight.w700)),
          Text(value, style: GoogleFonts.nunito(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.brand(context))),
        ],
      ),
    );
  }
}
