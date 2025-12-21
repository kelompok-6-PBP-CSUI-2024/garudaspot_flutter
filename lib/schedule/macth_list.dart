// lib/schedule/screens/match_list.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import 'model/match.dart'; 
import 'match_detail.dart';
import '../right_drawer.dart'; 

class MatchListPage extends StatefulWidget {
  // Menerima parameter isAdmin dari halaman sebelumnya
  const MatchListPage({super.key, this.isAdmin = false, this.isSuperuser = false});

  final bool isAdmin;
  final bool isSuperuser;

  bool get canManage => isAdmin || isSuperuser;

  @override
  State<MatchListPage> createState() => _MatchListPageState();
}

class _MatchListPageState extends State<MatchListPage> {
  // Sesuaikan URL: localhost untuk Web/iOS, 10.0.2.2 untuk Android Emulator
  static const String _baseUrl = 'https://hasanul-muttaqin-garudaspot.pbp.cs.ui.ac.id/schedule/api/match/';
  
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

  // --- LOGIC DIALOG / POPUP ---
  void _openFormDialog({Match? match}) async {
    await showDialog(
      context: context,
      builder: (context) => MatchFormDialog(
        match: match,
        canManage: widget.canManage,
      ),
    );
    _loadMatches(reset: true);
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: Colors.white,
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
          if (widget.canManage)
            IconButton(
              onPressed: () => _openFormDialog(), 
              icon: const Icon(Icons.add, color: Colors.black),
              tooltip: 'Add Match',
            ),
          Builder(
            builder: (ctx) => IconButton(
              onPressed: () {
                Scaffold.of(ctx).openEndDrawer();
              },
              icon: const Icon(Icons.menu, color: Colors.black),
              tooltip: 'Menu',
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      endDrawer: RightDrawer(
        isAdmin: widget.isAdmin,
        isSuperuser: widget.isSuperuser,
      ),
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
            color: Colors.white, 
            elevation: 0, 
            margin: EdgeInsets.zero, 
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero, 
            ),
            child: InkWell(
              onTap: () {
                if (!request.loggedIn) {
                  Navigator.pushReplacementNamed(context, '/');
                  return;
                }
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
                              
                              if (widget.canManage)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      constraints: const BoxConstraints(),
                                      padding: const EdgeInsets.only(left: 8),
                                      onPressed: () => _openFormDialog(match: item), 
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
    if (!widget.canManage) return;
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
      final res = await request.postJson(
        "https://hasanul-muttaqin-garudaspot.pbp.cs.ui.ac.id/schedule/api/match/delete/${item.id}/",
        jsonEncode({
          "is_admin": widget.canManage,
        }),
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

// ==========================================================
// KELAS BARU: MatchFormDialog (POPUP FORM) - FIXED TYPES
// ==========================================================

class MatchFormDialog extends StatefulWidget {
  final Match? match;
  const MatchFormDialog({super.key, this.match, required this.canManage});

  final bool canManage;

  @override
  State<MatchFormDialog> createState() => _MatchFormDialogState();
}

class _MatchFormDialogState extends State<MatchFormDialog> {
  final _formKey = GlobalKey<FormState>();

  // --- Controllers ---
  final _homeTeamController = TextEditingController();
  final _awayTeamController = TextEditingController();
  final _locationController = TextEditingController();
  final _dateController = TextEditingController();
  final _homeScoreController = TextEditingController();
  final _awayScoreController = TextEditingController();
  
  // Stats Controllers
  final _shotsHome = TextEditingController();
  final _shotsAway = TextEditingController();
  final _possessionHome = TextEditingController();
  final _possessionAway = TextEditingController();
  final _passesHome = TextEditingController();
  final _passesAway = TextEditingController();
  final _foulsHome = TextEditingController();
  final _foulsAway = TextEditingController();
  final _yellowHome = TextEditingController();
  final _yellowAway = TextEditingController();
  final _redHome = TextEditingController();
  final _redAway = TextEditingController();
  final _cornersHome = TextEditingController();
  final _cornersAway = TextEditingController();
  final _offsidesHome = TextEditingController();
  final _offsidesAway = TextEditingController();

  String _category = 'Friendly Match';
  DateTime? _selectedDate;

  final List<String> _categories = [
    'Friendly Match', 'FIFA Matchday A', 'FIFA Matchday B',
    'AFF Championship', 'AFC Qualifiers', 'AFC Cup',
    'World Cup Qualifiers', 'World Cup', 'Other'
  ];

  @override
  void initState() {
    super.initState();
    // Jika Mode Edit: Isi form dengan data lama
    if (widget.match != null) {
      final m = widget.match!;
      _homeTeamController.text = m.homeTeam;
      _awayTeamController.text = m.awayTeam;
      _locationController.text = m.location;
      
      _selectedDate = m.matchDate;
      _dateController.text = "${m.matchDate.year}-${m.matchDate.month.toString().padLeft(2,'0')}-${m.matchDate.day.toString().padLeft(2,'0')}";

      if (_categories.contains(m.category)) _category = m.category;
      
      String str(int? val) => val?.toString() ?? '';
      _homeScoreController.text = str(m.homeScore);
      _awayScoreController.text = str(m.awayScore);
      
      // Stats
      _shotsHome.text = str(m.shotsHome); _shotsAway.text = str(m.shotsAway);
      _possessionHome.text = str(m.possessionHome); _possessionAway.text = str(m.possessionAway);
      _passesHome.text = str(m.passesHome); _passesAway.text = str(m.passesAway);
      _foulsHome.text = str(m.foulsHome); _foulsAway.text = str(m.foulsAway);
      _yellowHome.text = str(m.yellowCardsHome); _yellowAway.text = str(m.yellowCardsAway);
      _redHome.text = str(m.redCardsHome); _redAway.text = str(m.redCardsAway);
      _cornersHome.text = str(m.cornersHome); _cornersAway.text = str(m.cornersAway);
      _offsidesHome.text = str(m.offsidesHome); _offsidesAway.text = str(m.offsidesAway);
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.read<CookieRequest>();
    final isEdit = widget.match != null;

    return AlertDialog(
      title: Text(isEdit ? "Edit Match" : "Add Match"),
      scrollable: true, 
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
               TextFormField(
                controller: _homeTeamController,
                decoration: const InputDecoration(labelText: "Home Team", isDense: true),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _awayTeamController,
                decoration: const InputDecoration(labelText: "Away Team", isDense: true),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: TextFormField(controller: _homeScoreController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Home Score", isDense: true))),
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text("-")),
                  Expanded(child: TextFormField(controller: _awayScoreController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Away Score", isDense: true))),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: "Location", isDense: true),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(labelText: "Date", isDense: true),
                readOnly: true,
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedDate = picked;
                      _dateController.text = "${picked.year}-${picked.month.toString().padLeft(2,'0')}-${picked.day.toString().padLeft(2,'0')}";
                    });
                  }
                },
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _categories.contains(_category) ? _category : _categories[0],
                isExpanded: true,
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c, overflow: TextOverflow.ellipsis))).toList(),
                onChanged: (v) => setState(() => _category = v!),
              ),
              const Divider(),
              const Text("Stats (Optional)", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              _statRow("Shots", _shotsHome, _shotsAway),
              _statRow("Possession", _possessionHome, _possessionAway),
              _statRow("Passes", _passesHome, _passesAway),
              _statRow("Fouls", _foulsHome, _foulsAway),
              _statRow("Yellow Cards", _yellowHome, _yellowAway),
              _statRow("Red Cards", _redHome, _redAway),
              _statRow("Corners", _cornersHome, _cornersAway),
              _statRow("Offsides", _offsidesHome, _offsidesAway),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              
              // Helper: Ubah ke int dulu (validasi), lalu .toString()
              int pInt(String v) => v.isEmpty ? 0 : int.tryParse(v) ?? 0;
              
              final payload = {
                'home_team': _homeTeamController.text,
                'away_team': _awayTeamController.text,
                'location': _locationController.text,
                'match_date': _dateController.text,
                'category': _category,
                'is_admin': widget.canManage ? 'true' : 'false',
                
                // Tambahkan .toString() agar dikirim sebagai String!
                'home_score': pInt(_homeScoreController.text).toString(),
                'away_score': pInt(_awayScoreController.text).toString(),
                
                // Stats
                'shots_home': pInt(_shotsHome.text).toString(), 
                'shots_away': pInt(_shotsAway.text).toString(),
                
                'possession_home': pInt(_possessionHome.text).toString(), 
                'possession_away': pInt(_possessionAway.text).toString(),
                
                'passes_home': pInt(_passesHome.text).toString(), 
                'passes_away': pInt(_passesAway.text).toString(),
                
                'fouls_home': pInt(_foulsHome.text).toString(), 
                'fouls_away': pInt(_foulsAway.text).toString(),
                
                'yellow_cards_home': pInt(_yellowHome.text).toString(), 
                'yellow_cards_away': pInt(_yellowAway.text).toString(),
                
                'red_cards_home': pInt(_redHome.text).toString(), 
                'red_cards_away': pInt(_redAway.text).toString(),
                
                'corners_home': pInt(_cornersHome.text).toString(), 
                'corners_away': pInt(_cornersAway.text).toString(),
                
                'offsides_home': pInt(_offsidesHome.text).toString(), 
                'offsides_away': pInt(_offsidesAway.text).toString(),
              };

              final url = isEdit
                  ? "https://hasanul-muttaqin-garudaspot.pbp.cs.ui.ac.id/schedule/api/match/edit/${widget.match!.id}/"
                  : "https://hasanul-muttaqin-garudaspot.pbp.cs.ui.ac.id/schedule/api/match/add/";

              try {
                final response = await request.post(url, payload);

                if (context.mounted) {
                  // Cek respon sukses
                  if (response['id'] != null || response['status'] == 'success') {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEdit ? "Updated" : "Saved")));
                    Navigator.pop(context); // Tutup dialog jika sukses
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to save data")));
                  }
                }
              } catch (e) {
                print("Error saving: $e");
                if (context.mounted) {
                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                }
              }
            }
          },
          child: const Text("Save"),
        )
      ],
    );
  }

  Widget _statRow(String label, TextEditingController h, TextEditingController a) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: TextFormField(controller: h, keyboardType: TextInputType.number, textAlign: TextAlign.center, decoration: const InputDecoration(hintText: "0", isDense: true, contentPadding: EdgeInsets.all(8), border: OutlineInputBorder()))),
          SizedBox(width: 80, child: Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11))),
          Expanded(child: TextFormField(controller: a, keyboardType: TextInputType.number, textAlign: TextAlign.center, decoration: const InputDecoration(hintText: "0", isDense: true, contentPadding: EdgeInsets.all(8), border: OutlineInputBorder()))),
        ],
      ),
    );
  }
}
