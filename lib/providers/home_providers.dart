import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/daily_tip.dart';
import 'repository_providers.dart';

/// 1日の学習目標問題数のデフォルト値。
/// (Phase1には目標を変更する設定画面がないため、まずは固定値)
const int kDefaultDailyGoal = 10;

/// ホーム画面に表示する集計値。
class HomeStats {
  final int todayReviewCount; // 今日の復習問題数
  final int todayAnsweredCount; // 今日解いた問題数
  final int dailyGoal; // 今日の学習目標
  final double? recentAccuracy; // 直近の正答率(0.0〜1.0、データがなければnull)

  const HomeStats({
    required this.todayReviewCount,
    required this.todayAnsweredCount,
    required this.dailyGoal,
    required this.recentAccuracy,
  });
}

final homeStatsProvider = Provider<HomeStats>((ref) {
  ref.watch(dataRevisionProvider);

  final attemptRepo = ref.watch(attemptRepositoryProvider);
  final reviewRepo = ref.watch(reviewScheduleRepositoryProvider);

  final todayReviewCount = reviewRepo.getDue().length;
  final todayAnsweredCount = attemptRepo.countToday();

  // 直近20件の回答から正答率を計算する(シンプルな実装)。
  final recentAttempts = attemptRepo.getAll().take(20).toList();
  double? accuracy;
  if (recentAttempts.isNotEmpty) {
    final correctCount = recentAttempts.where((a) => a.isCorrect).length;
    accuracy = correctCount / recentAttempts.length;
  }

  return HomeStats(
    todayReviewCount: todayReviewCount,
    todayAnsweredCount: todayAnsweredCount,
    dailyGoal: kDefaultDailyGoal,
    recentAccuracy: accuracy,
  );
});

/// 今日の「今日のワンポイント学習」の内容(表示するかどうかは画面側で判定する)。
final todayTipProvider = Provider<DailyTip?>((ref) {
  final service = ref.watch(dailyTipServiceProvider);
  return service.pickForToday(DateTime.now());
});
