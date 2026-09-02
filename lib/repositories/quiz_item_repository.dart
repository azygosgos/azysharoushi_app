import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import '../constants/hive_boxes.dart';
import '../models/quiz_item.dart';
import 'hive_helpers.dart';

/// 〇×クイズデータへのアクセス。
///
/// 教材データなので基本的に読み取り専用。
class QuizItemRepository {
  List<QuizItem> getAll() {
    final box = Hive.box(HiveBoxes.quizItems);
    return box.values
        .map((e) => QuizItem.fromJson(asStringKeyedMap(e)))
        .toList();
  }

  List<QuizItem> getBySubject(String? subjectId) {
    final all = getAll();
    if (subjectId == null) return all;
    return all.where((item) => item.subjectId == subjectId).toList();
  }
}
