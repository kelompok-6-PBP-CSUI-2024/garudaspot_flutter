class ForumPost {
  final int id;
  final String slug;
  final String author;
  final String date;
  final String title;
  final String content;
  final String category;
  final int likeCount;

  ForumPost({
    required this.id,
    required this.slug,
    required this.author,
    required this.date,
    required this.title,
    required this.content,
    required this.category,
    required this.likeCount,
  });

  factory ForumPost.fromJson(Map<String, dynamic> json) {
    return ForumPost(
      id: json['id'] ?? 0,
      slug: json['slug'] ?? '',
      author: json['author'] ?? '',
      date: json['date'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      category: json['category'] ?? '',
      likeCount: json['like_count'] ?? 0,
    );
  }
}
