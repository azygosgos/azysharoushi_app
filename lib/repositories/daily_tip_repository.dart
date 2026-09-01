import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import '../constants/hive_boxes.dart';
import '../models/daily_tip.dart';
import 'hive_helpers.dart';

/// 「今日のワンポイント学習」データへのアクセス。
class DailyTipRepository {
  List<DailyTip> getAll() {
    final box = Hive.box(HiveBoxes.dailyTips);
    return box.values
        .map((e) => DailyTip.fromJson(asStringKeyedMap(e)))
        .toList();
  }

  DailyTip? getById(String id) {
    final box = Hive.box(HiveBoxes.dailyTips);
    final raw = box.get(id);
    return raw == null ? null : DailyTip.fromJson(asStringKeyedMap(raw));
  }
}
