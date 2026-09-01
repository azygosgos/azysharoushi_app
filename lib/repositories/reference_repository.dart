import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import '../constants/hive_boxes.dart';
import '../models/article.dart';
import '../models/law.dart';
import '../models/source.dart';
import '../models/subject.dart';
import '../models/topic.dart';
import 'hive_helpers.dart';

/// 「教材の元データ」(科目・論点・法律・条文・出典)へのアクセスをまとめたRepository。
///
/// これらはユーザーが編集するデータではなく、assets/data/*.json から
/// DataLoaderServiceによって読み込まれる「読み取り専用」のデータなので、
/// 1つのRepositoryにまとめてシンプルにしています。
class ReferenceRepository {
  List<Subject> getSubjects() {
    final box = Hive.box(HiveBoxes.subjects);
    return box.values
        .map((e) => Subject.fromJson(asStringKeyedMap(e)))
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  List<Topic> getTopics() {
    final box = Hive.box(HiveBoxes.topics);
    return box.values.map((e) => Topic.fromJson(asStringKeyedMap(e))).toList();
  }

  Topic? getTopicById(String id) {
    final box = Hive.box(HiveBoxes.topics);
    final raw = box.get(id);
    return raw == null ? null : Topic.fromJson(asStringKeyedMap(raw));
  }

  List<Law> getLaws() {
    final box = Hive.box(HiveBoxes.laws);
    return box.values.map((e) => Law.fromJson(asStringKeyedMap(e))).toList();
  }

  List<Article> getArticlesByLaw(String lawId) {
    final box = Hive.box(HiveBoxes.articles);
    return box.values
        .map((e) => Article.fromJson(asStringKeyedMap(e)))
        .where((a) => a.lawId == lawId)
        .toList();
  }

  Article? getArticleById(String id) {
    final box = Hive.box(HiveBoxes.articles);
    final raw = box.get(id);
    return raw == null ? null : Article.fromJson(asStringKeyedMap(raw));
  }

  List<Source> getSources() {
    final box = Hive.box(HiveBoxes.sources);
    return box.values.map((e) => Source.fromJson(asStringKeyedMap(e))).toList();
  }

  Source? getSourceById(String id) {
    final box = Hive.box(HiveBoxes.sources);
    final raw = box.get(id);
    return raw == null ? null : Source.fromJson(asStringKeyedMap(raw));
  }
}
