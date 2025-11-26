import 'dart:convert';

class News {
  const News({
    required this.id,
    required this.title,
    required this.category,
    required this.publishDate,
    required this.content,
    this.publishedMonth,
  });

  final String id;
  final String title;
  final String category;
  final String publishDate;
  final int? publishedMonth;
  final String content;

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      publishDate: json['publish_date']?.toString() ?? '',
      publishedMonth: _toIntOrNull(json['published_month']),
      content: json['content']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'publish_date': publishDate,
      'published_month': publishedMonth,
      'content': content,
    };
  }
}

News newsFromJson(String str) => News.fromJson(json.decode(str) as Map<String, dynamic>);

List<News> newsListFromJson(String str) {
  final dynamic data = json.decode(str);
  if (data is List) {
    return data.map((e) => News.fromJson(e as Map<String, dynamic>)).toList();
  }
  if (data is Map<String, dynamic> && data['items'] is List) {
    return (data['items'] as List)
        .map((e) => News.fromJson(e as Map<String, dynamic>))
        .toList();
  }
  return [];
}

String newsToJson(News data) => json.encode(data.toJson());
String newsListToJson(List<News> data) => json.encode(data.map((x) => x.toJson()).toList());

int? _toIntOrNull(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  return int.tryParse(value.toString());
}
