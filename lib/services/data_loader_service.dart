import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/hive_boxes.dart';

/// assets/data/*.json の教材データを、初回起動時(またはデータ更新時)に
/// Hiveへ読み込むサービス。
///
/// 【問題データを追加・修正したいとき】
/// 1. assets/data/questions.json 等を編集する
/// 2. このファイルの [currentDataVersion] の数字を1つ増やす
///    (これをしないと、次回起動時に新しいデータが反映されません)
class DataLoaderService {
  /// データを変更したら、この数字を必ず+1してください。
  static const int currentDataVersion = 40;

  Future<void> loadIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final savedVersion = prefs.getInt(PrefKeys.dataVersion) ?? 0;

    if (savedVersion == currentDataVersion) {
      // すでに最新バージョンのデータが読み込み済みなので何もしない。
      return;
    }

    await _loadJsonIntoBox('assets/data/subjects.json', HiveBoxes.subjects);
    await _loadJsonIntoBox('assets/data/sources.json', HiveBoxes.sources);
    await _loadJsonIntoBox('assets/data/topics.json', HiveBoxes.topics);
    await _loadJsonIntoBox('assets/data/laws.json', HiveBoxes.laws);
    await _loadJsonIntoBox('assets/data/articles.json', HiveBoxes.articles);
    await _loadJsonIntoBox('assets/data/questions.json', HiveBoxes.questions);
    await _loadJsonIntoBox('assets/data/quiz_items.json', HiveBoxes.quizItems);
    await _loadJsonIntoBox('assets/data/daily_tips.json', HiveBoxes.dailyTips);

    await prefs.setInt(PrefKeys.dataVersion, currentDataVersion);
  }

  /// 1つのJSONファイル(配列)を読み込み、各要素の"id"をキーとしてBoxへ保存する。
  Future<void> _loadJsonIntoBox(String assetPath, String boxName) async {
    final jsonString = await rootBundle.loadString(assetPath);
    final List<dynamic> list = jsonDecode(jsonString) as List<dynamic>;
    final box = Hive.box(boxName);

    // 教材データは「読み込み直し」が前提なので、一度空にしてから入れ直す。
    await box.clear();

    final Map<String, dynamic> entries = {
      for (final item in list) (item as Map<String, dynamic>)['id'] as String: item,
    };
    await box.putAll(entries);
  }
}
