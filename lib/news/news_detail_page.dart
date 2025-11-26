import 'package:flutter/material.dart';
import 'model/news.dart';

/// Placeholder detail page for a news entry.
/// Displays basic fields; will be wired to backend data later.
class NewsDetailPage extends StatelessWidget {
  const NewsDetailPage({super.key, required this.news});

  final News news;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Berita'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              news.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              '${news.category} • ${news.publishDate}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Text(news.content.isNotEmpty ? news.content : 'Konten belum tersedia.'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
