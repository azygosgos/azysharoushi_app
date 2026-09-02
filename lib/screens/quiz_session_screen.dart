import 'package:flutter/material.dart';

import '../models/quiz_item.dart';
import 'question_screen.dart';

/// 〇×クイズの演習画面。
/// 1問ずつ、文章を読んで○か×かを答え、すぐに正誤と解説・ポイント・
/// ひっかけポイントを表示する。自動車免許の試験のようなテンポで進める。
class QuizSessionScreen extends StatefulWidget {
  final List<QuizItem> items;

  const QuizSessionScreen({super.key, required this.items});

  @override
  State<QuizSessionScreen> createState() => _QuizSessionScreenState();
}

class _QuizSessionScreenState extends State<QuizSessionScreen> {
  int _index = 0;
  int _correctCount = 0;
  bool _finished = false;

  bool _answered = false;
  bool? _selected;
  bool _isCorrect = false;

  QuizItem get _current => widget.items[_index];

  void _answer(bool value) {
    if (_answered) return;
    setState(() {
      _selected = value;
      _answered = true;
      _isCorrect = value == _current.isTrue;
      if (_isCorrect) _correctCount++;
    });
  }

  void _next() {
    if (_index >= widget.items.length - 1) {
      setState(() => _finished = true);
      return;
    }
    setState(() {
      _index++;
      _answered = false;
      _selected = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) {
      return _buildSummary(context);
    }

    final item = _current;
    return Scaffold(
      appBar: AppBar(title: Text('〇×クイズ (${_index + 1}/${widget.items.length})')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (item.year != null)
              Text('${item.year}年 過去問より', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Text(item.statementText, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 20),
            _buildChoiceArea(),
            if (_answered) _buildResultArea(item),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceArea() {
    return Row(
      children: [
        Expanded(child: _choiceButton(true, '○')),
        const SizedBox(width: 12),
        Expanded(child: _choiceButton(false, '×')),
      ],
    );
  }

  Widget _choiceButton(bool value, String label) {
    final selected = _selected == value;
    Color? borderColor;
    if (_answered) {
      if (value == _current.isTrue) {
        borderColor = Colors.green;
      } else if (selected) {
        borderColor = Colors.redAccent;
      }
    }
    return OutlinedButton(
      onPressed: _answered ? null : () => _answer(value),
      style: OutlinedButton.styleFrom(
        backgroundColor: (selected && !_answered)
            ? Theme.of(context).colorScheme.primaryContainer
            : null,
        side: borderColor != null ? BorderSide(color: borderColor, width: 2) : null,
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      child: Text(label, style: const TextStyle(fontSize: 20)),
    );
  }

  Widget _buildResultArea(QuizItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 32),
        Row(
          children: [
            Icon(
              _isCorrect ? Icons.check_circle : Icons.cancel,
              color: _isCorrect ? Colors.green : Colors.redAccent,
            ),
            const SizedBox(width: 8),
            Text(
              _isCorrect ? '正解' : '不正解',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: _isCorrect ? Colors.green : Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text('正答: ${item.isTrue ? '○' : '×'}'),
        const SizedBox(height: 16),
        if (item.explanation.isNotEmpty) ...[
          _sectionTitle('解説'),
          Text(item.explanation),
          const SizedBox(height: 16),
        ],
        if (item.legalBasis.isNotEmpty) ...[
          _sectionTitle('根拠法令'),
          Text(item.legalBasis),
          const SizedBox(height: 16),
        ],
        if (item.learningPoint.isNotEmpty) ...[
          _sectionTitle('この過去問全体の試験対策ポイント'),
          Text(item.learningPoint),
          const SizedBox(height: 16),
        ],
        if (item.commonTrap.isNotEmpty) ...[
          _sectionTitle('この過去問全体のひっかけポイント'),
          Text(item.commonTrap),
          const SizedBox(height: 16),
        ],
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            icon: const Icon(Icons.description_outlined),
            label: const Text('元の過去問を見る'),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => QuestionScreen(questionId: item.sourceQuestionId),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: _next,
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          child: Text(_index >= widget.items.length - 1 ? '結果を見る' : '次の問題へ'),
        ),
      ],
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
    );
  }

  Widget _buildSummary(BuildContext context) {
    final total = widget.items.length;
    final rate = total == 0 ? 0 : (_correctCount / total * 100).round();
    return Scaffold(
      appBar: AppBar(title: const Text('結果')),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.emoji_events, size: 64, color: Colors.amber),
                const SizedBox(height: 16),
                Text(
                  '$_correctCount / $total 問正解',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text('正答率 $rate%'),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: () {
                    setState(() {
                      _index = 0;
                      _correctCount = 0;
                      _finished = false;
                      _answered = false;
                      _selected = null;
                    });
                  },
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                  child: const Text('同じ問題でもう一度'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                  child: const Text('終了する'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
