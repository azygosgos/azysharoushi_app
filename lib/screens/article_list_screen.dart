import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/article.dart';
import '../providers/repository_providers.dart';
import 'article_detail_screen.dart';

/// 条文一覧画面。章(chapterTitle)ごとにグルーピングして表示する。
class ArticleListScreen extends ConsumerWidget {
  final String lawId;
  final String lawName;

  const ArticleListScreen({super.key, required this.lawId, required this.lawName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articles = ref.watch(referenceRepositoryProvider).getArticlesByLaw(lawId);
    final grouped = _groupByChapter(articles);

    return Scaffold(
      appBar: AppBar(title: Text('$lawName 条文一覧')),
      body: SafeArea(
        child: grouped.isEmpty
            ? const Center(child: Text('条文がありません'))
            : ListView(
                children: grouped.entries.expand((entry) {
                  return [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                      child: Text(
                        entry.key,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    ...entry.value.map((article) {
                      return ListTile(
                        title: Text(article.displayHeading),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ArticleDetailScreen(articleId: article.id),
                            ),
                          );
                        },
                      );
                    }),
                    const Divider(height: 1),
                  ];
                }).toList(),
              ),
      ),
    );
  }

  /// 章(chapterTitle)ごとにグルーピングし、各章内は条文番号の昇順に並べる。
  /// 章の順番は、条文一覧内で最初に登場した順を保つ。
  Map<String, List<Article>> _groupByChapter(List<Article> articles) {
    final grouped = <String, List<Article>>{};
    for (final article in articles) {
      grouped.putIfAbsent(article.chapterTitle, () => []).add(article);
    }
    for (final list in grouped.values) {
      list.sort((a, b) => _articleSortKey(a).compareTo(_articleSortKey(b)));
    }
    return grouped;
  }

  /// "第32条の2" のような条文番号を、数値として比較できるキーに変換する。
  double _articleSortKey(Article article) {
    final match = RegExp(r'第(\d+)条(?:の(\d+))?').firstMatch(article.articleNumber);
    if (match == null) return 0;
    final main = int.parse(match.group(1)!);
    final sub = match.group(2) != null ? int.parse(match.group(2)!) : 0;
    return main + sub / 1000;
  }
}
