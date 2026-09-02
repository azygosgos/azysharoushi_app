import 'enums.dart';

/// 過去問(5肢択一)の選択肢を1つずつ独立させて作った〇×クイズ問題。
///
/// `assets/data/quiz_items.json` は手書きではなく、
/// `tool/generate_quiz_items.dart` が `questions.json` から自動生成したものです。
class QuizItem {
  final String id;
  final String sourceQuestionId; // 元になった過去問のQuestion.id
  final String subjectId;
  final String? topicId;
  final String? sourceId;
  final int? year;
  final String statementText; // 正誤を判定する文章
  final bool isTrue;
  final String explanation;
  final String learningPoint;
  final String commonTrap;
  final String legalBasis;
  final Importance importance;

  const QuizItem({
    required this.id,
    required this.sourceQuestionId,
    required this.subjectId,
    this.topicId,
    this.sourceId,
    this.year,
    required this.statementText,
    required this.isTrue,
    this.explanation = '',
    this.learningPoint = '',
    this.commonTrap = '',
    this.legalBasis = '',
    this.importance = Importance.c,
  });

  factory QuizItem.fromJson(Map<String, dynamic> json) {
    return QuizItem(
      id: json['id'] as String,
      sourceQuestionId: json['sourceQuestionId'] as String,
      subjectId: json['subjectId'] as String,
      topicId: json['topicId'] as String?,
      sourceId: json['sourceId'] as String?,
      year: json['year'] as int?,
      statementText: json['statementText'] as String,
      isTrue: json['isTrue'] as bool,
      explanation: json['explanation'] as String? ?? '',
      learningPoint: json['learningPoint'] as String? ?? '',
      commonTrap: json['commonTrap'] as String? ?? '',
      legalBasis: json['legalBasis'] as String? ?? '',
      importance: Importance.fromJson(json['importance'] as String? ?? 'c'),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sourceQuestionId': sourceQuestionId,
        'subjectId': subjectId,
        'topicId': topicId,
        'sourceId': sourceId,
        'year': year,
        'statementText': statementText,
        'isTrue': isTrue,
        'explanation': explanation,
        'learningPoint': learningPoint,
        'commonTrap': commonTrap,
        'legalBasis': legalBasis,
        'importance': importance.toJson(),
      };
}
