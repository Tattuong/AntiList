import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/calc/syllabus_presets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/grades_provider.dart';
import 'course_editor_screen.dart';

class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final grades = context.watch<GradesProvider>();
    final ink = AppColors.ink(context);
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(AppStrings.t(context, 'calculator'), style: GoogleFonts.nunito(fontSize: 28, fontWeight: FontWeight.w800, color: ink)),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CourseEditorScreen())),
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
          Text(AppStrings.t(context, 'calcHint'), style: GoogleFonts.nunito(color: AppColors.muted(context))),
          const SizedBox(height: 12),
          Text(AppStrings.t(context, 'quickSyllabus'), style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.muted(context))),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final p in SyllabusPreset.all)
                ActionChip(
                  avatar: Icon(p.icon, size: 16, color: p.color),
                  label: Text(AppStrings.t(context, p.nameKey), style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CourseEditorScreen(preset: p))),
                ),
            ],
          ),
          const SizedBox(height: 14),
          for (final c in grades.courses)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                onTap: () {
                  grades.setFocus(c.id);
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => CourseEditorScreen(courseId: c.id)));
                },
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                tileColor: AppColors.card(context),
                leading: CircleAvatar(
                  backgroundColor: AppColors.subjects[c.colorIndex % AppColors.subjects.length],
                  child: Text(c.currentLetter, style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12)),
                ),
                title: Text(c.name, style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
                subtitle: Text('${c.code} · ${c.currentPercent.toStringAsFixed(1)}%'),
                trailing: const Icon(Icons.chevron_right_rounded),
              ),
            ),
        ],
      ),
    );
  }
}
