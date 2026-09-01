import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/attempt.dart';
import '../models/enums.dart';
import '../models/note.dart';
import '../models/question.dart';
import '../models/review_schedule.dart';
import '../providers/question_providers.dart';
import '../providers/repository_providers.dart';

/// 問題画面: 表示 → 回答 → 正誤判定 → 解説 → メモ → 理解度評価、までを1画面で行う。
class QuestionScreen extends ConsumerStatefulWidget {
  final String questionId;

  const QuestionScreen({super.key, required this.questionId});

  @override
  ConsumerState<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends ConsumerState<QuestionScreen> {
  static const _uuid = Uuid();
  final _noteController = TextEditingController();

  late final DateTime _startTime;
  String? _selectedAnswer;
  bool _answered = false;
  bool _isCorrect = false;
  DateTime? _answeredAt;
  bool _attemptSaved = false; // 理解度を選んでAttemptを保存済みか

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();

    final notes = ref
        .read(noteRepositoryProvider)
        .getByTarget(NoteTargetType.question, widget.questionId);
    if (notes.isNotEmpty) {
      _noteController.text = notes.first.content;
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _submitAnswer(Question question) {
    if (_selectedAnswer == null) return;
    setState(() {
      _answered = true;
      _answeredAt = DateTime.now();
      _isCorrect = _selectedAnswer == question.correctAnswer;
    });
  }

  Future<void> _saveAttemptWithUnderstanding(
    Question question,
    Understanding understanding,
  ) async {
    if (_attemptSaved || _selectedAnswer == null || _answeredAt == null) return;

    final attemptRepo = ref.read(attemptRepositoryProvider);
    final reviewRepo = ref.read(reviewScheduleRepositoryProvider);
    final reviewService = ref.read(reviewServiceProvider);

    final previousCount = attemptRepo.getByQuestion(question.id).length;
    final attempt = Attempt(
      id: _uuid.v4(),
      questionId: question.id,
      answeredAt: _answeredAt!,
      userAnswer: _selectedAnswer!,
      isCorrect: _isCorrect,
      understanding: understanding,
      durationSeconds: _answeredAt!.difference(_startTime).inSeconds,
      reviewCount: previousCount + 1,
    );
    await attemptRepo.add(attempt);

    final currentSchedule = reviewRepo.getByQuestion(question.id);
    final nextSchedule = reviewService.computeNext(
      questionId: question.id,
      current: currentSchedule,
      isCorrect: _isCorrect,
      understanding: understanding,
      now: DateTime.now(),
    );
    await reviewRepo.upsert(nextSchedule);

    if (!mounted) return;
    setState(() => _attemptSaved = true);
    bumpDataRevision(ref);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('記録しました(次回復習: ${nextSchedule.intervalDays}日後)')),
    );
  }

  Future<void> _saveNote(String questionId) async {
    final content = _noteController.text.trim();
    final noteRepo = ref.read(noteRepositoryProvider);
    // 1問につき1件のメモになるよう、IDを固定にしてupsertする。
    final noteId = 'note_question_$questionId';
    await noteRepo.upsert(Note(
      id: noteId,
      targetType: NoteTargetType.question,
      targetId: questionId,
      content: content,
      updatedAt: DateTime.now(),
    ));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('メモを保存しました')));
  }

  Future<void> _markForLaterReview(String questionId) async {
    final reviewRepo = ref.read(reviewScheduleRepositoryProvider);
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    await reviewRepo.upsert(ReviewSchedule(
      questionId: questionId,
      dueDate: DateTime(tomorrow.year, tomorrow.month, tomorrow.day),
      intervalDays: 1,
      repetition: 0,
      updatedAt: DateTime.now(),
    ));
    if (!mounted) return;
    bumpDataRevision(ref);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('復習リストに追加しました')));
  }

  @override
  Widget build(BuildContext context) {
    final question = ref.watch(questionByIdProvider(widget.questionId));
    if (question == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('問題')),
        body: const Center(child: Text('問題が見つかりませんでした')),
      );
    }

    final favoriteRepo = ref.watch(favoriteRepositoryProvider);
    final isFavorite = favoriteRepo.isFavorite(question.id);
    final subjects = ref.watch(referenceRepositoryProvider).getSubjects();
    final matchingSubjects = subjects.where((s) => s.id == question.subjectId);
    final subjectName = matchingSubjects.isEmpty ? '' : matchingSubjects.first.name;

    return Scaffold(
      appBar: AppBar(
        title: Text(subjectName),
        actions: [
          IconButton(
            icon: Icon(isFavorite ? Icons.star : Icons.star_border),
            tooltip: 'お気に入り登録',
            onPressed: () async {
              await favoriteRepo.toggle(question.id);
              if (!mounted) return;
              setState(() {});
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(question.displayLabel, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Text(question.questionText, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 20),
            _buildChoiceArea(question),
            const SizedBox(height: 12),
            if (!_answered) ...[
              FilledButton(
                onPressed: _selectedAnswer == null ? null : () => _submitAnswer(question),
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                child: const Text('回答する'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                icon: const Icon(Icons.schedule),
                label: const Text('後で復習する'),
                onPressed: () => _markForLaterReview(question.id),
              ),
            ],
            if (_answered) _buildResultArea(question),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceArea(Question question) {
    if (question.questionType == QuestionType.trueFalse) {
      return Row(
        children: [
          Expanded(child: _choiceButton('true', '○', question)),
          const SizedBox(width: 12),
          Expanded(child: _choiceButton('false', '×', question)),
        ],
      );
    }
    return Column(
      children: question.choices.map((c) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _choiceButton(c.id, '${c.id}. ${c.text}', question, alignLeft: true),
        );
      }).toList(),
    );
  }

  Widget _choiceButton(String value, String label, Question question, {bool alignLeft = false}) {
    final selected = _selectedAnswer == value;
    Color? borderColor;
    if (_answered) {
      if (value == question.correctAnswer) {
        borderColor = Colors.green;
      } else if (selected) {
        borderColor = Colors.redAccent;
      }
    }
    return OutlinedButton(
      onPressed: _answered ? null : () => setState(() => _selectedAnswer = value),
      style: OutlinedButton.styleFrom(
        backgroundColor: (selected && !_answered)
            ? Theme.of(context).colorScheme.primaryContainer
            : null,
        side: borderColor != null ? BorderSide(color: borderColor, width: 2) : null,
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      child: Align(
        alignment: alignLeft ? Alignment.centerLeft : Alignment.center,
        child: Text(label, style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  Widget _buildResultArea(Question question) {
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
        Text('正答: ${_answerLabel(question, question.correctAnswer)}'),
        const SizedBox(height: 16),
        _sectionTitle('オリジナル解説'),
        Text(question.explanation),
        if (question.legalBasis.isNotEmpty) ...[
          const SizedBox(height: 16),
          _sectionTitle('根拠法令'),
          Text(question.legalBasis),
        ],
        if (question.relatedArticleIds.isNotEmpty) ...[
          const SizedBox(height: 16),
          _sectionTitle('関連条文'),
          ..._buildRelatedArticles(question),
        ],
        if (question.learningPoint.isNotEmpty) ...[
          const SizedBox(height: 16),
          _sectionTitle('試験対策上のポイント'),
          Text(question.learningPoint),
        ],
        if (question.commonTrap.isNotEmpty) ...[
          const SizedBox(height: 16),
          _sectionTitle('間違えやすいポイント'),
          Text(question.commonTrap),
        ],
        const SizedBox(height: 20),
        _sectionTitle('自分の復習メモ'),
        const SizedBox(height: 6),
        TextField(
          controller: _noteController,
          maxLines: 3,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: '覚え方や間違えたポイントなど、自由にメモできます',
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => _saveNote(question.id),
            child: const Text('メモを保存'),
          ),
        ),
        const SizedBox(height: 20),
        _sectionTitle('理解度'),
        const SizedBox(height: 8),
        _buildUnderstandingButtons(question),
        if (_attemptSaved)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text('記録済みです。戻って他の問題にも挑戦しましょう。'),
          ),
      ],
    );
  }

  List<Widget> _buildRelatedArticles(Question question) {
    final referenceRepo = ref.read(referenceRepositoryProvider);
    return question.relatedArticleIds.map((id) {
      final article = referenceRepo.getArticleById(id);
      if (article == null) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text('・${article.displayHeading}'),
      );
    }).toList();
  }

  Widget _buildUnderstandingButtons(Question question) {
    return Row(
      children: Understanding.values.map((u) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: OutlinedButton(
              onPressed: _attemptSaved ? null : () => _saveAttemptWithUnderstanding(question, u),
              child: Text(u.label),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14));
  }

  String _answerLabel(Question question, String answer) {
    if (question.questionType == QuestionType.trueFalse) {
      return answer == 'true' ? '○' : '×';
    }
    final matches = question.choices.where((c) => c.id == answer);
    return matches.isEmpty ? answer : '${matches.first.id}. ${matches.first.text}';
  }
}
