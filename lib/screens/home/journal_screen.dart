import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/garden.dart';
import '../../providers/garden_provider.dart';

class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final garden = context.watch<GardenProvider>();
    final green = AppColors.brand(context);
    return ColoredBox(
      color: AppColors.page(context),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            Row(
              children: [
                Expanded(child: Text(AppStrings.t(context, 'journal'), style: GoogleFonts.nunito(fontSize: 28, fontWeight: FontWeight.w800, color: green))),
                TextButton(onPressed: () => _edit(context, garden, null), child: Text(AppStrings.t(context, 'addItem'))),
              ],
            ),
            if (garden.notes.isEmpty) Text(AppStrings.t(context, 'journalEmpty'), style: GoogleFonts.nunito(color: AppColors.muted(context))),
            for (final n in garden.notes)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Material(
                  color: AppColors.card(context),
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    onTap: () => _edit(context, garden, n),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(n.title, style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 16)),
                          Text(DateFormat.yMMMd().format(n.at), style: GoogleFonts.nunito(fontSize: 12, color: AppColors.muted(context))),
                          const SizedBox(height: 6),
                          Text(n.body, style: GoogleFonts.nunito(height: 1.4)),
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(onPressed: () => garden.deleteNote(n.id), icon: const Icon(Icons.delete_outline)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _edit(BuildContext context, GardenProvider garden, JournalNote? note) async {
    final title = TextEditingController(text: note?.title ?? '');
    final body = TextEditingController(text: note?.body ?? '');
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + MediaQuery.of(ctx).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppStrings.t(ctx, 'addNote'), style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 18)),
            TextField(controller: title, decoration: InputDecoration(labelText: AppStrings.t(ctx, 'itemName'))),
            TextField(controller: body, maxLines: 4, decoration: const InputDecoration(labelText: 'Note')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(AppStrings.t(ctx, 'save'))),
          ],
        ),
      ),
    );
    if (ok == true && title.text.trim().isNotEmpty) {
      await garden.upsertNote(JournalNote(
        id: note?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: title.text.trim(),
        body: body.text.trim(),
        at: note?.at ?? DateTime.now(),
      ));
    }
    title.dispose();
    body.dispose();
  }
}
