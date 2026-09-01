/// 試験科目 (例: 労働基準法)
class Subject {
  final String id;
  final String name;
  final int order;

  const Subject({
    required this.id,
    required this.name,
    required this.order,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'] as String,
      name: json['name'] as String,
      order: json['order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'order': order,
      };
}
