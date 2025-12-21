import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

class PostDetailPage extends StatefulWidget {
  final String username;
  final bool isAdmin; // Tetap simpan sebagai cadangan
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
  static const String _baseUrl = 'https://hasanul-muttaqin-garudaspot.pbp.cs.ui.ac.id/forum';

  Map<String, dynamic>? post;
  List<Map<String, dynamic>> comments = [];
  final TextEditingController _commentController = TextEditingController();
  bool _isLoading = false;

  // GETTER BARU: Mengambil status admin langsung dari session CookieRequest
  bool get _isAdminStatus {
    final request = context.read<CookieRequest>();
    // Cek field 'is_superuser' di jsonData yang dikembalikan Django saat login
    return request.jsonData['is_superuser'] ?? widget.isAdmin;
  }

  String get _currentUsername {
    final request = context.read<CookieRequest>();
    final u = request.jsonData['username'];
    if (u is String && u.isNotEmpty) return u;
    if (widget.username.isNotEmpty) return widget.username;
    return 'Guest';
  }

  @override
  void initState() {
    super.initState();
    post = Map<String, dynamic>.from(widget.initialPost);
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    final slug = (post?['slug'] ?? '').toString();
    if (slug.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final request = context.read<CookieRequest>();
      final resp = await request.get('$_baseUrl/api/posts/$slug/');

      if (resp is Map<String, dynamic>) {
        setState(() {
          post = Map<String, dynamic>.from(resp['post']);
          comments = List<Map<String, dynamic>>.from(resp['comments']);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _addComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final slug = (post?['slug'] ?? '').toString();
    try {
      final request = context.read<CookieRequest>();
      final resp = await request.postJson(
        '$_baseUrl/api/posts/$slug/comments/',
        jsonEncode({
          'content': text,
          'author': _currentUsername,
        }),
      );

      if (resp['id'] != null) {
        _commentController.clear();
        await _loadDetail();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengirim komentar: $e')),
        );
      }
    }
  }

  Future<void> _deleteComment(int commentId) async {
    if (!_isAdminStatus) return; // Gunakan getter baru

    try {
      final request = context.read<CookieRequest>();
      final resp = await request.postJson(
        '$_baseUrl/api/comments/$commentId/delete/',
        jsonEncode({
          'is_admin': _isAdminStatus,
        }),
      );

      if (resp['ok'] == true) {
        await _loadDetail();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Komentar berhasil dihapus')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error hapus komentar: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (post == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(post!['title'] ?? 'Detail Post'),
      ),
      body: _isLoading && comments.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(post!['date'] ?? '', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              const SizedBox(height: 8),
                              Text(post!['title'] ?? '', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 12),
                              Text(post!['content'] ?? '', style: const TextStyle(fontSize: 16)),
                            ],
                          ),
                        ),
                        const Divider(thickness: 1),
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('Komentar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        ),
                        if (comments.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: Text('Belum ada komentar.')),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: comments.length,
                            itemBuilder: (ctx, i) {
                              final c = comments[i];
                              final id = c['id'];
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ListTile(
                                    title: Row(
                                      children: [
                                        Text(c['author'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                                        const SizedBox(width: 8),
                                        Text(c['time'] ?? '', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                      ],
                                    ),
                                    subtitle: Text(c['content'] ?? ''),
                                  ),
                                  // GUNAKAN GETTER _isAdminStatus DI SINI
                                  if (_isAdminStatus && id is int)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 16, bottom: 8),
                                      child: InkWell(
                                        onTap: () => _deleteComment(id),
                                        child: const Text(
                                          'Delete',
                                          style: TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  const Divider(height: 1),
                                ],
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                // Input Komentar ... (sama seperti sebelumnya)
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: const InputDecoration(hintText: 'Tulis komentar...'),
                        ),
                      ),
                      IconButton(
                        onPressed: _addComment,
                        icon: const Icon(Icons.send, color: Color(0xFF7A1E1E)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
