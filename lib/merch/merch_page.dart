import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../right_drawer.dart';
import 'merch_header.dart';
import 'merch_detail_page.dart';
import 'model/merch.dart';

const String _proxyBase = 'https://hasanul-muttaqin-garudaspot.pbp.cs.ui.ac.id/proxy-image/?url=';

class MerchPage extends StatefulWidget {
  const MerchPage({super.key, this.isAdmin = false, this.isSuperuser = false});

  final bool isAdmin;
  final bool isSuperuser;

  @override
  State<MerchPage> createState() => _MerchPageState();
}

class _MerchPageState extends State<MerchPage> {
  static const String _apiUrl = 'https://hasanul-muttaqin-garudaspot.pbp.cs.ui.ac.id/merch/json/';
  late Future<List<Merch>> _futureMerch;
  String _selectedFilter = 'All';
  String _selectedSort = 'recent';
  bool get _canManage => widget.isAdmin || widget.isSuperuser;

  static const Map<String, String> _filterOptions = {
    'All': 'All Merch',
    'Keychain': 'Keychain',
    'Jersey': 'Jersey',
    'Jacket': 'Jacket',
    'Hoodie': 'Hoodie',
    'Cap': 'Cap',
    'Scarf': 'Scarf',
    'Others': 'Others',
  };

  static const Map<String, String> _sortOptions = {
    'recent': 'Recently Added',
    'price_asc': 'Price: Low → High',
    'price_desc': 'Price: High → Low',
    'popular': 'Most Popular',
  };

  static const List<String> _categoryOptions = [
    'keychain',
    'jersey',
    'jacket',
    'hoodie',
    'cap',
    'scarf',
    'others',
  ];

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
    final request = context.watch<CookieRequest>();
    final isAdmin = request.jsonData['is_admin'] == true || widget.isAdmin;

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
            ),
            const SizedBox(width: 8),
            const Text(
              'GarudaSpot',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        actions: [
          if (_canManage)
            IconButton(
              onPressed: () => _openAddDialog(request),
              icon: const Icon(Icons.add, color: Colors.black),
              tooltip: 'Add Merch',
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
      body: Container(
        color: Colors.white,
        child: FutureBuilder<List<Merch>>(
          future: _futureMerch,
          builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat merch: ${snapshot.error}'));
          }
          final rawItems = snapshot.data ?? [];
          if (rawItems.isEmpty) {
            return const Center(child: Text('Belum ada merch.'));
          }
          final items = _applyFilterSort(rawItems);
          return Column(
            children: [
              const MerchHeader(),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.red.shade700,
                              width: 2,
                            ),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedFilter,
                            isExpanded: true,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                            items: _filterOptions.entries
                                .map(
                                  (entry) => DropdownMenuItem(
                                    value: entry.key,
                                    child: Text(
                                      entry.value,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                            dropdownColor: Colors.white,
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() => _selectedFilter = value);
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.red.shade700,
                              width: 2,
                            ),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedSort,
                            isExpanded: true,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                            items: _sortOptions.entries
                                .map(
                                  (entry) => DropdownMenuItem(
                                    value: entry.key,
                                    child: Text(
                                      entry.value,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                            dropdownColor: Colors.white,
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() => _selectedSort = value);
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: items.isEmpty
                    ? const Center(
                        child: Text('Tidak ada hasil untuk filter ini.'),
                      )
                    : ListView.separated(
                        padding: EdgeInsets.zero,
                        itemCount: items.length,
                        separatorBuilder: (_, __) => Divider(
                          height: 1,
                          color: Colors.grey.shade200,
                        ),
                        itemBuilder: (context, index) {
                          final merch = items[index];
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
                                  MaterialPageRoute(
                                    builder: (_) => MerchDetailPage(
                                      merch: merch,
                                      isAdmin: _canManage,
                                      onEdit: () => _openEditDialog(
                                        request: request,
                                        merch: merch,
                                      ),
                                      onDelete: () => _confirmDelete(
                                        request: request,
                                        merch: merch,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          if (merch.thumbnail.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(right: 12),
                                              child: Image.network(
                                                '$_proxyBase${Uri.encodeComponent(merch.thumbnail)}',
                                                width: 56,
                                                height: 56,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) =>
                                                    const Icon(Icons.image_not_supported),
                                              ),
                                            )
                                          else
                                            const Padding(
                                              padding: EdgeInsets.only(right: 12),
                                              child: Icon(Icons.shopping_bag_outlined),
                                            ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  merch.name,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  '${merch.vendor} • ${_capitalize(merch.category)}',
                                                  style: const TextStyle(
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                      Text(
                                        'Rp ${_formatPrice(merch.price)}',
                                        style: TextStyle(
                                          color: Colors.red.shade700,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Stok: ${merch.stock}',
                                        style: const TextStyle(color: Colors.black54),
                                      ),
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
                                                child: const Text(
                                                  'Shop Now (Visit Vendor)',
                                                ),
                                              ),
                                            if (_canManage)
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.grey.shade400,
                                                  foregroundColor: Colors.black87,
                                                ),
                                                onPressed: () => _openEditDialog(
                                                  request: request,
                                                  merch: merch,
                                                ),
                                                child: const Text('Edit'),
                                              ),
                                            if (_canManage)
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red.shade700,
                                                  foregroundColor: Colors.white,
                                                ),
                                                onPressed: () => _confirmDelete(
                                                  request: request,
                                                  merch: merch,
                                                ),
                                                child: const Text('Delete'),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
          },
        ),
      ),
    );
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

  void _openEditDialog({required CookieRequest request, required Merch merch}) {
    if (!_canManage) return;
    final nameC = TextEditingController(text: merch.name);
    final vendorC = TextEditingController(text: merch.vendor);
    final priceC = TextEditingController(text: merch.price.toString());
    final stockC = TextEditingController(text: merch.stock.toString());
    final thumbnailC = TextEditingController(text: merch.thumbnail);
    final linkC = TextEditingController(text: merch.link);
    final descriptionC = TextEditingController(text: merch.description);
    String selectedCategory = _categoryOptions.contains(merch.category)
        ? merch.category
        : 'others';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Merch'),
        content: SingleChildScrollView(
          child: StatefulBuilder(
            builder: (context, setDialogState) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameC,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: vendorC,
                  decoration: const InputDecoration(labelText: 'Vendor'),
                ),
                TextField(
                  controller: priceC,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Price'),
                ),
                TextField(
                  controller: stockC,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Stock'),
                ),
                TextField(
                  controller: thumbnailC,
                  decoration: const InputDecoration(labelText: 'Thumbnail URL'),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: selectedCategory,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: _categoryOptions
                      .map(
                        (value) => DropdownMenuItem(
                          value: value,
                          child: Text(_capitalize(value)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setDialogState(() => selectedCategory = value);
                  },
                ),
                TextField(
                  controller: linkC,
                  decoration: const InputDecoration(labelText: 'Product Link'),
                ),
                TextField(
                  controller: descriptionC,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _submitEdit(
                request: request,
                merchId: merch.id,
                name: nameC.text,
                vendor: vendorC.text,
                price: priceC.text,
                stock: stockC.text,
                thumbnail: thumbnailC.text,
                category: selectedCategory,
                link: linkC.text,
                description: descriptionC.text,
              );
              if (mounted) {
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _openAddDialog(CookieRequest request) {
    if (!_canManage) return;
    final nameC = TextEditingController();
    final vendorC = TextEditingController();
    final priceC = TextEditingController(text: '0');
    final stockC = TextEditingController(text: '0');
    final thumbnailC = TextEditingController();
    final linkC = TextEditingController();
    final descriptionC = TextEditingController();
    String selectedCategory = _categoryOptions.first;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Merch'),
        content: SingleChildScrollView(
          child: StatefulBuilder(
            builder: (context, setDialogState) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameC,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: vendorC,
                  decoration: const InputDecoration(labelText: 'Vendor'),
                ),
                TextField(
                  controller: priceC,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Price'),
                ),
                TextField(
                  controller: stockC,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Stock'),
                ),
                TextField(
                  controller: thumbnailC,
                  decoration: const InputDecoration(labelText: 'Thumbnail URL'),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: selectedCategory,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: _categoryOptions
                      .map(
                        (value) => DropdownMenuItem(
                          value: value,
                          child: Text(_capitalize(value)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setDialogState(() => selectedCategory = value);
                  },
                ),
                TextField(
                  controller: linkC,
                  decoration: const InputDecoration(labelText: 'Product Link'),
                ),
                TextField(
                  controller: descriptionC,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _submitCreate(
                request: request,
                name: nameC.text,
                vendor: vendorC.text,
                price: priceC.text,
                stock: stockC.text,
                thumbnail: thumbnailC.text,
                category: selectedCategory,
                link: linkC.text,
                description: descriptionC.text,
              );
              if (mounted) {
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitCreate({
    required CookieRequest request,
    required String name,
    required String vendor,
    required String price,
    required String stock,
    required String thumbnail,
    required String category,
    required String link,
    required String description,
  }) async {
    if (!_canManage) return;
    try {
      await request.post(
        "https://hasanul-muttaqin-garudaspot.pbp.cs.ui.ac.id/merch/api/create/",
        {
          "name": name,
          "vendor": vendor,
          "price": price,
          "stock": stock,
          "thumbnail": thumbnail,
          "category": category,
          "link": link,
          "description": description,
          "is_admin": _canManage ? "true" : "false",
        },
      );
      if (mounted) {
        setState(() {
          _futureMerch = _fetchMerch();
        });
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Merch created')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create merch: $e')),
        );
      }
    }
  }

  Future<void> _submitEdit({
    required CookieRequest request,
    required int merchId,
    required String name,
    required String vendor,
    required String price,
    required String stock,
    required String thumbnail,
    required String category,
    required String link,
    required String description,
  }) async {
    if (!_canManage) return;
    try {
      await request.post(
        "https://hasanul-muttaqin-garudaspot.pbp.cs.ui.ac.id/merch/api/update/$merchId/",
        {
          "name": name,
          "vendor": vendor,
          "price": price,
          "stock": stock,
          "thumbnail": thumbnail,
          "category": category,
          "link": link,
          "description": description,
          "is_admin": _canManage ? "true" : "false",
        },
      );
      if (mounted) {
        setState(() {
          _futureMerch = _fetchMerch();
        });
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Merch updated')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update merch: $e')),
        );
      }
    }
  }

  Future<void> _confirmDelete({
    required CookieRequest request,
    required Merch merch,
  }) async {
    if (!_canManage) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Merch?'),
        content: Text('"${merch.name}" akan dihapus. Lanjutkan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _deleteMerch(request: request, merchId: merch.id);
    }
  }

  Future<void> _deleteMerch({
    required CookieRequest request,
    required int merchId,
  }) async {
    if (!_canManage) return;
    try {
      await request.post(
        "https://hasanul-muttaqin-garudaspot.pbp.cs.ui.ac.id/merch/api/delete/$merchId/",
        {
          "is_admin": _canManage ? "true" : "false",
        },
      );
      if (mounted) {
        setState(() {
          _futureMerch = _fetchMerch();
        });
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Merch deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete merch: $e')),
        );
      }
    }
  }

  List<Merch> _applyFilterSort(List<Merch> items) {
    Iterable<Merch> filtered = items;
    if (_selectedFilter != 'All') {
      filtered = filtered.where((m) => m.category == _selectedFilter);
    }

    final sorted = filtered.toList();
    switch (_selectedSort) {
      case 'price_asc':
        sorted.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_desc':
        sorted.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'popular':
        sorted.sort((a, b) => b.viewCount.compareTo(a.viewCount));
        break;
      case 'recent':
      default:
        sorted.sort((a, b) => b.id.compareTo(a.id));
        break;
    }
    return sorted;
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
