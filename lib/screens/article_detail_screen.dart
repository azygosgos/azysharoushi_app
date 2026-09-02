import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/repository_providers.dart';
import 'question_screen.dart';

/// 条文詳細画面。条文本文・試験対策ポイント・この条文に関連する過去問一覧を表示する。
class ArticleDetailScreen extends ConsumerWidget {
  final String articleId;

  const ArticleDetailScreen({super.key, required this.articleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final article = ref.watch(referenceRepositoryProvider).getArticleById(articleId);
    if (article == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('条文')),
        body: const Center(child: Text('条文が見つかりませんでした')),
      );
    }

    final relatedQuestions =
        ref.watch(questionRepositoryProvider).getByRelatedArticle(articleId);

    return Scaffold(
      appBar: AppBar(title: Text(article.articleNumber)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(article.chapterTitle, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 4),
            Text(article.displayHeading, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            for (var i = 0; i < article.paragraphs.length; i++) ...[
              Text('${i + 1}. ${article.paragraphs[i]}'),
              const SizedBox(height: 8),
            ],
            if (article.examPoints.isNotEmpty) ...[
              const SizedBox(height: 12),
              _sectionTitle('試験対策上のポイント'),
              const SizedBox(height: 6),
              for (final point in article.examPoints)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('・$point'),
                ),
            ],
            if (relatedQuestions.isNotEmpty) ...[
              const SizedBox(height: 20),
              _sectionTitle('この条文に関連する過去問'),
              const SizedBox(height: 6),
              for (final question in relatedQuestions)
                ListTile(
                  contentPadding: EdgeInsets.zero,
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
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14));
  }
}
