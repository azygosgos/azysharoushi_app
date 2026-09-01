/// 問題ごとの次回復習予定 (間隔反復スケジュール)
class ReviewSchedule {
  final String questionId; // 問題IDをそのままキーにする(1問1レコード)
  final DateTime dueDate; // 次回復習予定日
  final int intervalDays; // 現在の復習間隔(日数)
  final int repetition; // 連続正解回数などのステップ数
  final DateTime updatedAt;

  const ReviewSchedule({
    required this.questionId,
    required this.dueDate,
    required this.intervalDays,
    required this.repetition,
    required this.updatedAt,
  });

  factory ReviewSchedule.fromJson(Map<String, dynamic> json) {
    return ReviewSchedule(
      questionId: json['questionId'] as String,
      dueDate: DateTime.parse(json['dueDate'] as String),
      intervalDays: json['intervalDays'] as int,
      repetition: json['repetition'] as int? ?? 0,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'questionId': questionId,
        'dueDate': dueDate.toIso8601String(),
        'intervalDays': intervalDays,
        'repetition': repetition,
        'updatedAt': updatedAt.toIso8601String(),
      };

  ReviewSchedule copyWith({
    DateTime? dueDate,
    int? intervalDays,
    int? repetition,
    DateTime? updatedAt,
  }) {
    return ReviewSchedule(
      questionId: questionId,
      dueDate: dueDate ?? this.dueDate,
      intervalDays: intervalDays ?? this.intervalDays,
      repetition: repetition ?? this.repetition,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
