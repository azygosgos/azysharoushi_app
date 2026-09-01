/// 条文 (法律 > 章 > 条 の「条」にあたる)
///
/// 「項」は paragraphs のリストとして保持します。
class Article {
  final String id;
  final String lawId;
  final String chapterTitle;
  final String articleNumber; // 例: "第35条"
  final String title; // 例: "休日"
  final List<String> paragraphs; // 各項の条文テキスト
  final List<String> examPoints; // 試験上のポイント

  const Article({
    required this.id,
    required this.lawId,
    required this.chapterTitle,
    required this.articleNumber,
    required this.title,
    required this.paragraphs,
    this.examPoints = const [],
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] as String,
      lawId: json['lawId'] as String,
      chapterTitle: json['chapterTitle'] as String,
      articleNumber: json['articleNumber'] as String,
      title: json['title'] as String,
      paragraphs: (json['paragraphs'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
      examPoints: (json['examPoints'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'lawId': lawId,
        'chapterTitle': chapterTitle,
        'articleNumber': articleNumber,
        'title': title,
        'paragraphs': paragraphs,
        'examPoints': examPoints,
      };

  /// 画面表示用の見出し (例: "第35条 休日")
  String get displayHeading => '$articleNumber $title';
}
