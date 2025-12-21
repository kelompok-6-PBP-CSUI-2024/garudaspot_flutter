import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../model/forum_post.dart';

class ForumService {

  static String get baseUrl {
    if (kIsWeb) return 'https://hasanul-muttaqin-garudaspot.pbp.cs.ui.ac.id/forum';
    return 'https://hasanul-muttaqin-garudaspot.pbp.cs.ui.ac.id/forum';
  }

  Future<List<ForumPost>> fetchPosts() async {
    final uri = Uri.parse('$baseUrl/api/posts/');
    final resp = await http.get(uri);

    if (resp.statusCode != 200) {
      throw Exception('Gagal load posts: ${resp.statusCode} ${resp.body}');
    }

    final decoded = jsonDecode(resp.body);

    final List list;
    if (decoded is Map<String, dynamic> && decoded['results'] is List) {
      list = decoded['results'] as List;
    } else if (decoded is List) {
      list = decoded;
    } else {
      throw Exception('Format response tidak dikenali: ${resp.body}');
    }

    return list
        .map((e) => ForumPost.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<ForumPost> createPost({
    required String authorName,
    required String title,
    required String content,
    required String category,
  }) async {
    final uri = Uri.parse('$baseUrl/api/posts/');
    final resp = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
      'author': authorName,
      'title': title,
      'content': content,
      'category': category,
    }),
    );

    if (resp.statusCode != 201) {
      final isJson = resp.headers['content-type']?.contains('application/json') == true;
      final bodyPreview = isJson
          ? resp.body
          : 'Server error (non-JSON). Cek terminal Django. Status: ${resp.statusCode}';
      throw Exception('Gagal buat post: $bodyPreview');
    }

    final m = jsonDecode(resp.body) as Map<String, dynamic>;
    return ForumPost.fromJson(m);
  }
}
