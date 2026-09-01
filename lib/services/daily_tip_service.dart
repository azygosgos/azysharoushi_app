import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/hive_boxes.dart';
import '../models/daily_tip.dart';
import '../repositories/daily_tip_repository.dart';

/// 「今日のワンポイント学習」を1日1回だけ表示するためのロジック。
class DailyTipService {
  DailyTipService(this._repository);

  final DailyTipRepository _repository;
  static final DateFormat _dayFormat = DateFormat('yyyy-MM-dd');

  /// 今日の日付から、決定的に(同じ日は必ず同じ内容になるように)1件選ぶ。
  DailyTip? pickForToday(DateTime now) {
    final tips = _repository.getAll();
    if (tips.isEmpty) return null;
    // 年始からの通算日数のようなものを作って、tipsの数で割った余りを使う。
    final dayOfEpoch = now.difference(DateTime(2024, 1, 1)).inDays;
    final index = dayOfEpoch % tips.length;
    return tips[index < 0 ? 0 : index];
  }

  /// 今日まだ表示していなければtrue。
  Future<bool> shouldShowToday(DateTime now) async {
    final prefs = await SharedPreferences.getInstance();
    final lastShown = prefs.getString(PrefKeys.lastTipShownDate);
    return lastShown != _dayFormat.format(now);
  }

  /// 「今日はもう表示した」ことを記録する。
  Future<void> markShownToday(DateTime now) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PrefKeys.lastTipShownDate, _dayFormat.format(now));
  }
}
