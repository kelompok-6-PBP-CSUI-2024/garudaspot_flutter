import 'package:flutter/material.dart';
import 'package:garudaspot_flutter/tiket/services/ticket_service.dart';
import 'package:garudaspot_flutter/tiket/models/ticket_link.dart';
import 'package:garudaspot_flutter/tiket/models/ticket_match.dart';
import 'package:garudaspot_flutter/tiket/widgets/ticket_link_create.dart';
import 'package:garudaspot_flutter/tiket/widgets/ticket_match_create.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class TicketDetailsPage extends StatefulWidget {
  const TicketDetailsPage({
    super.key,
    required this.matchUuid,
    this.initialMatch,
    this.canManage = false,
  });

  final String matchUuid;
  final TicketMatch? initialMatch;
  final bool canManage;

  @override
  State<TicketDetailsPage> createState() => _TicketDetailsPageState();
}

class _TicketDetailsPageState extends State<TicketDetailsPage> {
  final TicketApiService _service = TicketApiService();
  TicketMatch? _match;
  bool _loading = true;
  String? _error;
  bool _openingLink = false;

  @override
  void initState() {
    super.initState();
    _match = widget.initialMatch;
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final detail = await _service.fetchMatchDetail(widget.matchUuid);
      setState(() {
        _match = detail;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    const primaryRed = Color(0xFFE11D2A);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text('Ticket Detail', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (widget.canManage && _match != null) ...[
            IconButton(
              onPressed: () => _openEdit(request),
              icon: const Icon(Icons.edit_outlined, color: Colors.black),
              tooltip: 'Edit',
            ),
            IconButton(
              onPressed: () => _openAddLink(request),
              icon: const Icon(Icons.add_link, color: Colors.black),
              tooltip: 'Add Link',
            ),
            IconButton(
              onPressed: () => _confirmDeleteMatch(request),
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              tooltip: 'Delete',
            ),
          ],
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDetail,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            if (_loading) const Center(child: CircularProgressIndicator()),
            if (!_loading && _error != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: _cardDecoration(),
                child: Text('Failed to load ticket: $_error', style: const TextStyle(color: Colors.red)),
              ),
            if (!_loading && _match != null) ...[
              _buildHeaderCard(_match!, primaryRed),
              const SizedBox(height: 16),
              _buildLinksGrid(_match!, request),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(TicketMatch match, Color primaryRed) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _avatar(match.imgTeam1),
              const SizedBox(width: 8),
              Text(
                match.team1,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF111827)),
              ),
              const SizedBox(width: 10),
              const Text('vs', style: TextStyle(color: Color(0xFF6B7280))),
              const SizedBox(width: 10),
              Text(
                match.team2,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF111827)),
              ),
              const SizedBox(width: 8),
              _avatar(match.imgTeam2),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _formatDate(match.date) + (match.place != null ? ' · ${match.place}' : ''),
            style: const TextStyle(color: Color(0xFF4B5563)),
            textAlign: TextAlign.center,
          ),
          if (match.imgCup != null && match.imgCup!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Image.network(
              match.imgCup!,
              height: 48,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLinksGrid(TicketMatch match, CookieRequest request) {
    final links = match.links;
    if (links.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration(),
        child: const Text('No links yet.', style: TextStyle(color: Color(0xFF6B7280))),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        int columns = 1;
        if (constraints.maxWidth >= 900) {
          columns = 3;
        } else if (constraints.maxWidth >= 640) {
          columns = 2;
        }
        return GridView.builder(
          itemCount: links.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.3, // wider than tall, tighter cards
          ),
          itemBuilder: (context, index) {
            final link = links[index];
            return InkWell(
              onTap: () => _openVendorLink(link.vendorLink),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: _cardDecoration(),
                child: Row(
                  children: [
                    if (link.imgVendor.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          link.imgVendor,
                          width: 36,
                          height: 36,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.store, color: Color(0xFFB91C1C)),
                        ),
                      ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            link.vendor,
                            style: const TextStyle(
                              color: Color(0xFFB91C1C),
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _formatPrice(link.price),
                            style: const TextStyle(color: Color(0xFF4B5563), fontSize: 12.5),
                          ),
                        ],
                      ),
                    ),
                    if (widget.canManage)
                      IconButton(
                        onPressed: () => _confirmDeleteLink(request, link),
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFE5E7EB)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  String _formatDate(DateTime d) => d.toIso8601String().split('T').first;

  String _formatPrice(int price) {
    final raw = price.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < raw.length; i++) {
      final posFromEnd = raw.length - i;
      buffer.write(raw[i]);
      if (posFromEnd > 1 && posFromEnd % 3 == 1) buffer.write('.');
    }
    return 'Rp$buffer';
  }

  Widget _avatar(String url) {
    return CircleAvatar(
      radius: 18,
      backgroundImage: NetworkImage(url),
      backgroundColor: const Color(0xFFE5E7EB),
      onBackgroundImageError: (_, __) {},
    );
  }

  Future<void> _openVendorLink(String rawUrl) async {
    if (_openingLink) return;
    final trimmed = rawUrl.trim();
    if (trimmed.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No link available')),
        );
      }
      return;
    }

    final withScheme = trimmed.startsWith('http') ? trimmed : 'https://$trimmed';
    final uri = Uri.tryParse(withScheme);
    if (uri == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid link')),
        );
      }
      return;
    }

    setState(() => _openingLink = true);
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open link')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open link')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _openingLink = false);
      } else {
        _openingLink = false;
      }
    }
  }

  Future<void> _openAddLink(CookieRequest request) async {
    if (!widget.canManage) return;
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: TicketLinkForm(
            onSubmit: (payload) async {
              return _service.createLink(
                request: request,
                matchUuid: widget.matchUuid,
                payload: payload,
              );
            },
          ),
        ),
      ),
    );
    if (result == true) {
      await _loadDetail();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Link added')),
        );
      }
    }
  }

  Future<void> _openEdit(CookieRequest request) async {
    final existing = _match;
    if (!widget.canManage || existing == null) return;
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: TicketMatchForm(
            initial: existing,
            onSubmit: (payload) async {
              return _service.updateMatch(
                request: request,
                matchUuid: widget.matchUuid,
                payload: payload,
              );
            },
          ),
        ),
      ),
    );
    if (result == true) {
      await _loadDetail();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ticket updated')),
        );
      }
    }
  }

  Future<void> _confirmDeleteMatch(CookieRequest request) async {
    if (!widget.canManage) return;
    final match = _match;
    if (match == null) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete ticket?'),
        content: Text('Remove ${match.team1} vs ${match.team2}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (ok == true) {
      final success = await _service.deleteMatch(request: request, matchUuid: widget.matchUuid);
      if (success && mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ticket deleted')),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete ticket')),
        );
      }
    }
  }

  Future<void> _confirmDeleteLink(CookieRequest request, TicketLink link) async {
    if (!widget.canManage) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete link?'),
        content: Text('Remove ${link.vendor}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (ok == true) {
      final success = await _service.deleteLink(request: request, linkUuid: link.linkId);
      if (success) {
        await _loadDetail();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Link deleted')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete link')),
          );
        }
      }
    }
  }
}
