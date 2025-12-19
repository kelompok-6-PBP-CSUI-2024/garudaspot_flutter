import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

  // posts berisi map: author, date, title, content, category, likeCount, likedBy, comments
  List<Map<String, dynamic>> posts = [];

  bool _isLoading = false;

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
    final uri = Uri.parse('$_baseUrl/api/posts/');
    final resp = await http.get(uri);

    if (resp.statusCode != 200) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal load posts: ${resp.statusCode} ${resp.reasonPhrase}',
            ),
          ),
        );
      }
      return;
    }

    final decoded = jsonDecode(resp.body);

    // backend kamu mengirim {"results": [ ... ] }
    final List list;
    if (decoded is Map<String, dynamic> && decoded['results'] is List) {
      list = decoded['results'] as List;
    } else {
      // jaga-jaga kalau nanti kamu ubah jadi list langsung
      list = decoded as List;
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
          'likedBy': <String>[],
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
    if (mounted) {
      setState(() => _isLoading = false);
    }
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
                          .map((k) =>
                              DropdownMenuItem(value: k, child: Text(k)))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedKategori = value),
                      validator: (v) =>
                          v == null ? 'Kategori wajib dipilih' : null,
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

  Future<void> _submitPost(BuildContext dialogContext) async {
    if (!_formKey.currentState!.validate()) return;

    final title = _judulController.text.trim();
    final content = _isiController.text.trim();
    final category = _selectedKategori ?? 'Match';

    setState(() => _isLoading = true);

    try {
      final uri = Uri.parse('$_baseUrl/api/posts/');
      final resp = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'author_name': widget.username, // sesuai views Django
          'title': title,
          'content': content,
          'category': category,
        }),
      );

      if (resp.statusCode != 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Gagal buat post: ${resp.statusCode} ${resp.body}',
              ),
            ),
          );
        }
      } else {
        final m = jsonDecode(resp.body) as Map<String, dynamic>;

        // Tambah ke list lokal biar langsung muncul di layar
        setState(() {
          posts.insert(0, {
            'id': m['id'],
            'slug': m['slug'],
            'author': m['author'] ?? '',
            'date': m['date'] ?? '',
            'title': m['title'] ?? '',
            'content': m['content'] ?? '',
            'category': m['category'] ?? '',
            'likeCount': m['like_count'] ?? 0,
            'likedBy': <String>[],
            'comments': <Map<String, String>>[],
          });
          _selectedFilter = 'Semua';
        });

        _judulController.clear();
        _isiController.clear();
        _selectedKategori = null;

        Navigator.of(dialogContext).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error buat post: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ====== LIKE (MASIH LOKAL, BELUM KE BACKEND) ======

  void _toggleLike(int originalIndex) {
    final post = posts[originalIndex];

    final List<String> likedBy;
    final raw = post['likedBy'];
    if (raw is List) {
      likedBy = raw.cast<String>();
    } else {
      likedBy = <String>[];
    }

    if (likedBy.contains(widget.username)) {
      likedBy.remove(widget.username);
    } else {
      likedBy.add(widget.username);
    }

    posts[originalIndex]['likedBy'] = likedBy;
    posts[originalIndex]['likeCount'] = likedBy.length;

    setState(() {});
  }

  // ====== UI ======

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
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
              IconButton(
                onPressed: _openPostDialog,
                icon: const Icon(Icons.add_comment_outlined),
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
                  onTap: () => setState(() => _selectedFilter = cat),
                ),
            ],
          ),
        ),

        // Area konten
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
        // Header FORUM + filter
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
                        onSelected: (_) => setState(() => _selectedFilter = cat),
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

  // LIST POST
  Widget _buildPostList({double paddingHorizontal = 40}) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_filteredPosts.isEmpty) {
      return const Center(child: Text('Belum ada post untuk kategori ini.'));
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: paddingHorizontal, vertical: 24),
      itemCount: _filteredPosts.length,
      itemBuilder: (ctx, index) {
        final post = _filteredPosts[index];

        // index asli di list posts
        final originalIndex = posts.indexOf(post);

        final List<String> likedBy = (() {
          final raw = post['likedBy'];
          if (raw is List) return raw.cast<String>();
          return <String>[];
        })();

        final bool isLiked = likedBy.contains(widget.username);
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
              onDelete: null, // belum implement delete ke backend
              onTapTitle: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PostDetailPage(
                      username: widget.username,
                      initialPost: post,
                    ),
                  ),
                );
                // kalau nanti ada API comment/like di backend, bisa panggil _loadPostsFromApi();
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
            // Header: author + date + category + delete (kalau admin)
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
                        const TextSpan(
                          text: '   ',
                          style: TextStyle(color: Colors.black),
                        ),
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
                    icon: const Icon(
                      Icons.delete,
                      size: 18,
                      color: Colors.redAccent,
                    ),
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
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: const TextStyle(fontSize: 14),
            ),
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
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
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
  final Map<String, dynamic> initialPost;

  const PostDetailPage({
    super.key,
    required this.username,
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

    final dateTimeStr =
        "${now.day.toString().padLeft(2, '0')} ${monthNamesShort[now.month - 1]} ${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    final name = widget.username;

    comments.add({
      'author': name,
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
          // Konten post (tanggal dulu, lalu judul, lalu isi)
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
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    post!['content'] ?? '',
                    style: const TextStyle(fontSize: 14),
                  ),
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
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  c['time'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(c['content'] ?? ''),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 16, bottom: 8),
                            child: InkWell(
                              onTap: () => _deleteComment(i),
                              child: const Text(
                                'Delete',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
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
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
