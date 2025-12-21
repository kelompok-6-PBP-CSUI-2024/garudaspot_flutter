import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import '/right_drawer.dart';

// pakai detail page dari file terpisah
import 'pages/post_detail_page.dart';

// pakai widget terpisah
import 'widgets/post_card.dart';
import 'widgets/desktop_category_item.dart';

class ForumPage extends StatefulWidget {
  final String username;

  /// Kalau kamu masih passing ini dari route, boleh.
  /// Tapi nanti kita tetap pakai jsonData is_superuser sebagai sumber utama.
  final bool isAdmin;

  const ForumPage({
    super.key,
    required this.username,
    this.isAdmin = false,
  });

  @override
  State<ForumPage> createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  static const String _baseUrl = 'http://localhost:8000/forum';

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Map<String, dynamic>> posts = [];
  bool _isLoading = false;

  int _visiblePostCount = 5;
  String _selectedFilter = 'Semua';

  final List<String> _kategoriList = ['Match', 'Merch', 'News', 'Player', 'Ticket'];

  List<String> get _allFilters => ['Semua', ..._kategoriList];

  // username yang valid dari session
  String get _currentUsername {
    final request = context.read<CookieRequest>();
    final u = request.jsonData['username'];
    if (u is String && u.isNotEmpty) return u;
    return widget.username;
  }

  // superuser yang valid dari session (prioritas)
  bool get _isSuperuser {
    final request = context.read<CookieRequest>();
    final v = request.jsonData['is_superuser'];
    if (v == true) return true;
    // fallback kalau kamu masih passing dari route
    return widget.isAdmin == true;
  }

  List<Map<String, dynamic>> get _filteredPosts {
    if (_selectedFilter == 'Semua') return posts;
    return posts.where((p) => p['category'] == _selectedFilter).toList();
  }

  List<Map<String, dynamic>> get _visiblePosts {
    final list = _filteredPosts;
    if (list.length <= _visiblePostCount) return list;
    return list.take(_visiblePostCount).toList();
  }

  // Form
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _isiController = TextEditingController();
  String? _selectedKategori;

  @override
  void initState() {
    super.initState();
    _loadPostsFromApi();
  }

  @override
  void dispose() {
    _judulController.dispose();
    _isiController.dispose();
    super.dispose();
  }

  // ================= API =================

  Future<void> _loadPostsFromApi() async {
    setState(() => _isLoading = true);

    try {
      final request = context.read<CookieRequest>();
      final resp = await request.get('$_baseUrl/api/posts/');

      final List list;
      if (resp is Map<String, dynamic> && resp['results'] is List) {
        list = resp['results'] as List;
      } else {
        list = resp as List;
      }

      setState(() {
        posts = list.map((e) {
          final m = Map<String, dynamic>.from(e as Map);
          return {
            'id': m['id'],
            'slug': m['slug'],
            'author': m['author'] ?? '',
            'date': m['date'] ?? '',
            'title': m['title'] ?? '',
            'content': m['content'] ?? '',
            'category': m['category'] ?? '',
            'likeCount': m['like_count'] ?? 0,
            'isLiked': m['is_liked'] == true,
          };
        }).toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error load posts: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submitPost(BuildContext dialogContext) async {
    if (!_formKey.currentState!.validate()) return;

    final title = _judulController.text.trim();
    final content = _isiController.text.trim();
    final category = _selectedKategori ?? 'Match';

    setState(() => _isLoading = true);

    try {
      final request = context.read<CookieRequest>();

      final resp = await request.postJson(
        '$_baseUrl/api/posts/',
        jsonEncode({
          'title': title, // jangan ada suffix random
          'content': content,
          'category': category,
        }),
      );

      if (resp is! Map<String, dynamic> || resp['id'] == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal buat post: $resp')),
          );
        }
        return;
      }

      await _loadPostsFromApi();

      _judulController.clear();
      _isiController.clear();
      _selectedKategori = null;

      if (mounted) Navigator.of(dialogContext).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error buat post: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleLike(int originalIndex) async {
    final post = posts[originalIndex];
    final slug = post['slug'];
    if (slug == null) return;

    try {
      final request = context.read<CookieRequest>();
      final resp = await request.postJson(
        '$_baseUrl/api/posts/$slug/like/',
        jsonEncode({}),
      );

      if (resp is! Map<String, dynamic>) return;

      final bool liked = resp['liked'] == true;
      final int likeCount = (resp['like_count'] as int?) ?? 0;

      setState(() {
        posts[originalIndex]['isLiked'] = liked;
        posts[originalIndex]['likeCount'] = likeCount;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal like: $e')),
        );
      }
    }
  }

  Future<void> _deletePost(String slug) async {
    try {
      final request = context.read<CookieRequest>();
      final resp = await request.post(
        '$_baseUrl/api/posts/$slug/delete/',
        {},
      );

      if (resp is Map && resp['ok'] == true) {
        await _loadPostsFromApi();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Post berhasil dihapus')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal hapus post: $resp')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error hapus post: $e')),
        );
      }
    }
  }

  // ================= UI =================

  void _openPostDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 80, vertical: 60),
          contentPadding: const EdgeInsets.all(16),
          content: SizedBox(
            width: 700,
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Center(
                            child: Text(
                              'Post Komen',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _judulController,
                      decoration: const InputDecoration(
                        labelText: 'Judul',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Judul wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Pilih Kategori',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedKategori,
                      items: _kategoriList.map((k) => DropdownMenuItem(value: k, child: Text(k))).toList(),
                      onChanged: (value) => setState(() => _selectedKategori = value),
                      validator: (v) => v == null ? 'Kategori wajib dipilih' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _isiController,
                      decoration: const InputDecoration(
                        labelText: 'Tulis isi post...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 8,
                      validator: (v) => v == null || v.trim().isEmpty ? 'Isi wajib diisi' : null,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('Batal'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => _submitPost(ctx),
                          child: const Text('Send'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      key: _scaffoldKey,
      endDrawer: const RightDrawer(),
      backgroundColor: const Color(0xFF3A3A3A),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Garuda Spot', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  IconButton(onPressed: _openPostDialog, icon: const Icon(Icons.add_comment_outlined)),
                  IconButton(
                    onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
                    icon: const Icon(Icons.menu),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        Container(
          width: 260,
          color: const Color(0xFF7A1E1E),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(width: 2, height: 120, color: Colors.white),
                  const SizedBox(width: 16),
                  const Text(
                    'FORUM',
                    style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 2),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              for (final cat in _allFilters)
                DesktopCategoryItem(
                  text: cat,
                  isSelected: _selectedFilter == cat,
                  onTap: () => setState(() {
                    _selectedFilter = cat;
                    _visiblePostCount = 5;
                  }),
                ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            color: Colors.white,
            child: _buildPostList(paddingHorizontal: 40),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        Container(
          height: 220,
          width: double.infinity,
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('FORUM', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text('Filter', style: TextStyle(letterSpacing: 4)),
              const SizedBox(height: 12),
              Container(width: 120, height: 3, color: Colors.red),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _allFilters.map((cat) {
                    final sel = _selectedFilter == cat;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(cat),
                        selected: sel,
                        onSelected: (_) => setState(() {
                          _selectedFilter = cat;
                          _visiblePostCount = 5;
                        }),
                        selectedColor: const Color(0xFF7A1E1E),
                        labelStyle: TextStyle(color: sel ? Colors.white : Colors.black),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            color: Colors.white,
            child: _buildPostList(paddingHorizontal: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildPostList({double paddingHorizontal = 40}) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_filteredPosts.isEmpty) {
      return const Center(child: Text('Belum ada post untuk kategori ini.'));
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: paddingHorizontal, vertical: 24),
      itemCount: _visiblePosts.length + 1,
      itemBuilder: (ctx, index) {
        if (index == _visiblePosts.length) {
          final hasMore = _visiblePostCount < _filteredPosts.length;
          if (!hasMore) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: ElevatedButton(
                onPressed: () => setState(() => _visiblePostCount += 5),
                child: const Text('Load More'),
              ),
            ),
          );
        }

        final post = _visiblePosts[index];
        final originalIndex = posts.indexOf(post);

        return Column(
          children: [
            PostCard(
              author: post['author'] ?? '',
              date: post['date'] ?? '',
              title: post['title'] ?? '',
              content: post['content'] ?? '',
              category: post['category'] ?? '',
              isLiked: post['isLiked'] == true,
              likeCount: (post['likeCount'] as int?) ?? 0,
              onLike: () => _toggleLike(originalIndex),

              // tombol delete muncul jika superuser
              canDelete: _isSuperuser,
              onDelete: _isSuperuser
                  ? () async {
                      final slug = (post['slug'] ?? '').toString();
                      if (slug.isEmpty) return;

                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Hapus post?'),
                          content: const Text('Aksi ini tidak bisa dibatalkan.'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
                            ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
                          ],
                        ),
                      );

                      if (ok == true) {
                        await _deletePost(slug);
                      }
                    }
                  : null,

              onTapTitle: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    // pakai PostDetailPage dari pages/post_detail_page.dart
                    builder: (_) => PostDetailPage(
                      isAdmin: _isSuperuser,
                      initialPost: post, username: _currentUsername,
                    ),
                  ),
                );
                // setelah balik dari detail, refresh (kalau ada delete/comment)
                await _loadPostsFromApi();
              },
            ),
            const Divider(height: 0, thickness: 1, color: Color(0xFFE0E0E0)),
          ],
        );
      },
    );
  }
}
