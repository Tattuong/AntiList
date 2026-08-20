import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/calc/gpa_math.dart';
import '../../core/calc/syllabus_presets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/course.dart';
import '../../providers/grades_provider.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_toast.dart';

class CourseEditorScreen extends StatefulWidget {
  final String? courseId;
  final SyllabusPreset? preset;
  const CourseEditorScreen({super.key, this.courseId, this.preset});

  @override
  State<CourseEditorScreen> createState() => _CourseEditorScreenState();
}

class _CourseEditorScreenState extends State<CourseEditorScreen> {
  late Course _course;
  bool _isNew = false;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _codeCtrl;
  double _whatIf = 80;

  @override
  void initState() {
    super.initState();
    final grades = context.read<GradesProvider>();
    if (widget.courseId != null) {
      _course = grades.courses.firstWhere((c) => c.id == widget.courseId, orElse: () => _blank());
      _isNew = !grades.courses.any((c) => c.id == widget.courseId);
    } else {
      _course = _blank(widget.preset);
      _isNew = true;
    }
    _nameCtrl = TextEditingController(text: _course.name);
    _codeCtrl = TextEditingController(text: _course.code);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  Course _blank([SyllabusPreset? preset]) {
    final n = context.read<GradesProvider>().courses.length;
    return Course(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: preset == null ? 'New course' : AppStrings.tCode(preset.nameKey),
      code: 'CODE',
      colorIndex: n % 6,
      assignments: preset?.assignments ??
          const [
            Assignment(id: 'hw', name: 'Homework', weight: 20, score: 90),
            Assignment(id: 'mid', name: 'Midterm', weight: 30, score: 85),
            Assignment(id: 'fin', name: 'Final Exam', weight: 50, isFinal: true),
          ],
    );
  }

  Future<void> _save() async {
    final grades = context.read<GradesProvider>();
    if (_isNew && grades.courses.length >= grades.courseCap) {
      AppToast.show(context, title: AppStrings.t(context, 'courseCap'));
      return;
    }
    await grades.upsertCourse(_course);
    if (mounted) Navigator.pop(context);
  }

  void _editAssignment(Assignment a) async {
    final name = TextEditingController(text: a.name);
    final weight = TextEditingController(text: a.weight.toStringAsFixed(0));
    final score = TextEditingController(text: a.score?.toStringAsFixed(1) ?? '');
    var isFinal = a.isFinal;
    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: Text(AppStrings.t(ctx, 'editItem')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: name, decoration: InputDecoration(labelText: AppStrings.t(ctx, 'itemName'))),
              TextField(controller: weight, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: AppStrings.t(ctx, 'weight'))),
              TextField(controller: score, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: AppStrings.t(ctx, 'scoreHint'))),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(AppStrings.t(ctx, 'markFinal')),
                value: isFinal,
                onChanged: (v) => setD(() => isFinal = v),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(AppStrings.t(ctx, 'cancel'))),
            TextButton(
              onPressed: () {
                setState(() {
                  _course = _course.copyWith(
                    assignments: [
                      for (final x in _course.assignments)
                        if (x.id == a.id)
                          x.copyWith(
                            name: name.text.trim().isEmpty ? x.name : name.text.trim(),
                            weight: double.tryParse(weight.text) ?? x.weight,
                            score: score.text.trim().isEmpty ? null : double.tryParse(score.text),
                            clearScore: score.text.trim().isEmpty,
                            isFinal: isFinal,
                          )
                        else
                          x,
                    ],
                  );
                });
                Navigator.pop(ctx);
              },
              child: Text(AppStrings.t(ctx, 'save')),
            ),
          ],
        ),
      ),
    );
    name.dispose();
    weight.dispose();
    score.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ink = AppColors.ink(context);
    final exam = _course.finalExam;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: FtrBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 8, 0),
                child: Row(
                  children: [
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_rounded)),
                    Expanded(
                      child: Text(_course.name, style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w800, color: ink)),
                    ),
                    if (!_isNew)
                      IconButton(
                        onPressed: () async {
                          await context.read<GradesProvider>().deleteCourse(_course.id);
                          if (context.mounted) Navigator.pop(context);
                        },
                        icon: const Icon(Icons.delete_outline_rounded),
                      ),
                    TextButton(onPressed: _save, child: Text(AppStrings.t(context, 'save'))),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    Row(
                      children: [
                        _Stat(label: AppStrings.t(context, 'currentGrade'), value: '${_course.currentPercent.toStringAsFixed(1)}%'),
                        _Stat(label: AppStrings.t(context, 'finalWeight'), value: '${(exam?.weight ?? 0).toStringAsFixed(0)}%'),
                        _Stat(label: AppStrings.t(context, 'currentGpaShort'), value: _course.currentGpa.toStringAsFixed(2)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _nameCtrl,
                      onChanged: (v) => _course = _course.copyWith(name: v),
                      decoration: InputDecoration(labelText: AppStrings.t(context, 'courseName')),
                    ),
                    TextField(
                      controller: _codeCtrl,
                      onChanged: (v) => _course = _course.copyWith(code: v),
                      decoration: InputDecoration(labelText: AppStrings.t(context, 'courseCode')),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(AppStrings.t(context, 'assignments'), style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _course = _course.copyWith(
                                assignments: [
                                  ..._course.assignments,
                                  Assignment(id: DateTime.now().millisecondsSinceEpoch.toString(), name: 'New item', weight: 5),
                                ],
                              );
                            });
                          },
                          child: Text(AppStrings.t(context, 'addItem')),
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.card(context),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.line(context)),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
                            child: Row(
                              children: [
                                Expanded(flex: 3, child: Text(AppStrings.t(context, 'itemName'), style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.muted(context)))),
                                Expanded(child: Text(AppStrings.t(context, 'weight'), style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.muted(context)))),
                                Expanded(child: Text(AppStrings.t(context, 'score'), style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.muted(context)))),
                                const SizedBox(width: 32),
                              ],
                            ),
                          ),
                          for (final a in _course.assignments)
                            ListTile(
                              dense: true,
                              title: Text(a.name, style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
                              subtitle: Text('${a.weight.toStringAsFixed(0)}% · ${a.score == null ? '—' : '${a.score!.toStringAsFixed(0)}%'}'),
                              trailing: IconButton(icon: const Icon(Icons.edit_outlined, size: 18), onPressed: () => _editAssignment(a)),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      AppStrings.t(context, 'weightTotal', {'n': _course.totalWeight.toStringAsFixed(0), 'g': _course.currentPercent.toStringAsFixed(1)}),
                      style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(AppStrings.t(context, 'calcTip'), style: GoogleFonts.nunito(fontSize: 12, color: AppColors.muted(context))),
                    if (_course.remainingWeight > 0) ...[
                      const SizedBox(height: 16),
                      Text(AppStrings.t(context, 'whatIfRemaining'), style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
                      Slider(
                        value: _whatIf,
                        min: 0,
                        max: 100,
                        divisions: 20,
                        label: '${_whatIf.round()}%',
                        onChanged: (v) => setState(() => _whatIf = v),
                      ),
                      Text(
                        AppStrings.t(context, 'whatIfResult', {
                          'avg': '${_whatIf.round()}',
                          'grade': _course.percentIfRemaining(_whatIf).toStringAsFixed(1),
                          'letter': GpaMath.letterLabel(_course.percentIfRemaining(_whatIf)),
                        }),
                        style: GoogleFonts.nunito(fontWeight: FontWeight.w700, color: AppColors.ink(context)),
                      ),
                    ],
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

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(label, textAlign: TextAlign.center, style: GoogleFonts.nunito(fontSize: 11, color: AppColors.muted(context), fontWeight: FontWeight.w700)),
          Text(value, style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 16)),
        ],
      ),
    );
  }
}
