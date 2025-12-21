import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import '/right_drawer.dart';

class ForumPage extends StatefulWidget {
  final String username; // nama user login
  final bool isAdmin; // apakah user ini admin

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

  String get _currentUsername {
  final request = context.read<CookieRequest>();
  final username = request.jsonData['username'];
  if (username is String && username.isNotEmpty) {
    return username;
  }
  return widget.username; // fallback
  }

  // untuk buka right drawer dari tombol
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // posts berisi map: author, date, title, content, category, likeCount, likedBy, comments
  List<Map<String, dynamic>> posts = [];
  bool _isLoading = false;

  // LOAD MORE
  int _visiblePostCount = 5;

  // FILTER
  String _selectedFilter = 'Semua';

  final List<String> _kategoriList = [
    'Match',
    'Merch',
    'News',
    'Player',
    'Ticket',
  ];

  List<String> get _allFilters => ['Semua', ..._kategoriList];

  List<Map<String, dynamic>> get _filteredPosts {
    if (_selectedFilter == 'Semua') return posts;
    return posts.where((p) => p['category'] == _selectedFilter).toList();
  }

  // hanya ambil sesuai limit tampil
  List<Map<String, dynamic>> get _visiblePosts {
    final list = _filteredPosts;
    if (list.length <= _visiblePostCount) return list;
    return list.take(_visiblePostCount).toList();
  }

  // FORM STATE
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

  // ====== API: LOAD LIST POST DARI DJANGO ======

  Future<void> _loadPostsFromApi() async {
  setState(() => _isLoading = true);

  try {
    final request = context.read<CookieRequest>();

    final resp = await request.get('$_baseUrl/api/posts/');
    // resp sudah berupa decoded JSON (Map/List)

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
          'likedBy': (m['is_liked'] == true)
        ? <String>[_currentUsername]
        : <String>[],
          'comments': <Map<String, String>>[],
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


  // ====== FORM DIALOG ======

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
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
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

                    // Judul
                    TextFormField(
                      controller: _judulController,
                      decoration: const InputDecoration(
                        labelText: 'Judul',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Judul wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),

                    // Kategori
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Pilih Kategori',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedKategori,
                      items: _kategoriList
                          .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                          .toList(),
                      onChanged: (value) => setState(() => _selectedKategori = value),
                      validator: (v) => v == null ? 'Kategori wajib dipilih' : null,
                    ),
                    const SizedBox(height: 16),

                    // Isi
                    TextFormField(
                      controller: _isiController,
                      decoration: const InputDecoration(
                        labelText: 'Tulis isi post...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 8,
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Isi wajib diisi' : null,
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

  // ====== API: KIRIM POST BARU KE DJANGO ======

  String _makeUniqueTitleForBackend(String originalTitle) {
    final suffix = DateTime.now().millisecondsSinceEpoch;
    return '${originalTitle}__$suffix';
  }

  Future<void> _submitPost(BuildContext dialogContext) async {
  if (!_formKey.currentState!.validate()) return;

  final titleOriginal = _judulController.text.trim();
  final content = _isiController.text.trim();
  final category = _selectedKategori ?? 'Match';
  final titleForBackend = _makeUniqueTitleForBackend(titleOriginal);

  setState(() => _isLoading = true);

  try {
    final request = context.read<CookieRequest>();

    // pakai CookieRequest supaya session login kebawa
    final resp = await request.postJson(
      '$_baseUrl/api/posts/',
      jsonEncode({
        'author': _currentUsername, // FIX: pakai user login beneran
        'title': titleForBackend,
        'content': content,
        'category': category,
      }),
    );

    // resp sudah decoded JSON (Map)
    if (resp is! Map<String, dynamic> || resp['id'] == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal buat post: $resp')),
        );
      }
      return;
    }

    final m = resp;

    setState(() {
      posts.insert(0, {
        'id': m['id'],
        'slug': m['slug'],
        'author': m['author'] ?? '',
        'date': m['date'] ?? '',
        'title': titleOriginal,
        'content': m['content'] ?? '',
        'category': m['category'] ?? '',
        'likeCount': m['like_count'] ?? 0,
        'likedBy': <String>[], // tetap
        'comments': <Map<String, String>>[],
      });

      _selectedFilter = 'Semua';
      _visiblePostCount = 5;
    });

    _judulController.clear();
    _isiController.clear();
    _selectedKategori = null;

    Navigator.of(dialogContext).pop();
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


  // ====== LIKE (MASIH LOKAL, BELUM KE BACKEND) ======

  Future<void> _toggleLike(int originalIndex) async {
  final post = posts[originalIndex];
  final slug = post['slug'];

  if (slug == null) return;

  try {
    final request = context.read<CookieRequest>();

    // endpoint toggle like (Django)
    final resp = await request.postJson(
      '$_baseUrl/api/posts/$slug/like/',
      jsonEncode({}), // body kosong aja
    );

    if (resp is! Map<String, dynamic>) return;

    final bool liked = resp['liked'] == true;
    final int likeCount = (resp['like_count'] as int?) ?? 0;

    // kita tetap pakai struktur "likedBy" yg sudah ada
    final List<String> likedBy = <String>[];
    if (liked) likedBy.add(_currentUsername);

    setState(() {
      posts[originalIndex]['likedBy'] = likedBy;
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
      if (!widget.isAdmin) return;

      try {
        final request = context.read<CookieRequest>();

        // Panggil view delete_post yang sudah ada (login_required + superuser check)
        // NOTE: ini view Django kamu nge-redirect, tapi untuk Flutter cukup anggap sukses kalau gak error.
        await request.post('$_baseUrl/delete/$slug/', {});

        // refresh list
        await _loadPostsFromApi();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Post berhasil dihapus')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal hapus post: $e')),
          );
        }
      }
    }



  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      key: _scaffoldKey,
      endDrawer: const RightDrawer(), // RIGHT DRAWER

      backgroundColor: const Color(0xFF3A3A3A),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Garuda Spot',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              // tombol add + menu drawer
              Row(
                children: [
                  IconButton(
                    onPressed: _openPostDialog,
                    icon: const Icon(Icons.add_comment_outlined),
                  ),
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

  // DESKTOP
  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Sidebar merah
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
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              for (final cat in _allFilters)
                _DesktopCategoryItem(
                  text: cat,
                  isSelected: _selectedFilter == cat,
                  onTap: () => setState(() {
                    _selectedFilter = cat;
                    _visiblePostCount = 5; // reset load more saat ganti filter
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

  // MOBILE
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
              const Text(
                'FORUM',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
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
                          _visiblePostCount = 5; // reset load more
                        }),
                        selectedColor: const Color(0xFF7A1E1E),
                        labelStyle: TextStyle(
                          color: sel ? Colors.white : Colors.black,
                        ),
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

  // LIST POST + LOAD MORE
  Widget _buildPostList({double paddingHorizontal = 40}) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_filteredPosts.isEmpty) {
      return const Center(child: Text('Belum ada post untuk kategori ini.'));
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: paddingHorizontal, vertical: 24),
      itemCount: _visiblePosts.length + 1, // +1 untuk tombol Load More
      itemBuilder: (ctx, index) {
        // tombol Load More di paling bawah
        if (index == _visiblePosts.length) {
          final hasMore = _visiblePostCount < _filteredPosts.length;
          if (!hasMore) return const SizedBox.shrink();

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _visiblePostCount += 5;
                  });
                },
                child: const Text('Load More'),
              ),
            ),
          );
        }

        final post = _visiblePosts[index];
        final originalIndex = posts.indexOf(post);

        final List<String> likedBy = (() {
          final raw = post['likedBy'];
          if (raw is List) return raw.cast<String>();
          return <String>[];
        })();

        final bool isLiked = likedBy.contains(_currentUsername);
        final int likeCount = (post['likeCount'] as int?) ?? likedBy.length;

        return Column(
          children: [
            _PostCard(
              author: post['author'] ?? '',
              date: post['date'] ?? '',
              title: post['title'] ?? '',
              content: post['content'] ?? '',
              category: post['category'] ?? '',
              isLiked: isLiked,
              likeCount: likeCount,
              onLike: () => _toggleLike(originalIndex),
              canDelete: widget.isAdmin,
              onDelete: widget.isAdmin
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
                    builder: (_) => PostDetailPage(
                    username: _currentUsername,
                    isAdmin: widget.isAdmin,
                    initialPost: post,
                  ),
                  ),
                );
              },
            ),
            const Divider(
              height: 0,
              thickness: 1,
              color: Color(0xFFE0E0E0),
            ),
          ],
        );
      },
    );
  }
}

// ====== KOMPONEN KECIL ======

class _DesktopCategoryItem extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _DesktopCategoryItem({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: onTap,
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            decoration:
                isSelected ? TextDecoration.underline : TextDecoration.none,
          ),
        ),
      ),
    );
  }
}

// Kartu post
class _PostCard extends StatelessWidget {
  final String author;
  final String date;
  final String title;
  final String content;
  final String category;
  final bool isLiked;
  final int likeCount;
  final VoidCallback onLike;
  final bool canDelete;
  final VoidCallback? onDelete;
  final VoidCallback onTapTitle;

  const _PostCard({
    required this.author,
    required this.date,
    required this.title,
    required this.content,
    required this.category,
    required this.isLiked,
    required this.likeCount,
    required this.onLike,
    required this.canDelete,
    this.onDelete,
    required this.onTapTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: author,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.black,
                          ),
                        ),
                        const TextSpan(text: '   '),
                        TextSpan(
                          text: date,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  category,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (canDelete && onDelete != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete, size: 18, color: Colors.redAccent),
                    tooltip: 'Hapus post',
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: onTapTitle,
              child: Text(
                title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Text(content, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  onPressed: onLike,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    size: 18,
                    color: isLiked ? const Color(0xFFB71C1C) : Colors.grey,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '$likeCount',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============ HALAMAN DETAIL + KOMENTAR (MASIH LOKAL) ============

class PostDetailPage extends StatefulWidget {
  final String username;
  final bool isAdmin;
  final Map<String, dynamic> initialPost;

  const PostDetailPage({
    super.key,
    required this.username,
    required this.isAdmin,
    required this.initialPost,
  });

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  Map<String, dynamic>? post;
  List<Map<String, String>> comments = [];
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    post = Map<String, dynamic>.from(widget.initialPost);
    final rawComments = post!['comments'];
    if (rawComments is List) {
      comments = rawComments
          .map((e) => Map<String, String>.from(e as Map))
          .toList();
    } else {
      comments = <Map<String, String>>[];
    }
  }

  void _addComment() {
    if (_commentController.text.trim().isEmpty) return;

    final now = DateTime.now();
    const monthNamesShort = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];

    final dateTimeStr =
        "${now.day.toString().padLeft(2, '0')} ${monthNamesShort[now.month - 1]} ${now.year} "
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    comments.add({
      'author': widget.username,
      'content': _commentController.text.trim(),
      'time': dateTimeStr,
    });

    _commentController.clear();
    setState(() {});
  }

  void _deleteComment(int index) {
    comments.removeAt(index);
    setState(() {});
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (post == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(post!['title'] ?? 'Detail Post'),
      ),
      body: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post!['date'] ?? '',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    post!['title'] ?? '',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(post!['content'] ?? '', style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ),
          const Divider(thickness: 1),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Komentar',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
          Expanded(
            child: comments.isEmpty
                ? const Center(child: Text('Belum ada komentar.'))
                : ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (ctx, i) {
                      final c = comments[i];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            title: Row(
                              children: [
                                Text(
                                  c['author'] ?? '',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  c['time'] ?? '',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(c['content'] ?? ''),
                            ),
                          ),
                          if (widget.isAdmin)
                            Padding(
                            padding: const EdgeInsets.only(left: 16, bottom: 8),
                            child: InkWell(
                              onTap: () => _deleteComment(i),
                              child: const Text(
                                'Delete',
                                style: TextStyle(color: Colors.red, fontSize: 12),
                              ),
                            ),
                          ),
                          const Divider(thickness: 1),
                        ],
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              children: [
                TextField(
                  controller: _commentController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Tulis komentar...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton(
                    onPressed: _addComment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7A1E1E),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Send'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
