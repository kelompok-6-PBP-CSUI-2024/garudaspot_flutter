import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../right_drawer.dart';
import 'model/merch.dart';

const String _proxyBase = 'http://localhost:8000/proxy-image/?url=';

class MerchPage extends StatefulWidget {
  const MerchPage({super.key});

  @override
  State<MerchPage> createState() => _MerchPageState();
}

class _MerchPageState extends State<MerchPage> {
  static const String _apiUrl = 'http://localhost:8000/merch/json/';
  late Future<List<Merch>> _futureMerch;

  @override
  void initState() {
    super.initState();
    _futureMerch = _fetchMerch();
  }

  Future<List<Merch>> _fetchMerch() async {
    final response = await http.get(
      Uri.parse(_apiUrl),
      headers: const {'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch merch (${response.statusCode})');
    }

    return merchListFromJson(utf8.decode(response.bodyBytes));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Merch')),
      endDrawer: const RightDrawer(),
      body: FutureBuilder<List<Merch>>(
        future: _futureMerch,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat merch: ${snapshot.error}'));
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const Center(child: Text('Belum ada merch.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final merch = items[index];
              return ListTile(
                leading: merch.thumbnail.isNotEmpty
                    ? Image.network(
                        '$_proxyBase${Uri.encodeComponent(merch.thumbnail)}',
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.image_not_supported),
                      )
                    : const Icon(Icons.shopping_bag_outlined),
                title: Text(merch.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${merch.vendor} • ${merch.category}'),
                    Text('Harga: ${merch.price} • Stok: ${merch.stock}'),
                    if (merch.link.isNotEmpty)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () => _openLink(merch.link),
                          child: const Text('Shop Now (Visit Vendor)'),
                        ),
                      ),
                  ],
                ),
                onTap: () => _showDetail(context, merch),
              );
            },
          );
        },
      ),
    );
  }
}

Future<void> _openLink(String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null) {
    return;
  }
  await launchUrl(
    uri,
    mode: LaunchMode.externalApplication,
  );
}

void _showDetail(BuildContext context, Merch merch) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(merch.name),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (merch.thumbnail.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Image.network(
                  '$_proxyBase${Uri.encodeComponent(merch.thumbnail)}',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.image_not_supported, size: 64),
                ),
              ),
            Text('Vendor: ${merch.vendor}'),
            Text('Kategori: ${merch.category}'),
            Text('Harga: ${merch.price}'),
            Text('Stok: ${merch.stock}'),
            const SizedBox(height: 8),
            Text(
              merch.description.isNotEmpty
                  ? merch.description
                  : 'Tidak ada deskripsi.',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Tutup'),
        ),
        if (merch.link.isNotEmpty)
          TextButton(
            onPressed: () => _openLink(merch.link),
            child: const Text('Shop Now (Visit Vendor)'),
          ),
      ],
    ),
  );
}
