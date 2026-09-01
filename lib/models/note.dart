import 'enums.dart';

/// 問題単位・条文単位の自由記載メモ
class Note {
  final String id;
  final NoteTargetType targetType;
  final String targetId; // questionId または articleId
  final String content;
  final DateTime updatedAt;

  const Note({
    required this.id,
    required this.targetType,
    required this.targetId,
    required this.content,
    required this.updatedAt,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as String,
      targetType: NoteTargetType.fromJson(json['targetType'] as String),
      targetId: json['targetId'] as String,
      content: json['content'] as String,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'targetType': targetType.toJson(),
        'targetId': targetId,
        'content': content,
        'updatedAt': updatedAt.toIso8601String(),
      };
}
