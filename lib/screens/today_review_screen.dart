import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/review_providers.dart';
import 'question_screen.dart';

/// 「今日の復習」画面: 復習予定日が今日以前になっている問題の一覧。
class TodayReviewScreen extends ConsumerWidget {
  const TodayReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questions = ref.watch(todayReviewQuestionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('今日の復習')),
      body: SafeArea(
        child: questions.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    '今日復習すべき問題はありません。\n過去問演習で新しい問題に挑戦してみましょう。',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: FilledButton.icon(
                      icon: const Icon(Icons.play_arrow),
                      label: Text('最初の問題から始める(${questions.length}問)'),
                      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => QuestionScreen(questionId: questions.first.id),
                          ),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      itemCount: questions.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final question = questions[index];
                        return ListTile(
                          leading: CircleAvatar(child: Text('${index + 1}')),
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
      ),
    );
  }
}
