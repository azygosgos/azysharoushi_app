import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/attempt.dart';
import '../providers/question_providers.dart';
import '../providers/repository_providers.dart';
import 'question_screen.dart';

/// 過去問演習: 問題一覧画面。
///
/// Phase1では絞り込みを「全問題 / 未回答 / 不正解 / 復習対象」の4種類のみに
/// しています(年度別・論点別・お気に入り等は今後追加予定)。
class QuestionListScreen extends ConsumerStatefulWidget {
  final String subjectId;
  final String subjectName;

  const QuestionListScreen({
    super.key,
    required this.subjectId,
    required this.subjectName,
  });

  @override
  ConsumerState<QuestionListScreen> createState() => _QuestionListScreenState();
}

class _QuestionListScreenState extends ConsumerState<QuestionListScreen> {
  QuestionFilter _filter = QuestionFilter.all;

  @override
  Widget build(BuildContext context) {
    final questions = ref.watch(
      filteredQuestionsProvider(
        QuestionListArgs(subjectId: widget.subjectId, filter: _filter),
      ),
    );
    final attemptRepo = ref.watch(attemptRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: Text('${widget.subjectName} 問題一覧')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Wrap(
              spacing: 8,
              children: QuestionFilter.values.map((f) {
                return ChoiceChip(
                  label: Text(f.label),
                  selected: _filter == f,
                  onSelected: (_) => setState(() => _filter = f),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: questions.isEmpty
                ? const Center(child: Text('該当する問題がありません'))
                : ListView.separated(
                    itemCount: questions.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final question = questions[index];
                      final lastAttempt = _lastAttempt(attemptRepo.getByQuestion(question.id));
                      return ListTile(
                        leading: _resultIcon(lastAttempt),
                        title: Text(
                          question.questionText,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(question.displayLabel),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => QuestionScreen(questionId: question.id),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Attempt? _lastAttempt(List<Attempt> attempts) {
    return attempts.isEmpty ? null : attempts.first; // getByQuestionは新しい順
  }

  Widget _resultIcon(Attempt? attempt) {
    if (attempt == null) {
      return const Icon(Icons.circle_outlined, color: Colors.grey);
    }
    if (attempt.isCorrect) {
      return const Icon(Icons.check_circle, color: Colors.green);
    }
    return const Icon(Icons.cancel, color: Colors.redAccent);
  }
}
