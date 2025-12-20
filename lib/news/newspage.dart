import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import 'model/news.dart';
import 'news_detail_page.dart';
import 'news_header.dart';
import '../right_drawer.dart';

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
  static const String _baseUrl = 'http://localhost:8000/json/';
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
    final request = context.watch<CookieRequest>();

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
              onPressed: () => _openAddDialog(request),
              icon: const Icon(Icons.add, color: Colors.black),
              tooltip: 'Add News',
            ),
          const SizedBox(width: 4),
        ],
      ),
      endDrawer: const RightDrawer(),
      body: Column(
        children: [
          NewsHeader(
            isAdmin: widget.isAdmin,
            onAddNews: () => _openAddDialog(request),
          ),
          _buildFilters(),
          Expanded(
            child: _buildNewsList(request),
          ),
          _buildLoadMore(),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    TextStyle labelStyle = const TextStyle(fontWeight: FontWeight.w600);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Row(
        children: [
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.red.shade700, width: 2),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedMonth,
                  isExpanded: true,
                  style: labelStyle,
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
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.red.shade700, width: 2),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedSort,
                  isExpanded: true,
                  style: labelStyle,
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsList(CookieRequest request) {
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
          return Card(
            elevation: 1,
            margin: EdgeInsets.zero,
            child: InkWell(
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
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Text(
                            item.category,
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              item.publishDate,
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                              ),
                            ),
                            if (widget.isAdmin)
                              IconButton(
                                onPressed: () => _confirmDelete(item, request),
                                icon: Icon(Icons.delete_outline, color: Colors.red.shade700),
                                tooltip: 'Delete',
                              ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 60,
                      height: 2,
                      color: Colors.red.shade700,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      snippet,
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(height: 8),
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

  void _openAddDialog(CookieRequest request) {
    final titleC = TextEditingController();
    final categoryC = TextEditingController();
    final dateC = TextEditingController();
    final contentC = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add News'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleC,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: categoryC,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              TextField(
                controller: dateC,
                decoration: const InputDecoration(labelText: 'Publish date'),
              ),
              TextField(
                controller: contentC,
                decoration: const InputDecoration(labelText: 'Content'),
                maxLines: 4,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _submitCreate(
                request: request,
                title: titleC.text,
                category: categoryC.text,
                publishDate: dateC.text,
                content: contentC.text,
              );
              if (mounted) {
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitCreate({
    required CookieRequest request,
    required String title,
    required String category,
    required String publishDate,
    required String content,
  }) async {
    if (!(widget.isAdmin)) return;
    try {
      final res = await request.post(
        "http://localhost:8000/api/news/add/",
        {
          "title": title,
          "category": category,
          "publish_date": publishDate,
          "content": content,
        },
      );
      final created = News.fromJson(res as Map<String, dynamic>);
      setState(() {
        _news.insert(0, created);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('News created')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create news: $e')),
      );
    }
  }

  Future<void> _confirmDelete(News item, CookieRequest request) async {
    if (!widget.isAdmin) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus berita?'),
        content: Text('Berita "${item.title}" akan dihapus. Lanjutkan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Hapus',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    await _deleteNews(item, request);
  }

  Future<void> _deleteNews(News item, CookieRequest request) async {
    try {
      final res = await request.post(
        "http://localhost:8000/api/news/delete/${item.id}/",
        {},
      );
      final ok = res is Map<String, dynamic> && res['deleted'] != null;
      if (!ok) {
        throw Exception('Unexpected response');
      }
      setState(() {
        _news.removeWhere((n) => n.id == item.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('News deleted')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete: $e')),
      );
    }
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
