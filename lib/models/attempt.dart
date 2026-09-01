import 'enums.dart';

/// 1回の回答記録 (学習履歴)
class Attempt {
  final String id;
  final String questionId;
  final DateTime answeredAt;
  final String userAnswer;
  final bool isCorrect;
  final Understanding understanding;
  final int? durationSeconds; // 回答所要時間
  final int reviewCount; // これが何回目の回答か(1=初回)

  const Attempt({
    required this.id,
    required this.questionId,
    required this.answeredAt,
    required this.userAnswer,
    required this.isCorrect,
    required this.understanding,
    this.durationSeconds,
    this.reviewCount = 1,
  });

  factory Attempt.fromJson(Map<String, dynamic> json) {
    return Attempt(
      id: json['id'] as String,
      questionId: json['questionId'] as String,
      answeredAt: DateTime.parse(json['answeredAt'] as String),
      userAnswer: json['userAnswer'] as String,
      isCorrect: json['isCorrect'] as bool,
      understanding:
          Understanding.fromJson(json['understanding'] as String? ?? 'normal'),
      durationSeconds: json['durationSeconds'] as int?,
      reviewCount: json['reviewCount'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'questionId': questionId,
        'answeredAt': answeredAt.toIso8601String(),
        'userAnswer': userAnswer,
        'isCorrect': isCorrect,
        'understanding': understanding.toJson(),
        'durationSeconds': durationSeconds,
        'reviewCount': reviewCount,
      };
}
