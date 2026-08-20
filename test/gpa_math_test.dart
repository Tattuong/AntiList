import 'package:flutter_test/flutter_test.dart';
import 'package:grademate/core/calc/gpa_math.dart';
import 'package:grademate/models/course.dart';

void main() {
  test('letter scale maps 89.2 to A-', () {
    expect(GpaMath.letterLabel(89.2), 'A-');
    expect(GpaMath.gpaFor(89.2), 3.67);
  });

  test('current percent ignores blank final', () {
    const c = Course(
      id: 'c1',
      name: 'Data Structures',
      code: 'CS 201',
      colorIndex: 0,
      assignments: [
        Assignment(id: 'a1', name: 'Homework 1', weight: 5, score: 95),
        Assignment(id: 'a2', name: 'Lab 2', weight: 10, score: 90),
        Assignment(id: 'a3', name: 'Midterm Exam', weight: 30, score: 89),
        Assignment(id: 'a4', name: 'Quizzes', weight: 25, score: 88),
        Assignment(id: 'a5', name: 'Final Exam', weight: 30, isFinal: true),
      ],
    );
    expect(c.currentPercent, closeTo(89.21, 0.05));
  });

  test('required final lifts semester GPA', () {
    const ds = Course(
      id: 'c1',
      name: 'DS',
      code: 'CS',
      colorIndex: 0,
      assignments: [
        Assignment(id: 'a1', name: 'HW', weight: 70, score: 89),
        Assignment(id: 'a2', name: 'Final', weight: 30, isFinal: true),
      ],
    );
    const other = Course(
      id: 'c2',
      name: 'EN',
      code: 'EN',
      colorIndex: 1,
      assignments: [Assignment(id: 'b1', name: 'All', weight: 100, score: 91)],
    );
    final need = GradeSnapshot.requiredFinalForGoal([ds, other], ds, 3.5);
    expect(need, isNotNull);
    expect(need!, inInclusiveRange(0, 100));
    expect(GradeSnapshot.semesterGpaIfFinal([ds, other], ds.id, need), greaterThanOrEqualTo(3.5 - 0.02));
  });

  test('cushion for remaining work to keep A-', () {
    const c = Course(
      id: 'c1',
      name: 'DS',
      code: 'CS',
      colorIndex: 0,
      assignments: [
        Assignment(id: 'a1', name: 'Done', weight: 70, score: 89.21),
        Assignment(id: 'a2', name: 'Final', weight: 30, isFinal: true),
      ],
    );
    final need = c.remainingNeededFor(87);
    expect(need, isNotNull);
    expect(need!, closeTo(81.84, 0.2));
  });
}
