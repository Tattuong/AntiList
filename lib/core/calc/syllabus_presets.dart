import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../../models/course.dart';

class SyllabusPreset {
  final String nameKey;
  final IconData icon;
  final Color color;
  final List<Assignment> assignments;

  const SyllabusPreset({
    required this.nameKey,
    required this.icon,
    required this.color,
    required this.assignments,
  });

  static const all = [
    SyllabusPreset(
      nameKey: 'presetStem',
      icon: Icons.functions_rounded,
      color: AppColors.primary,
      assignments: [
        Assignment(id: 'hw', name: 'Homework', weight: 20),
        Assignment(id: 'mid', name: 'Midterm', weight: 30),
        Assignment(id: 'fin', name: 'Final Exam', weight: 50, isFinal: true),
      ],
    ),
    SyllabusPreset(
      nameKey: 'presetLab',
      icon: Icons.science_outlined,
      color: AppColors.concrete,
      assignments: [
        Assignment(id: 'lab', name: 'Labs', weight: 40),
        Assignment(id: 'mid', name: 'Midterm', weight: 20),
        Assignment(id: 'fin', name: 'Final Exam', weight: 40, isFinal: true),
      ],
    ),
    SyllabusPreset(
      nameKey: 'presetEssay',
      icon: Icons.menu_book_outlined,
      color: AppColors.accent,
      assignments: [
        Assignment(id: 'p', name: 'Papers', weight: 50),
        Assignment(id: 'part', name: 'Participation', weight: 20),
        Assignment(id: 'fin', name: 'Final paper', weight: 30, isFinal: true),
      ],
    ),
  ];
}
