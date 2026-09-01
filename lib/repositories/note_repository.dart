import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import '../constants/hive_boxes.dart';
import '../models/enums.dart';
import '../models/note.dart';
import 'hive_helpers.dart';

/// 問題・条文へのメモの保存/取得/検索を行うRepository。
class NoteRepository {
  Box get _box => Hive.box(HiveBoxes.notes);

  Future<void> upsert(Note note) async {
    await _box.put(note.id, note.toJson());
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  List<Note> getAll() {
    return _box.values.map((e) => Note.fromJson(asStringKeyedMap(e))).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  /// 特定の問題/条文に紐づくメモ (1つの対象に複数メモを許可する)
  List<Note> getByTarget(NoteTargetType type, String targetId) {
    return getAll()
        .where((n) => n.targetType == type && n.targetId == targetId)
        .toList();
  }

  /// メモ本文をキーワード検索する (メモ一覧画面用)
  List<Note> search(String keyword) {
    if (keyword.trim().isEmpty) return getAll();
    final lower = keyword.toLowerCase();
    return getAll().where((n) => n.content.toLowerCase().contains(lower)).toList();
  }
}
