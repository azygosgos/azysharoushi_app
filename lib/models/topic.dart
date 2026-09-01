import 'enums.dart';

/// 出題論点 (例: 「休日と休暇の違い」)
class Topic {
  final String id;
  final String subjectId;
  final String name;
  final Importance importance;

  const Topic({
    required this.id,
    required this.subjectId,
    required this.name,
    this.importance = Importance.c,
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['id'] as String,
      subjectId: json['subjectId'] as String,
      name: json['name'] as String,
      importance: Importance.fromJson(json['importance'] as String? ?? 'c'),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'subjectId': subjectId,
        'name': name,
        'importance': importance.toJson(),
      };
}
