import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../models/course.dart';
import '../core/services/storage_service.dart';
import 'shop_provider.dart';

class GradesProvider extends ChangeNotifier {
  static const _coursesKey = 'gm_courses';
  static const _onboardKey = 'gm_onboarding_done';
  static const _goalKey = 'gm_goal_gpa';
  static const _historyKey = 'gm_gpa_history';
  static const _focusKey = 'gm_focus_course';

  ShopProvider? _shop;
  List<Course> _courses = [];
  List<double> _history = [];
  bool _onboardingComplete = false;
  double _goalGpa = 3.50;
  String? _focusId;

  List<Course> get courses => List.unmodifiable(_courses);
  List<double> get gpaHistory => List.unmodifiable(_history);
  bool get onboardingComplete => _onboardingComplete;
  double get goalGpa => _goalGpa;
  String? get focusId => _focusId;

  int get courseCap => _shop?.hasCoursePack == true ? 40 : 6;

  Course? get focusCourse {
    if (_courses.isEmpty) return null;
    final match = _courses.where((c) => c.id == _focusId);
    if (match.isNotEmpty) return match.first;
    return _courses.first;
  }

  double get semesterGpa => GradeSnapshot.semesterGpa(_courses);

  void bindShop(ShopProvider shop) => _shop = shop;

  Future<void> init() async {
    _onboardingComplete = await StorageService.instance.getBool(_onboardKey) ?? false;
    _goalGpa = await StorageService.instance.getDouble(_goalKey) ?? 3.50;
    _focusId = await StorageService.instance.getString(_focusKey);
    final raw = await StorageService.instance.getString(_coursesKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final list = jsonDecode(raw) as List<dynamic>;
        _courses = list.map((e) => Course.fromJson(Map<String, dynamic>.from(e as Map))).toList();
      } catch (_) {
        _courses = [];
      }
    }
    if (_courses.isEmpty) _courses = _seed();
    final hist = await StorageService.instance.getString(_historyKey);
    if (hist != null && hist.isNotEmpty) {
      try {
        _history = (jsonDecode(hist) as List<dynamic>).map((e) => (e as num).toDouble()).toList();
      } catch (_) {
        _history = [];
      }
    }
    if (_history.isEmpty) {
      _history = const [3.12, 3.18, 3.15, 3.22, 3.28, 3.25, 3.31, 3.35, 3.38, 3.40, 3.42, 3.41, 3.43, 3.44, 3.45];
    }
    notifyListeners();
  }

  List<Course> _seed() {
    return const [
      Course(
        id: 'c1',
        name: 'Data Structures',
        code: 'CS 201',
        colorIndex: 0,
        assignments: const [
          Assignment(id: 'a1', name: 'Homework 1', weight: 5, score: 95),
          Assignment(id: 'a2', name: 'Lab 2', weight: 10, score: 90),
          Assignment(id: 'a3', name: 'Midterm Exam', weight: 30, score: 89),
          Assignment(id: 'a4', name: 'Quizzes', weight: 25, score: 88),
          Assignment(id: 'a5', name: 'Final Exam', weight: 30, isFinal: true),
        ],
      ),
      Course(
        id: 'c2',
        name: 'Calculus I',
        code: 'MATH 101',
        colorIndex: 1,
        assignments: const [
          Assignment(id: 'b1', name: 'Homework', weight: 20, score: 84),
          Assignment(id: 'b2', name: 'Midterm', weight: 30, score: 78),
          Assignment(id: 'b3', name: 'Final Exam', weight: 50, isFinal: true),
        ],
      ),
      Course(
        id: 'c3',
        name: 'English Comp',
        code: 'ENG 102',
        colorIndex: 2,
        assignments: const [
          Assignment(id: 'd1', name: 'Essays', weight: 40, score: 91),
          Assignment(id: 'd2', name: 'Participation', weight: 20, score: 95),
          Assignment(id: 'd3', name: 'Final Paper', weight: 40, isFinal: true),
        ],
      ),
      Course(
        id: 'c4',
        name: 'Physics',
        code: 'PHYS 201',
        colorIndex: 3,
        assignments: const [
          Assignment(id: 'e1', name: 'Labs', weight: 25, score: 86),
          Assignment(id: 'e2', name: 'Midterm', weight: 35, score: 80),
          Assignment(id: 'e3', name: 'Final Exam', weight: 40, isFinal: true),
        ],
      ),
    ];
  }

  Future<void> _persist() async {
    await StorageService.instance.saveString(
      _coursesKey,
      jsonEncode(_courses.map((c) => c.toJson()).toList()),
    );
    await StorageService.instance.saveString(_historyKey, jsonEncode(_history));
    await StorageService.instance.saveDouble(_goalKey, _goalGpa);
    if (_focusId != null) {
      await StorageService.instance.saveString(_focusKey, _focusId!);
    }
  }

  Future<void> completeOnboarding() async {
    _onboardingComplete = true;
    await StorageService.instance.saveBool(_onboardKey, true);
    notifyListeners();
  }

  Future<void> setGoal(double gpa) async {
    _goalGpa = gpa.clamp(0, 4);
    await _persist();
    notifyListeners();
  }

  Future<void> setFocus(String id) async {
    _focusId = id;
    await _persist();
    notifyListeners();
  }

  Future<void> upsertCourse(Course course) async {
    final i = _courses.indexWhere((c) => c.id == course.id);
    if (i >= 0) {
      _courses = [..._courses]..[i] = course;
    } else {
      if (_courses.length >= courseCap) return;
      _courses = [..._courses, course];
      await _shop?.rewardForJobSave();
    }
    _pushHistory();
    await _persist();
    notifyListeners();
  }

  Future<void> deleteCourse(String id) async {
    _courses = _courses.where((c) => c.id != id).toList();
    if (_focusId == id) _focusId = _courses.isEmpty ? null : _courses.first.id;
    await _persist();
    notifyListeners();
  }

  void _pushHistory() {
    final g = semesterGpa;
    if (_history.isEmpty || (g - _history.last).abs() > 0.005) {
      _history = [..._history, g].take(15).toList();
      if (_history.length > 15) _history = _history.sublist(_history.length - 15);
    }
  }
}
