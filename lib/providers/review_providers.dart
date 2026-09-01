import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/question.dart';
import 'repository_providers.dart';

/// 「今日の復習」対象の問題一覧。
/// (復習スケジュールのdueDateが今日以前になっている問題)
final todayReviewQuestionsProvider = Provider<List<Question>>((ref) {
  ref.watch(dataRevisionProvider);

  final dueSchedules = ref.watch(reviewScheduleRepositoryProvider).getDue();
  final questionRepo = ref.watch(questionRepositoryProvider);

  return dueSchedules
      .map((schedule) => questionRepo.getById(schedule.questionId))
      .whereType<Question>()
      .toList();
});
