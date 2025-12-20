import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'model/merch.dart';

const String _proxyBase = 'http://localhost:8000/proxy-image/?url=';

class MerchDetailPage extends StatelessWidget {
  const MerchDetailPage({
    super.key,
    required this.merch,
    bool? isAdmin,
    required this.onEdit,
    required this.onDelete,
  }) : isAdmin = isAdmin ?? false;

  final Merch merch;
  final bool isAdmin;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text(merch.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (merch.thumbnail.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Image.network(
                  '$_proxyBase${Uri.encodeComponent(merch.thumbnail)}',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.image_not_supported, size: 64),
                ),
              ),
            Text('Vendor: ${merch.vendor}'),
            Text('Kategori: ${_capitalize(merch.category)}'),
            Text('Harga: Rp ${_formatPrice(merch.price)}'),
            Text('Stok: ${merch.stock}'),
            const SizedBox(height: 12),
            Text(
              merch.description.isNotEmpty
                  ? merch.description
                  : 'Tidak ada deskripsi.',
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                children: [
                  if (merch.link.isNotEmpty)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => _openLink(merch.link),
                      child: const Text('Shop Now (Visit Vendor)'),
                    ),
                  if (isAdmin)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade400,
                        foregroundColor: Colors.black87,
                      ),
                      onPressed: onEdit,
                      child: const Text('Edit'),
                    ),
                  if (isAdmin)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: onDelete,
                      child: const Text('Delete'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatPrice(int value) {
  final raw = value.toString();
  return raw.replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (match) => '${match[1]}.',
  );
}

String _capitalize(String value) {
  if (value.isEmpty) return value;
  return value[0].toUpperCase() + value.substring(1);
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
