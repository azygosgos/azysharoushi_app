/// データの出典 (公的機関の資料等)
class Source {
  final String id;
  final String name;
  final String? url;
  final String? note;

  const Source({
    required this.id,
    required this.name,
    this.url,
    this.note,
  });

  factory Source.fromJson(Map<String, dynamic> json) {
    return Source(
      id: json['id'] as String,
      name: json['name'] as String,
      url: json['url'] as String?,
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'url': url,
        'note': note,
      };
}
