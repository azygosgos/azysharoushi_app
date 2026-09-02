import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/repository_providers.dart';
import 'question_list_screen.dart';

/// 過去問演習の科目選択画面。科目が増えてきたので、
/// ホーム画面から直接1科目に決め打ちするのではなく、ここで選んでもらう。
class SubjectListScreen extends ConsumerWidget {
  const SubjectListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjects = ref.watch(referenceRepositoryProvider).getSubjects();

    return Scaffold(
      appBar: AppBar(title: const Text('過去問演習 - 科目を選ぶ')),
      body: SafeArea(
        child: ListView.separated(
          itemCount: subjects.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final subject = subjects[index];
            return ListTile(
              title: Text(subject.name),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => QuestionListScreen(
                      subjectId: subject.id,
                      subjectName: subject.name,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
