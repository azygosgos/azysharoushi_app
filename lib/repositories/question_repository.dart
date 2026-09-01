import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import '../constants/hive_boxes.dart';
import '../models/question.dart';
import 'hive_helpers.dart';

/// 問題データ(過去問・オリジナル問題)へのアクセス。
///
/// 教材データなので基本的に読み取り専用。
/// (問題の中身自体をアプリ内で編集する機能はPhase1にはありません)
class QuestionRepository {
  List<Question> getAll() {
    final box = Hive.box(HiveBoxes.questions);
    return box.values
        .map((e) => Question.fromJson(asStringKeyedMap(e)))
        .toList();
  }

  Question? getById(String id) {
    final box = Hive.box(HiveBoxes.questions);
    final raw = box.get(id);
    return raw == null ? null : Question.fromJson(asStringKeyedMap(raw));
  }

  List<Question> getBySubject(String subjectId) {
    return getAll().where((q) => q.subjectId == subjectId).toList();
  }
}
