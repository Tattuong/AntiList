class LetterGrade {
  final String letter;
  final double gpa;
  final double minPercent;

  const LetterGrade(this.letter, this.gpa, this.minPercent);
}

class GpaMath {
  GpaMath._();

  static const List<LetterGrade> scale = [
    LetterGrade('A', 4.0, 90),
    LetterGrade('A-', 3.67, 87),
    LetterGrade('B+', 3.33, 83),
    LetterGrade('B', 3.0, 80),
    LetterGrade('B-', 2.67, 77),
    LetterGrade('C+', 2.33, 73),
    LetterGrade('C', 2.0, 70),
    LetterGrade('C-', 1.67, 67),
    LetterGrade('D+', 1.33, 63),
    LetterGrade('D', 1.0, 60),
    LetterGrade('F', 0, 0),
  ];

  static LetterGrade letterFor(double percent) {
    for (final row in scale) {
      if (percent + 1e-9 >= row.minPercent) return row;
    }
    return scale.last;
  }

  static double gpaFor(double percent) => letterFor(percent).gpa;

  static String letterLabel(double percent) => letterFor(percent).letter;

  static LetterGrade? letterAbove(double percent) {
    final letter = letterFor(percent).letter;
    final i = scale.indexWhere((e) => e.letter == letter);
    if (i <= 0) return null;
    return scale[i - 1];
  }

  static double? requiredScore({
    required double earnedPoints,
    required double scoredWeight,
    required double remainingWeight,
    required double targetPercent,
  }) {
    if (remainingWeight <= 0) return null;
    final total = scoredWeight + remainingWeight;
    final need = targetPercent * total / 100 - earnedPoints;
    return (need / remainingWeight) * 100;
  }

  static double clampScore(double v) => v.clamp(0, 150).toDouble();
}
