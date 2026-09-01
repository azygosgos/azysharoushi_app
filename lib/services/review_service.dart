import '../models/enums.dart';
import '../models/review_schedule.dart';

/// 忘却曲線を意識した間隔反復(スペースドリピティション)のロジック。
///
/// UIやHiveの知識を一切持たない「純粋なDartクラス」にしているので、
/// Flutterを起動しなくても `flutter test` だけで動作確認できます。
/// 復習間隔の決め方を変えたくなったら、基本的にこのファイルだけを直せばOKです。
class ReviewService {
  /// 初期の復習間隔(日数)のステップ。
  /// 例: 1日後 → 3日後 → 7日後 → 14日後 → 30日後
  static const List<int> intervalStepsDays = [1, 3, 7, 14, 30];

  /// 「難しい」と評価されたときの短い再出題間隔(日数)。
  static const int hardIntervalDays = 2;

  /// 不正解のときの再出題間隔(日数) = 原則翌日。
  static const int incorrectIntervalDays = 1;

  /// 回答結果から、次回の復習スケジュールを計算する。
  ///
  /// [current] はこれまでの復習スケジュール(初回answeredならnull)。
  /// [now] は基準日時(テスト時は固定の日時を渡せる)。
  ReviewSchedule computeNext({
    required String questionId,
    required ReviewSchedule? current,
    required bool isCorrect,
    required Understanding understanding,
    required DateTime now,
  }) {
    final currentRepetition = current?.repetition ?? -1;
    int nextRepetition;
    int intervalDays;

    if (!isCorrect) {
      // 不正解 → 原則翌日など、短期間で再出題する。
      nextRepetition = 0;
      intervalDays = incorrectIntervalDays;
    } else {
      switch (understanding) {
        case Understanding.hard:
          // 正解したが「難しい」→ ステップは進めず、短い間隔で再出題。
          nextRepetition = currentRepetition < 0 ? 0 : currentRepetition;
          intervalDays = hardIntervalDays;
          break;
        case Understanding.normal:
          // 正解+「普通」→ 標準的に1ステップ進める。
          nextRepetition = currentRepetition + 1;
          intervalDays = _intervalForStep(nextRepetition);
          break;
        case Understanding.easy:
          // 正解+「余裕」→ 2ステップ分進めて、間隔を大きく伸ばす。
          nextRepetition = currentRepetition + 2;
          intervalDays = _intervalForStep(nextRepetition);
          break;
      }
    }

    final today = DateTime(now.year, now.month, now.day);
    final dueDate = today.add(Duration(days: intervalDays));

    return ReviewSchedule(
      questionId: questionId,
      dueDate: dueDate,
      intervalDays: intervalDays,
      repetition: nextRepetition,
      updatedAt: now,
    );
  }

  /// ステップ番号(0始まり)から復習間隔(日数)を求める。
  /// ステップが intervalStepsDays の範囲を超えたら、
  /// 最後の間隔(30日)を基準に少しずつ伸ばす(最大90日でストップ)。
  int _intervalForStep(int step) {
    if (step < 0) {
      return intervalStepsDays.first;
    }
    if (step < intervalStepsDays.length) {
      return intervalStepsDays[step];
    }
    final overSteps = step - (intervalStepsDays.length - 1);
    final extended = intervalStepsDays.last + overSteps * 15;
    return extended > 90 ? 90 : extended;
  }
}
