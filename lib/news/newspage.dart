import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'model/news.dart';
import 'news_detail_page.dart';

/// News landing page for the news module.
/// Fetches from the Django backend API.
class NewsPage extends StatefulWidget {
  const NewsPage({super.key, this.isAdmin = false});

  /// Toggle this to show the Add News button (mirrors web admin-only action).
  final bool isAdmin;

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  static const String _baseUrl = 'http://localhost:8000/api/news/';
  final List<News> _news = [];

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
  bool _loading = true;
  bool _fetchingMore = false;
  bool _hasNext = false;
  String? _error;
  int _page = 1;
  static const int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _loadNews(reset: true);
  }

  Future<void> _loadNews({bool reset = false}) async {
    if (reset) {
      setState(() {
        _loading = true;
        _fetchingMore = false;
        _error = null;
        _hasNext = false;
        _page = 1;
        _news.clear();
      });
    } else {
      setState(() {
        _fetchingMore = true;
        _error = null;
      });
    }

    try {
      final res = await _fetchNewsFromApi(
        page: _page,
        pageSize: _pageSize,
        month: _selectedMonthInt(),
        sort: _selectedSort == 'Terbaru' ? 'desc' : 'asc',
      );
      setState(() {
        _news.addAll(res.items);
        _hasNext = res.hasNext;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
        _fetchingMore = false;
      });
    }
  }

  Future<_NewsResponse> _fetchNewsFromApi({
    required int page,
    required int pageSize,
    int? month,
    String sort = 'desc',
  }) async {
    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'page': page.toString(),
      'page_size': pageSize.toString(),
      'sort': sort,
      if (month != null) 'month': month.toString(),
    });

    final response = await http.get(
      uri,
      headers: const {
        'Accept': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch news: ${response.statusCode}');
    }

    final dynamic data = json.decode(response.body);
    List<dynamic> rawItems;
    bool hasNext = false;

    if (data is Map<String, dynamic>) {
      rawItems = (data['items'] as List?) ?? [];
      hasNext = data['has_next'] == true;
    } else if (data is List) {
      rawItems = data;
    } else {
      rawItems = [];
    }

    final items = rawItems
        .map((e) => News.fromJson(e as Map<String, dynamic>))
        .toList();

    return _NewsResponse(items: items, hasNext: hasNext);
  }

  int? _selectedMonthInt() {
    final idx = _months.indexOf(_selectedMonth);
    if (idx <= 0) return null; // "Semua" or not found
    return idx; // Jan -> 1, etc.
  }

  Future<void> _refresh() async {
    await _loadNews(reset: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 12,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logo_top.png',
              height: 32,
            ),
            const SizedBox(width: 8),
            const Text(
              'Garuda Spot',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        actions: [
          Builder(
            builder: (ctx) => IconButton(
              onPressed: () {
                Scaffold.of(ctx).openEndDrawer();
              },
              icon: const Icon(Icons.menu, color: Colors.black),
              tooltip: 'Menu',
            ),
          ),
          if (widget.isAdmin)
            IconButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Add News tapped')),
                );
              },
              icon: const Icon(Icons.add, color: Colors.black),
              tooltip: 'Add News',
            ),
          const SizedBox(width: 4),
        ],
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.black12),
              child: Text('Menu'),
            ),
            _drawerItem(Icons.article_outlined, 'News', onTap: () {}),
            _drawerItem(Icons.shopping_bag_outlined, 'Merch', onTap: () {}),
            _drawerItem(Icons.groups_outlined, 'Squad', onTap: () {}),
            _drawerItem(Icons.event_available_outlined, 'Schedule', onTap: () {}),
            _drawerItem(Icons.confirmation_num_outlined, 'Ticket', onTap: () {}),
            _drawerItem(Icons.forum_outlined, 'Forum', onTap: () {}),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildHero(),
          _buildFilters(),
          Expanded(
            child: _buildNewsList(),
          ),
          _buildLoadMore(),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Stack(
      children: [
        SizedBox(
          height: 200,
          width: double.infinity,
          child: Image.asset(
            'assets/images/background.png',
            fit: BoxFit.cover,
          ),
        ),
        Container(
          height: 200,
          width: double.infinity,
          color: Colors.white.withOpacity(0.8),
        ),
        SizedBox(
          height: 200,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Garuda Spot',
                  style: TextStyle(
                    letterSpacing: 3,
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'BERITA TERKINI',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 60,
                  height: 3,
                  color: Colors.red.shade700,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Berita terbaru sepak bola Indonesia',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black87,
                  ),
                ),
                if (widget.isAdmin) ...[
                  const SizedBox(height: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Add News tapped')),
                      );
                    },
                    child: const Text('Add News'),
                  ),
                ]
              ],
            ),
          ),
        ),
      ],
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
                _loadNews(reset: true);
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
                _loadNews(reset: true);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsList() {
    if (_loading && _news.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _news.isEmpty) {
      return Center(child: Text('Gagal memuat berita: $_error'));
    }

    if (_news.isEmpty) {
      return const Center(child: Text('Belum ada berita.'));
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        physics: const AlwaysScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final item = _news[index];
          final snippet = item.content.length > 200
              ? '${item.content.substring(0, 200)}…'
              : item.content;
          return ListTile(
            title: Text(item.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${item.category} • ${item.publishDate}'),
                const SizedBox(height: 4),
                Text(snippet),
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
        itemCount: _news.length,
      ),
    );
  }

  Widget _buildLoadMore() {
    if (!_hasNext) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: ElevatedButton(
        onPressed: _fetchingMore
            ? null
            : () {
                _page += 1;
                _loadNews();
              },
        child: _fetchingMore
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Load More'),
      ),
    );
  }

  ListTile _drawerItem(IconData icon, String label, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: onTap ??
          () {
            Navigator.of(context).pop();
          },
    );
  }
}

class _NewsResponse {
  const _NewsResponse({
    required this.items,
    required this.hasNext,
  });

  final List<News> items;
  final bool hasNext;
}
