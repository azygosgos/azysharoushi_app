import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/quiz_item.dart';
import '../providers/repository_providers.dart';
import 'quiz_session_screen.dart';

/// 〇×クイズの開始画面。科目と問題数を選んで演習を開始する。
class QuizStartScreen extends ConsumerStatefulWidget {
  const QuizStartScreen({super.key});

  @override
  ConsumerState<QuizStartScreen> createState() => _QuizStartScreenState();
}

class _QuizStartScreenState extends ConsumerState<QuizStartScreen> {
  static const _countOptions = [10, 20, 30];

  String? _selectedSubjectId; // nullなら全科目
  int? _selectedCount; // nullなら全問

  @override
  Widget build(BuildContext context) {
    final subjects = ref.watch(referenceRepositoryProvider).getSubjects();
    final targetItems =
        ref.watch(quizItemRepositoryProvider).getBySubject(_selectedSubjectId);

    return Scaffold(
      appBar: AppBar(title: const Text('〇×クイズ')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('科目を選ぶ', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('全科目'),
                    selected: _selectedSubjectId == null,
                    onSelected: (_) => setState(() => _selectedSubjectId = null),
                  ),
                  ...subjects.map((s) {
                    return ChoiceChip(
                      label: Text(s.name),
                      selected: _selectedSubjectId == s.id,
                      onSelected: (_) => setState(() => _selectedSubjectId = s.id),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 24),
              const Text('問題数を選ぶ', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ..._countOptions.map((c) {
                    return ChoiceChip(
                      label: Text('$c問'),
                      selected: _selectedCount == c,
                      onSelected: (_) => setState(() => _selectedCount = c),
                    );
                  }),
                  ChoiceChip(
                    label: const Text('全問'),
                    selected: _selectedCount == null,
                    onSelected: (_) => setState(() => _selectedCount = null),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text('対象: ${targetItems.length}問の中から出題します'),
              const Spacer(),
              FilledButton(
                onPressed: targetItems.isEmpty ? null : () => _start(targetItems),
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                child: const Text('開始する'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _start(List<QuizItem> targetItems) {
    final shuffled = List<QuizItem>.of(targetItems)..shuffle();
    final count = _selectedCount == null
        ? shuffled.length
        : (_selectedCount! < shuffled.length ? _selectedCount! : shuffled.length);
    final selected = shuffled.take(count).toList();

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => QuizSessionScreen(items: selected)),
    );
  }
}
