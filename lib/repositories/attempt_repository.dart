import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import '../constants/hive_boxes.dart';
import '../models/attempt.dart';
import 'hive_helpers.dart';

/// 回答履歴(学習履歴)の保存・取得を行うRepository。
class AttemptRepository {
  Box get _box => Hive.box(HiveBoxes.attempts);

  /// 回答を1件保存する。
  Future<void> add(Attempt attempt) async {
    await _box.put(attempt.id, attempt.toJson());
  }

  List<Attempt> getAll() {
    return _box.values
        .map((e) => Attempt.fromJson(asStringKeyedMap(e)))
        .toList()
      ..sort((a, b) => b.answeredAt.compareTo(a.answeredAt));
  }

  /// 指定した問題の回答履歴を、新しい順で返す。
  List<Attempt> getByQuestion(String questionId) {
    return getAll().where((a) => a.questionId == questionId).toList();
  }

  /// 指定日時以降の回答履歴を返す (学習履歴の期間集計に使用)。
  List<Attempt> getSince(DateTime since) {
    return getAll().where((a) => !a.answeredAt.isBefore(since)).toList();
  }

  /// 今日回答した件数
  int countToday() {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    return getSince(startOfToday).length;
  }

  /// すでに一度でも回答したことがある問題IDの集合
  Set<String> answeredQuestionIds() {
    return getAll().map((a) => a.questionId).toSet();
  }

  /// 「直近の回答が不正解」だった問題IDの集合 (簡易的な苦手問題判定)
  Set<String> incorrectQuestionIds() {
    final latestByQuestion = <String, Attempt>{};
    // getAll()は新しい順なので、最初に出てきたものが最新の回答。
    for (final a in getAll()) {
      latestByQuestion.putIfAbsent(a.questionId, () => a);
    }
    return latestByQuestion.values
        .where((a) => !a.isCorrect)
        .map((a) => a.questionId)
        .toSet();
  }
}
