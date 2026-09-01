import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import '../constants/hive_boxes.dart';
import '../models/review_schedule.dart';
import 'hive_helpers.dart';

/// 復習スケジュール(間隔反復)の保存・取得を行うRepository。
///
/// 1問につき1件のレコードを持ち、questionIdをキーとして保存する。
class ReviewScheduleRepository {
  Box get _box => Hive.box(HiveBoxes.reviewSchedules);

  Future<void> upsert(ReviewSchedule schedule) async {
    await _box.put(schedule.questionId, schedule.toJson());
  }

  ReviewSchedule? getByQuestion(String questionId) {
    final raw = _box.get(questionId);
    return raw == null ? null : ReviewSchedule.fromJson(asStringKeyedMap(raw));
  }

  List<ReviewSchedule> getAll() {
    return _box.values
        .map((e) => ReviewSchedule.fromJson(asStringKeyedMap(e)))
        .toList();
  }

  /// 指定日時までに復習予定日が来ている問題のスケジュール一覧
  /// (asOfを省略すると「今日まで」を対象にする)
  List<ReviewSchedule> getDue({DateTime? asOf}) {
    final cutoff = asOf ?? DateTime.now();
    final endOfCutoffDay = DateTime(cutoff.year, cutoff.month, cutoff.day, 23, 59, 59);
    return getAll().where((s) => !s.dueDate.isAfter(endOfCutoffDay)).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }
}
