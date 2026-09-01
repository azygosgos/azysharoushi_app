import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import '../constants/hive_boxes.dart';

/// お気に入り問題の登録/解除を行うRepository。
/// (questionIdをキーに、true を保存しているだけのシンプルな実装)
class FavoriteRepository {
  Box get _box => Hive.box(HiveBoxes.favorites);

  bool isFavorite(String questionId) {
    return _box.get(questionId, defaultValue: false) as bool;
  }

  Future<void> toggle(String questionId) async {
    final current = isFavorite(questionId);
    if (current) {
      await _box.delete(questionId);
    } else {
      await _box.put(questionId, true);
    }
  }

  Set<String> getAllFavoriteIds() {
    return _box.keys.map((k) => k as String).toSet();
  }
}
