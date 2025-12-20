// lib/schedule/screens/match_list.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import 'model/match.dart'; 
import 'match_detail.dart';
import 'match_form.dart'; 
import '../right_drawer.dart'; 

class MatchListPage extends StatefulWidget {
  const MatchListPage({super.key, this.isAdmin = false});

  final bool isAdmin;

  @override
  State<MatchListPage> createState() => _MatchListPageState();
}

class _MatchListPageState extends State<MatchListPage> {
  // Ganti URL sesuai environment
  static const String _baseUrl = 'http://localhost:8000/schedule/api/match/';
  
  final List<Match> _matches = [];
  final List<String> _categories = const [
    'Semua', 'Friendly Match', 'FIFA Matchday A', 'FIFA Matchday B',
    'AFF Championship', 'AFC Qualifiers', 'AFC Cup',
    'World Cup Qualifiers', 'World Cup', 'Other'
  ];

  String _selectedCategory = 'Semua';
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
    _loadMatches(reset: true);
  }

  Future<void> _loadMatches({bool reset = false}) async {
    if (reset) {
      setState(() {
        _loading = true;
        _fetchingMore = false;
        _error = null;
        _hasNext = false;
        _page = 1;
        _matches.clear();
      });
    } else {
      setState(() {
        _fetchingMore = true;
        _error = null;
      });
    }

    try {
      final res = await _fetchMatchesFromApi(
        page: _page,
        pageSize: _pageSize,
        category: _selectedCategory == 'Semua' ? null : _selectedCategory,
        sort: _selectedSort == 'Terbaru' ? 'desc' : 'asc',
      );
      setState(() {
        _matches.addAll(res.items);
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

  Future<_MatchResponse> _fetchMatchesFromApi({
    required int page,
    required int pageSize,
    String? category,
    String sort = 'desc',
  }) async {
    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'page': page.toString(),
      'page_size': pageSize.toString(),
      'sort': sort,
      if (category != null) 'category': category,
    });

    final response = await http.get(
      uri,
      headers: const {
        'Accept': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch matches: ${response.statusCode}');
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
        .map((e) => Match.fromJson(e as Map<String, dynamic>))
        .toList();

    return _MatchResponse(items: items, hasNext: hasNext);
  }

  Future<void> _refresh() async {
    await _loadMatches(reset: true);
  }

  // --- Navigasi: Create Match ---
  void _openAddPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MatchFormPage()),
    );
    if (result == true) {
      _loadMatches(reset: true);
    }
  }

  // --- Navigasi: Edit Match ---
  void _openEditPage(Match match) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MatchFormPage(match: match), 
      ),
    );
    if (result == true) {
      _loadMatches(reset: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: Colors.white, // Background Scaffold Putih
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
              errorBuilder: (ctx, error, stackTrace) => 
                  const Icon(Icons.sports_soccer, color: Colors.red),
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
              onPressed: _openAddPage,
              icon: const Icon(Icons.add, color: Colors.black),
              tooltip: 'Add Match',
            ),
          const SizedBox(width: 4),
        ],
      ),
      endDrawer: const RightDrawer(),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            alignment: Alignment.centerLeft,
            child: const Text(
              "Schedule",
              style: TextStyle(
                fontSize: 20, 
                fontWeight: FontWeight.bold, 
                color: Color.fromARGB(255, 115, 13, 13)
              ),
            ),
          ),
          _buildFilters(),
          Expanded(child: _buildMatchList(request)),
          _buildLoadMore(),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    TextStyle labelStyle = const TextStyle(fontWeight: FontWeight.w600);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Row(
        children: [
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.red.shade700, width: 2)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _categories.contains(_selectedCategory) ? _selectedCategory : _categories.first,
                  isExpanded: true,
                  style: labelStyle,
                  items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _selectedCategory = value);
                    _loadMatches(reset: true);
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.red.shade700, width: 2)),
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
                    setState(() => _selectedSort = value);
                    _loadMatches(reset: true);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchList(CookieRequest request) {
    if (_loading && _matches.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _matches.isEmpty) {
      return Center(child: Text('Gagal memuat jadwal: $_error'));
    }
    if (_matches.isEmpty) {
      return const Center(child: Text('Belum ada jadwal pertandingan.'));
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final item = _matches[index];
          
          return Card(
            // === SETTING CARD AGAR PUTIH, NO GAP, & FLAT ===
            color: Colors.white, 
            elevation: 0, 
            margin: EdgeInsets.zero, // Menghilangkan gap bawaan Card
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero, // Agar sudut menyatu rapi
            ),
            // ===============================================
            
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => MatchDetailPage(match: item)),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.red.shade700, width: 0.5),
                    bottom: BorderSide(color: Colors.red.shade700, width: 0.5),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      // --- TOP ROW: Kategori, Tanggal, & Action Buttons ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                                "${item.matchDate.day}-${item.matchDate.month}-${item.matchDate.year}",
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 12,
                                ),
                              ),
                              
                              if (widget.isAdmin)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      constraints: const BoxConstraints(),
                                      padding: const EdgeInsets.only(left: 8),
                                      onPressed: () => _openEditPage(item),
                                      icon: Icon(Icons.edit_outlined, color: Colors.blue.shade700, size: 20),
                                      tooltip: 'Edit',
                                    ),
                                    IconButton(
                                      constraints: const BoxConstraints(),
                                      padding: const EdgeInsets.only(left: 4),
                                      onPressed: () => _confirmDelete(item, request),
                                      icon: Icon(Icons.delete_outline, color: Colors.red.shade700, size: 20),
                                      tooltip: 'Delete',
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ],
                      ),

                      // --- MIDDLE ROW: Score ---
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                item.homeTeam,
                                textAlign: TextAlign.end,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 12),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "${item.homeScore ?? '-'} : ${item.awayScore ?? '-'}",
                                style: const TextStyle(
                                  color: Colors.white, 
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                item.awayTeam,
                                textAlign: TextAlign.start,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // --- BOTTOM ROW: Location ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.location_on, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            item.location,
                            style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        // Pastikan separator juga 0
        separatorBuilder: (_, __) => const SizedBox(height: 0),
        itemCount: _matches.length,
      ),
    );
  }

  Widget _buildLoadMore() {
    if (!_hasNext) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: ElevatedButton(
        onPressed: _fetchingMore
            ? null
            : () {
                _page += 1;
                _loadMatches();
              },
        child: _fetchingMore
            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
            : const Text('Load More'),
      ),
    );
  }

  Future<void> _confirmDelete(Match item, CookieRequest request) async {
    if (!widget.isAdmin) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Jadwal?'),
        content: Text('${item.homeTeam} vs ${item.awayTeam} akan dihapus. Lanjutkan?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Hapus', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      await _deleteMatch(item, request);
    }
  }

  Future<void> _deleteMatch(Match item, CookieRequest request) async {
    try {
      final res = await request.post(
        "http://localhost:8000/schedule/api/match/delete/${item.id}/",
        {},
      );
      final ok = res is Map<String, dynamic>; 
      if (!ok) throw Exception('Unexpected response');
      
      setState(() {
        _matches.removeWhere((m) => m.id == item.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Match deleted')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
    }
  }
}

class _MatchResponse {
  const _MatchResponse({required this.items, required this.hasNext});
  final List<Match> items;
  final bool hasNext;
}
