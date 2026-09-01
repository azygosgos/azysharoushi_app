/// 今日のワンポイント学習
class DailyTip {
  final String id;
  final String title; // 例: "労働基準法 第35条"
  final String body; // 短い解説文
  final String? relatedArticleId;
  final String? relatedQuestionId;

  const DailyTip({
    required this.id,
    required this.title,
    required this.body,
    this.relatedArticleId,
    this.relatedQuestionId,
  });

  factory DailyTip.fromJson(Map<String, dynamic> json) {
    return DailyTip(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      relatedArticleId: json['relatedArticleId'] as String?,
      relatedQuestionId: json['relatedQuestionId'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'relatedArticleId': relatedArticleId,
        'relatedQuestionId': relatedQuestionId,
      };
}
