import 'package:flutter/material.dart';

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
      comments = rawComments.map((e) => Map<String, String>.from(e as Map)).toList();
    } else {
      comments = <Map<String, String>>[];
    }
  }

  void _addComment() {
    if (_commentController.text.trim().isEmpty) return;

    final now = DateTime.now();
    const monthNamesShort = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];

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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text(post!['title'] ?? 'Detail Post')),
      body: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(post!['date'] ?? '', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Text(post!['title'] ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
              child: Text('Komentar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                                Text(c['author'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(width: 8),
                                Text(c['time'] ?? '', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(c['content'] ?? ''),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 16, bottom: 8),
                            child: InkWell(
                              onTap: () => _deleteComment(i),
                              child: const Text('Delete', style: TextStyle(color: Colors.red, fontSize: 12)),
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
