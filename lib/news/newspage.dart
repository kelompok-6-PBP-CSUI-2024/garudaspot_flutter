import 'package:flutter/material.dart';
import 'model/news.dart';
import 'news_detail_page.dart';

/// Very early, non-styled landing page for the news module.
/// Currently uses local sample data; backend wiring will come later.
class NewsPage extends StatefulWidget {
  const NewsPage({super.key, this.isAdmin = false});

  /// Toggle this to show the Add News button (mirrors web admin-only action).
  final bool isAdmin;

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  // Simple placeholder list to mimic backend data.
  final List<News> _allNews = [
    const News(
      id: '1',
      title: 'Garuda buka musim dengan kemenangan',
      category: 'Match',
      publishDate: '12 Oct 2024',
      publishedMonth: 10,
      content: 'Pertandingan perdana musim ini berakhir manis untuk Garuda.',
    ),
    const News(
      id: '2',
      title: 'Pemain baru resmi gabung tim',
      category: 'Transfer',
      publishDate: '10 Oct 2024',
      publishedMonth: 10,
      content: 'Rekrutan anyar diharapkan menambah kedalaman skuad.',
    ),
    const News(
      id: '3',
      title: 'Latihan tertutup jelang laga besar',
      category: 'Training',
      publishDate: '08 Oct 2024',
      publishedMonth: 10,
      content: 'Fokus pada taktik dan kesiapan fisik seluruh pemain.',
    ),
  ];

  final List<String> _months = const [
    'Semua',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  String _selectedMonth = 'Semua';
  String _selectedSort = 'Terbaru';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Berita Terkini'),
        actions: [
          if (widget.isAdmin)
            IconButton(
              onPressed: () {
                // Later: open add-news form modal/page.
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Add News tapped')),
                );
              },
              icon: const Icon(Icons.add),
              tooltip: 'Add News',
            ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: _buildNewsList(),
          ),
          _buildLoadMore(),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          Expanded(
            child: DropdownButton<String>(
              value: _selectedMonth,
              isExpanded: true,
              items: _months
                  .map((m) => DropdownMenuItem(value: m, child: Text('Bulan: $m')))
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _selectedMonth = value;
                });
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButton<String>(
              value: _selectedSort,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 'Terbaru', child: Text('Urutkan: Terbaru')),
                DropdownMenuItem(value: 'Terlama', child: Text('Urutkan: Terlama')),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _selectedSort = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsList() {
    // For now, just return the static list; filtering/sorting can be wired later.
    final items = List<News>.from(_allNews);

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          title: Text(item.title),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${item.category} • ${item.publishDate}'),
              const SizedBox(height: 4),
              Text(item.content),
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => NewsDetailPage(
                  news: item,
                ),
              ),
            );
          },
        );
      },
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemCount: items.length,
    );
  }

  Widget _buildLoadMore() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: ElevatedButton(
        onPressed: () {
          // Later: fetch next page.
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Load more tapped')),
          );
        },
        child: const Text('Load More'),
      ),
    );
  }
}
