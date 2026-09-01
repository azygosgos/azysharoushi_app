import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/attempt_repository.dart';
import '../repositories/daily_tip_repository.dart';
import '../repositories/favorite_repository.dart';
import '../repositories/note_repository.dart';
import '../repositories/question_repository.dart';
import '../repositories/reference_repository.dart';
import '../repositories/review_schedule_repository.dart';
import '../services/backup_service.dart';
import '../services/daily_tip_service.dart';
import '../services/review_service.dart';

/// Repository / Service のインスタンスをアプリ全体で共有するためのProvider集。
///
/// 【ポイント】
/// 画面のコードは、Hiveのことを直接知る必要はありません。
/// 必ずこのファイルのProvider経由でRepositoryを使ってください。
/// 将来、保存方法をHiveから別の方式に変えるときも、
/// 実装を差し替えるのはこのファイル + repositories/ フォルダだけで済みます。

final referenceRepositoryProvider = Provider<ReferenceRepository>((ref) {
  return ReferenceRepository();
});

final questionRepositoryProvider = Provider<QuestionRepository>((ref) {
  return QuestionRepository();
});

final attemptRepositoryProvider = Provider<AttemptRepository>((ref) {
  return AttemptRepository();
});

final favoriteRepositoryProvider = Provider<FavoriteRepository>((ref) {
  return FavoriteRepository();
});

final reviewScheduleRepositoryProvider = Provider<ReviewScheduleRepository>((ref) {
  return ReviewScheduleRepository();
});

final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  return NoteRepository();
});

final dailyTipRepositoryProvider = Provider<DailyTipRepository>((ref) {
  return DailyTipRepository();
});

final reviewServiceProvider = Provider<ReviewService>((ref) {
  return ReviewService();
});

final dailyTipServiceProvider = Provider<DailyTipService>((ref) {
  return DailyTipService(ref.watch(dailyTipRepositoryProvider));
});

final backupServiceProvider = Provider<BackupService>((ref) {
  return BackupService(
    attemptRepository: ref.watch(attemptRepositoryProvider),
    reviewScheduleRepository: ref.watch(reviewScheduleRepositoryProvider),
    noteRepository: ref.watch(noteRepositoryProvider),
    favoriteRepository: ref.watch(favoriteRepositoryProvider),
  );
});

/// 何かデータが更新された(回答した・メモを保存した等)ときにこの値を+1することで、
/// ホーム画面や一覧画面など「Hiveから再計算して表示している」Providerたちに
/// 再計算のタイミングを知らせるための、シンプルな仕組み。
///
/// (RiverpodでHiveの変更を自動検知する高度な方法もありますが、
/// 初心者にも仕組みが追いやすいよう、あえてこの単純な方式にしています)
final dataRevisionProvider = StateProvider<int>((ref) => 0);

/// データ更新後に呼び出すヘルパー。
/// 例: ref.read(bumpDataRevisionProvider)();
void bumpDataRevision(WidgetRef ref) {
  ref.read(dataRevisionProvider.notifier).state++;
}
