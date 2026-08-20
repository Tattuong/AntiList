import '../core/calc/gpa_math.dart';

class Assignment {
  final String id;
  final String name;
  final double weight;
  final double? score;
  final bool isFinal;

  const Assignment({
    required this.id,
    required this.name,
    required this.weight,
    this.score,
    this.isFinal = false,
  });

  Assignment copyWith({
    String? name,
    double? weight,
    double? score,
    bool clearScore = false,
    bool? isFinal,
  }) {
    return Assignment(
      id: id,
      name: name ?? this.name,
      weight: weight ?? this.weight,
      score: clearScore ? null : (score ?? this.score),
      isFinal: isFinal ?? this.isFinal,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'weight': weight,
        'score': score,
        'isFinal': isFinal,
      };

  factory Assignment.fromJson(Map<String, dynamic> json) => Assignment(
        id: json['id'] as String,
        name: json['name'] as String? ?? 'Item',
        weight: (json['weight'] as num?)?.toDouble() ?? 0,
        score: (json['score'] as num?)?.toDouble(),
        isFinal: json['isFinal'] as bool? ?? false,
      );
}

class Course {
  final String id;
  final String name;
  final String code;
  final int colorIndex;
  final double credits;
  final List<Assignment> assignments;

  const Course({
    required this.id,
    required this.name,
    required this.code,
    required this.colorIndex,
    this.credits = 3,
    required this.assignments,
  });

  Course copyWith({
    String? name,
    String? code,
    int? colorIndex,
    double? credits,
    List<Assignment>? assignments,
  }) {
    return Course(
      id: id,
      name: name ?? this.name,
      code: code ?? this.code,
      colorIndex: colorIndex ?? this.colorIndex,
      credits: credits ?? this.credits,
      assignments: assignments ?? this.assignments,
    );
  }

  double get totalWeight => assignments.fold(0, (s, a) => s + a.weight);

  double get scoredWeight => assignments.where((a) => a.score != null).fold(0, (s, a) => s + a.weight);

  double get earnedPoints =>
      assignments.where((a) => a.score != null).fold(0, (s, a) => s + a.score! * a.weight / 100);

  /// Weighted average of items that already have a score (final excluded until scored).
  double get currentPercent {
    if (scoredWeight <= 0) return 0;
    return assignments.where((a) => a.score != null).fold(0.0, (s, a) => s + a.score! * a.weight) / scoredWeight;
  }

  double get remainingWeight {
    final r = totalWeight - scoredWeight;
    return r < 0 ? 0 : r;
  }

  /// Average needed on unscored work to finish the course at [targetPercent].
  double? remainingNeededFor(double targetPercent) {
    if (remainingWeight <= 0) return null;
    return GpaMath.requiredScore(
      earnedPoints: earnedPoints,
      scoredWeight: scoredWeight,
      remainingWeight: remainingWeight,
      targetPercent: targetPercent,
    );
  }

  double percentIfRemaining(double remainingAverage) {
    if (totalWeight <= 0) return currentPercent;
    return (earnedPoints + remainingAverage * remainingWeight / 100) * 100 / totalWeight;
  }

  double percentWithFinal(double finalScore) {
    var num = 0.0;
    var den = 0.0;
    for (final a in assignments) {
      final score = a.isFinal ? finalScore : a.score;
      if (score == null) continue;
      num += score * a.weight;
      den += a.weight;
    }
    if (den <= 0) return 0;
    return num / den;
  }

  Assignment? get finalExam {
    for (final a in assignments) {
      if (a.isFinal) return a;
    }
    return null;
  }

  double get currentGpa => GpaMath.gpaFor(currentPercent);
  String get currentLetter => GpaMath.letterLabel(currentPercent);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'code': code,
        'colorIndex': colorIndex,
        'credits': credits,
        'assignments': assignments.map((a) => a.toJson()).toList(),
      };

  factory Course.fromJson(Map<String, dynamic> json) => Course(
        id: json['id'] as String,
        name: json['name'] as String? ?? 'Course',
        code: json['code'] as String? ?? '',
        colorIndex: json['colorIndex'] as int? ?? 0,
        credits: (json['credits'] as num?)?.toDouble() ?? 3,
        assignments: (json['assignments'] as List<dynamic>? ?? [])
            .map((e) => Assignment.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );
}

class GradeSnapshot {
  static double semesterGpa(List<Course> courses) {
    var num = 0.0;
    var den = 0.0;
    for (final c in courses) {
      if (c.scoredWeight <= 0) continue;
      num += c.currentGpa * c.credits;
      den += c.credits;
    }
    if (den <= 0) return 0;
    return num / den;
  }

  static double semesterGpaIfFinal(List<Course> courses, String courseId, double finalScore) {
    var num = 0.0;
    var den = 0.0;
    for (final c in courses) {
      final pct = c.id == courseId ? c.percentWithFinal(finalScore) : c.currentPercent;
      if (c.id != courseId && c.scoredWeight <= 0) continue;
      if (c.id == courseId && c.assignments.isEmpty) continue;
      num += GpaMath.gpaFor(pct) * c.credits;
      den += c.credits;
    }
    if (den <= 0) return 0;
    return num / den;
  }

  /// Lowest final % that lifts semester GPA to [goal]. Null if impossible even at 100.
  static double? requiredFinalForGoal(List<Course> courses, Course focus, double goal) {
    final exam = focus.finalExam;
    if (exam == null || exam.weight <= 0) return null;
    bool ok(double f) => semesterGpaIfFinal(courses, focus.id, f) + 1e-6 >= goal;
    if (ok(0)) return 0;
    if (!ok(100)) return null;
    var lo = 0.0;
    var hi = 100.0;
    for (var i = 0; i < 28; i++) {
      final mid = (lo + hi) / 2;
      if (ok(mid)) {
        hi = mid;
      } else {
        lo = mid;
      }
    }
    return hi;
  }
}
