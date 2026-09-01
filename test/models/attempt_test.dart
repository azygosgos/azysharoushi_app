import 'package:flutter_test/flutter_test.dart';
import 'package:sharoushi_app/models/attempt.dart';
import 'package:sharoushi_app/models/enums.dart';

void main() {
  test('Attemptの日時(DateTime)がJSON化・復元しても同じ日時になる', () {
    final now = DateTime(2026, 8, 27, 21, 30, 15);
    final attempt = Attempt(
      id: 'a1',
      questionId: 'q001',
      answeredAt: now,
      userAnswer: 'true',
      isCorrect: true,
      understanding: Understanding.easy,
      durationSeconds: 12,
      reviewCount: 1,
    );

    final restored = Attempt.fromJson(attempt.toJson());

    expect(restored.answeredAt, now);
    expect(restored.isCorrect, isTrue);
    expect(restored.understanding, Understanding.easy);
    expect(restored.durationSeconds, 12);
  });
}
