/// 法律 (例: 労働基準法)
class Law {
  final String id;
  final String name;
  final String? sourceId;

  const Law({
    required this.id,
    required this.name,
    this.sourceId,
  });

  factory Law.fromJson(Map<String, dynamic> json) {
    return Law(
      id: json['id'] as String,
      name: json['name'] as String,
      sourceId: json['sourceId'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'sourceId': sourceId,
      };
}
