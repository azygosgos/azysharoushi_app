import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/question.dart';
import 'repository_providers.dart';

/// 問題一覧画面の絞り込み条件。
/// Phase1では最低限の4種類のみ対応(将来ここに条件を追加していく)。
enum QuestionFilter {
  all,
  unanswered,
  incorrect,
  review,
}

extension QuestionFilterLabel on QuestionFilter {
  String get label {
    switch (this) {
      case QuestionFilter.all:
        return '全問題';
      case QuestionFilter.unanswered:
        return '未回答';
      case QuestionFilter.incorrect:
        return '不正解';
      case QuestionFilter.review:
        return '復習対象';
    }
  }
}

/// family provider(引数付きprovider)に渡す引数をまとめたクラス。
/// Riverpodのfamilyでキャッシュを正しく効かせるため、== とhashCodeを実装している。
class QuestionListArgs {
  final String subjectId;
  final QuestionFilter filter;

  const QuestionListArgs({required this.subjectId, required this.filter});

  @override
  bool operator ==(Object other) =>
      other is QuestionListArgs &&
      other.subjectId == subjectId &&
      other.filter == filter;

  @override
  int get hashCode => Object.hash(subjectId, filter);
}

/// 絞り込み済みの問題一覧を返すProvider。
final filteredQuestionsProvider =
    Provider.family<List<Question>, QuestionListArgs>((ref, args) {
  // dataRevisionProviderを監視することで、回答保存後などに再計算される。
  ref.watch(dataRevisionProvider);

  final allQuestions =
      ref.watch(questionRepositoryProvider).getBySubject(args.subjectId);
  final attemptRepo = ref.watch(attemptRepositoryProvider);

  switch (args.filter) {
    case QuestionFilter.all:
      return allQuestions;
    case QuestionFilter.unanswered:
      final answeredIds = attemptRepo.answeredQuestionIds();
      return allQuestions.where((q) => !answeredIds.contains(q.id)).toList();
    case QuestionFilter.incorrect:
      final incorrectIds = attemptRepo.incorrectQuestionIds();
      return allQuestions.where((q) => incorrectIds.contains(q.id)).toList();
    case QuestionFilter.review:
      final dueIds = ref
          .watch(reviewScheduleRepositoryProvider)
          .getDue()
          .map((s) => s.questionId)
          .toSet();
      return allQuestions.where((q) => dueIds.contains(q.id)).toList();
  }
});

/// IDを指定して1問だけ取得するProvider(問題画面で使用)。
final questionByIdProvider = Provider.family<Question?, String>((ref, id) {
  ref.watch(dataRevisionProvider);
  return ref.watch(questionRepositoryProvider).getById(id);
});
