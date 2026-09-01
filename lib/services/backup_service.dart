import '../models/attempt.dart';
import '../models/note.dart';
import '../models/review_schedule.dart';
import '../repositories/attempt_repository.dart';
import '../repositories/favorite_repository.dart';
import '../repositories/note_repository.dart';
import '../repositories/review_schedule_repository.dart';

/// 学習履歴・復習予定・メモ・お気に入りを、JSONとしてエクスポート/インポートするサービス。
///
/// 【Phase1時点の状態】
/// ロジックは実装済みですが、まだ画面にボタンを設置していません
/// (「バックアップを作成」「バックアップから復元」ボタンはPhase2以降で追加予定)。
/// 動作確認したい場合は、このクラスのメソッドを直接呼び出してください。
class BackupService {
  BackupService({
    required this.attemptRepository,
    required this.reviewScheduleRepository,
    required this.noteRepository,
    required this.favoriteRepository,
  });

  final AttemptRepository attemptRepository;
  final ReviewScheduleRepository reviewScheduleRepository;
  final NoteRepository noteRepository;
  final FavoriteRepository favoriteRepository;

  /// バックアップファイルの形式バージョン。
  /// 保存する項目を変えたら、この数字を+1してください。
  static const int backupFormatVersion = 1;

  /// 学習データを1つのMapにまとめる。
  /// jsonEncode(exportData()) でファイルに書き出せる形になる。
  Map<String, dynamic> exportData() {
    return {
      'backupFormatVersion': backupFormatVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'attempts': attemptRepository.getAll().map((a) => a.toJson()).toList(),
      'reviewSchedules':
          reviewScheduleRepository.getAll().map((s) => s.toJson()).toList(),
      'notes': noteRepository.getAll().map((n) => n.toJson()).toList(),
      'favoriteQuestionIds': favoriteRepository.getAllFavoriteIds().toList(),
    };
  }

  /// exportData()で作った内容から、学習データを復元する。
  /// (すでに保存済みのデータは、同じIDのものが上書きされます)
  Future<void> importData(Map<String, dynamic> data) async {
    final attempts = (data['attempts'] as List<dynamic>? ?? [])
        .map((e) => Attempt.fromJson(e as Map<String, dynamic>));
    for (final attempt in attempts) {
      await attemptRepository.add(attempt);
    }

    final schedules = (data['reviewSchedules'] as List<dynamic>? ?? [])
        .map((e) => ReviewSchedule.fromJson(e as Map<String, dynamic>));
    for (final schedule in schedules) {
      await reviewScheduleRepository.upsert(schedule);
    }

    final notes = (data['notes'] as List<dynamic>? ?? [])
        .map((e) => Note.fromJson(e as Map<String, dynamic>));
    for (final note in notes) {
      await noteRepository.upsert(note);
    }

    final favoriteIds = (data['favoriteQuestionIds'] as List<dynamic>? ?? []);
    for (final rawId in favoriteIds) {
      final id = rawId as String;
      if (!favoriteRepository.isFavorite(id)) {
        await favoriteRepository.toggle(id);
      }
    }
  }
}
