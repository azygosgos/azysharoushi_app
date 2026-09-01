import 'enums.dart';

/// 5肢択一・選択式などの選択肢
class Choice {
  final String id; // 例: "A", "1" など
  final String text;

  const Choice({required this.id, required this.text});

  factory Choice.fromJson(Map<String, dynamic> json) {
    return Choice(
      id: json['id'] as String,
      text: json['text'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
      };
}

/// 過去問(またはオリジナル演習問題)
///
/// [correctAnswer] は ○×問題なら "true"/"false"、
/// 5肢択一・選択式なら選択肢の [Choice.id] を指定します。
class Question {
  final String id;
  final String subjectId;
  final int? year; // 出題年度 (オリジナル問題はnull)
  final int? questionNumber; // 問題番号
  final QuestionType questionType;
  final String questionText;
  final List<Choice> choices; // ○×問題は空リストでよい
  final String correctAnswer;
  final String explanation; // オリジナル解説
  final String learningPoint; // 試験対策上のポイント
  final String commonTrap; // 間違えやすいポイント
  final String legalBasis; // 根拠法令 (表示用テキスト)
  final List<String> relatedArticleIds; // 関連条文 (question_law_links相当)
  final Importance importance;
  final String? topicId;
  final String? sourceId;

  const Question({
    required this.id,
    required this.subjectId,
    this.year,
    this.questionNumber,
    required this.questionType,
    required this.questionText,
    this.choices = const [],
    required this.correctAnswer,
    required this.explanation,
    this.learningPoint = '',
    this.commonTrap = '',
    this.legalBasis = '',
    this.relatedArticleIds = const [],
    this.importance = Importance.c,
    this.topicId,
    this.sourceId,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      subjectId: json['subjectId'] as String,
      year: json['year'] as int?,
      questionNumber: json['questionNumber'] as int?,
      questionType: QuestionType.fromJson(
        json['questionType'] as String? ?? 'trueFalse',
      ),
      questionText: json['questionText'] as String,
      choices: (json['choices'] as List<dynamic>? ?? [])
          .map((e) => Choice.fromJson(e as Map<String, dynamic>))
          .toList(),
      correctAnswer: json['correctAnswer'] as String,
      explanation: json['explanation'] as String? ?? '',
      learningPoint: json['learningPoint'] as String? ?? '',
      commonTrap: json['commonTrap'] as String? ?? '',
      legalBasis: json['legalBasis'] as String? ?? '',
      relatedArticleIds: (json['relatedArticleIds'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
      importance: Importance.fromJson(json['importance'] as String? ?? 'c'),
      topicId: json['topicId'] as String?,
      sourceId: json['sourceId'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'subjectId': subjectId,
        'year': year,
        'questionNumber': questionNumber,
        'questionType': questionType.toJson(),
        'questionText': questionText,
        'choices': choices.map((c) => c.toJson()).toList(),
        'correctAnswer': correctAnswer,
        'explanation': explanation,
        'learningPoint': learningPoint,
        'commonTrap': commonTrap,
        'legalBasis': legalBasis,
        'relatedArticleIds': relatedArticleIds,
        'importance': importance.toJson(),
        'topicId': topicId,
        'sourceId': sourceId,
      };

  /// 一覧表示用のラベル (例: "オリジナル問題" または "R5 問1")
  String get displayLabel {
    if (year != null && questionNumber != null) {
      return '$year年 問$questionNumber';
    }
    return 'オリジナル問題';
  }
}
