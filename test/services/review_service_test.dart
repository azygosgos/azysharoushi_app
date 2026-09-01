import 'package:flutter_test/flutter_test.dart';
import 'package:sharoushi_app/models/enums.dart';
import 'package:sharoushi_app/models/review_schedule.dart';
import 'package:sharoushi_app/services/review_service.dart';

void main() {
  final service = ReviewService();
  final baseDate = DateTime(2026, 1, 10); // テスト用の固定日付(金曜日など気にしなくてよい)

  group('ReviewService.computeNext', () {
    test('初めて不正解のとき: repetition=0, 翌日(1日後)に設定される', () {
      final result = service.computeNext(
        questionId: 'q1',
        current: null,
        isCorrect: false,
        understanding: Understanding.normal,
        now: baseDate,
      );

      expect(result.repetition, 0);
      expect(result.intervalDays, ReviewService.incorrectIntervalDays);
      expect(result.dueDate, baseDate.add(const Duration(days: 1)));
    });

    test('既に間隔が進んでいても、不正解なら repetition=0 にリセットされる', () {
      final current = ReviewSchedule(
        questionId: 'q1',
        dueDate: baseDate,
        intervalDays: 14,
        repetition: 3,
        updatedAt: baseDate,
      );

      final result = service.computeNext(
        questionId: 'q1',
        current: current,
        isCorrect: false,
        understanding: Understanding.hard,
        now: baseDate,
      );

      expect(result.repetition, 0);
      expect(result.intervalDays, 1);
    });

    test('初めて正解+普通: 最初のステップ(1日後)になる', () {
      final result = service.computeNext(
        questionId: 'q1',
        current: null,
        isCorrect: true,
        understanding: Understanding.normal,
        now: baseDate,
      );

      expect(result.repetition, 0);
      expect(result.intervalDays, ReviewService.intervalStepsDays[0]); // 1日
    });

    test('初めて正解+余裕: 2ステップ進んで3日後になる', () {
      final result = service.computeNext(
        questionId: 'q1',
        current: null,
        isCorrect: true,
        understanding: Understanding.easy,
        now: baseDate,
      );

      expect(result.repetition, 1);
      expect(result.intervalDays, ReviewService.intervalStepsDays[1]); // 3日
    });

    test('正解+難しい: ステップは進まず、短い間隔(hardIntervalDays)になる', () {
      final current = ReviewSchedule(
        questionId: 'q1',
        dueDate: baseDate,
        intervalDays: 7,
        repetition: 2,
        updatedAt: baseDate,
      );

      final result = service.computeNext(
        questionId: 'q1',
        current: current,
        isCorrect: true,
        understanding: Understanding.hard,
        now: baseDate,
      );

      expect(result.repetition, 2); // ステップは変わらない
      expect(result.intervalDays, ReviewService.hardIntervalDays);
    });

    test('途中(repetition=2, 7日)から正解+普通: 次のステップ(14日)に進む', () {
      final current = ReviewSchedule(
        questionId: 'q1',
        dueDate: baseDate,
        intervalDays: 7,
        repetition: 2,
        updatedAt: baseDate,
      );

      final result = service.computeNext(
        questionId: 'q1',
        current: current,
        isCorrect: true,
        understanding: Understanding.normal,
        now: baseDate,
      );

      expect(result.repetition, 3);
      expect(result.intervalDays, ReviewService.intervalStepsDays[3]); // 14日
    });

    test('最後のステップ(30日)を超えて正解+余裕を繰り返すと、間隔は伸び続け90日で頭打ちになる', () {
      final current = ReviewSchedule(
        questionId: 'q1',
        dueDate: baseDate,
        intervalDays: 30,
        repetition: 4, // intervalStepsDaysの最後(index=4, 30日)
        updatedAt: baseDate,
      );

      final result = service.computeNext(
        questionId: 'q1',
        current: current,
        isCorrect: true,
        understanding: Understanding.easy,
        now: baseDate,
      );

      // repetition=4+2=6 → 配列の範囲外 → 30 + (6-4)*15 = 60日
      expect(result.repetition, 6);
      expect(result.intervalDays, 60);
      expect(result.intervalDays <= 90, isTrue);
    });
  });
}
