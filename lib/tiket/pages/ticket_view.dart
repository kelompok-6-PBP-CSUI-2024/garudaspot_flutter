import 'package:flutter/material.dart';
import 'package:garudaspot_flutter/right_drawer.dart';
import 'package:garudaspot_flutter/tiket/pages/ticket_details.dart';
import 'package:garudaspot_flutter/tiket/services/ticket_service.dart';
import 'package:garudaspot_flutter/tiket/models/ticket_link.dart';
import 'package:garudaspot_flutter/tiket/models/ticket_match.dart';
import 'package:garudaspot_flutter/tiket/widgets/ticket_link_create.dart';
import 'package:garudaspot_flutter/tiket/widgets/ticket_match_create.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class TicketViewPage extends StatefulWidget {
  const TicketViewPage({
    super.key,
    this.isAdmin = false,
    this.isSuperuser = false,
  });

  final bool isAdmin;
  final bool isSuperuser;

  bool get canManage => isAdmin || isSuperuser;

  @override
  State<TicketViewPage> createState() => _TicketViewPageState();
}

class _TicketViewPageState extends State<TicketViewPage> {
  final TicketApiService _service = TicketApiService();
  final List<TicketMatch> _matches = [];
  bool _loading = true;
  bool _refreshing = false;
  String? _error;
  String _sortKey = 'date_desc';

  @override
  void initState() {
    super.initState();
    _loadMatches();
  }

  Future<void> _loadMatches() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _service.fetchMatches();
      setState(() {
        _matches
          ..clear()
          ..addAll(data);
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
        _refreshing = false;
      });
    }
  }

  List<TicketMatch> get _sortedMatches {
    final sorted = [..._matches];
    int cmp<T extends Comparable>(T a, T b) => a.compareTo(b);
    switch (_sortKey) {
      case 'date_asc':
        sorted.sort((a, b) => cmp(a.date, b.date));
        break;
      case 'date_desc':
        sorted.sort((a, b) => cmp(b.date, a.date));
        break;
      case 'id_asc':
        sorted.sort((a, b) => cmp(a.id ?? 0, b.id ?? 0));
        break;
      case 'id_desc':
        sorted.sort((a, b) => cmp(b.id ?? 0, a.id ?? 0));
        break;
      case 'uuid_asc':
        sorted.sort((a, b) => cmp(a.matchId, b.matchId));
        break;
      case 'uuid_desc':
        sorted.sort((a, b) => cmp(b.matchId, a.matchId));
        break;
      default:
        break;
    }
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    const primaryRed = Color(0xFFE11D2A);

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
              errorBuilder: (_, __, ___) => const Icon(Icons.confirmation_num_outlined, color: Colors.red),
            ),
            const SizedBox(width: 8),
            const Text(
              'Garuda Spot',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        actions: [
          Builder(
            builder: (ctx) => IconButton(
              onPressed: () => Scaffold.of(ctx).openEndDrawer(),
              icon: const Icon(Icons.menu, color: Colors.black),
              tooltip: 'Menu',
            ),
          ),
          if (widget.canManage)
            IconButton(
              onPressed: () => _openMatchForm(request),
              icon: const Icon(Icons.add, color: Colors.black),
              tooltip: 'Create Ticket',
            ),
          const SizedBox(width: 4),
        ],
      ),
      endDrawer: RightDrawer(
        isAdmin: widget.isAdmin,
        isSuperuser: widget.isSuperuser,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _refreshing = true;
          });
          await _loadMatches();
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          children: [
            const SizedBox(height: 4),
            const Text(
              'Browsing Dan Pembelian Tiket',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 12),
            _buildControls(primaryRed, request),
            const SizedBox(height: 12),
            _buildContent(request),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildControls(Color primaryRed, CookieRequest request) {
    return Row(
      children: [
        if (widget.canManage)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryRed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => _openMatchForm(request),
            child: const Text('Create Ticket'),
          ),
        if (widget.canManage) const SizedBox(width: 12),
        SizedBox(
          width: 220,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFB91C1C), width: 2)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _sortKey,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 'date_desc', child: Text('Date: Newest')),
                  DropdownMenuItem(value: 'date_asc', child: Text('Date: Oldest')),
                  DropdownMenuItem(value: 'id_desc', child: Text('ID: High to Low')),
                  DropdownMenuItem(value: 'id_asc', child: Text('ID: Low to High')),
                  DropdownMenuItem(value: 'uuid_desc', child: Text('UUID: Z-A')),
                  DropdownMenuItem(value: 'uuid_asc', child: Text('UUID: A-Z')),
                ],
                onChanged: (val) {
                  if (val == null) return;
                  setState(() {
                    _sortKey = val;
                  });
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(CookieRequest request) {
    if (_loading && !_refreshing) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration(),
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration(),
        child: Text(
          'Failed to load tickets: $_error',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }
    if (_matches.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration(),
        child: const Text('No tickets yet.', style: TextStyle(color: Color(0xFF6B7280))),
      );
    }

    final items = _sortedMatches;
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 520 ? 2 : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.05,
          ),
          itemBuilder: (context, index) {
            final m = items[index];
            return _TicketCard(
              match: m,
              canManage: widget.canManage,
              onView: () => _openDetail(m),
              onEdit: widget.canManage ? () => _openMatchForm(request, match: m) : null,
              onDelete: widget.canManage ? () => _confirmDeleteMatch(request, m) : null,
              onAddLink: widget.canManage ? () => _openLinkForm(request, m) : null,
              onDeleteLink: widget.canManage
                  ? (link) => _confirmDeleteLink(request: request, link: link, match: m)
                  : null,
            );
          },
        );
      },
    );
  }

  void _openDetail(TicketMatch match) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TicketDetailsPage(
          matchUuid: match.matchId,
          initialMatch: match,
          canManage: widget.canManage,
        ),
      ),
    );
  }

  Future<void> _openMatchForm(CookieRequest request, {TicketMatch? match}) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: TicketMatchForm(
            initial: match,
            onSubmit: (payload) async {
              if (!widget.canManage) return false;
              if (match == null) {
                return _service.createMatch(request: request, payload: payload);
              }
              return _service.updateMatch(
                request: request,
                matchUuid: match.matchId,
                payload: payload,
              );
            },
          ),
        ),
      ),
    );

    if (result == true) {
      await _loadMatches();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(match == null ? 'Ticket created' : 'Ticket updated')),
        );
      }
    }
  }

  Future<void> _openLinkForm(CookieRequest request, TicketMatch match) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: TicketLinkForm(
            onSubmit: (payload) async {
              if (!widget.canManage) return false;
              return _service.createLink(
                request: request,
                matchUuid: match.matchId,
                payload: payload,
              );
            },
          ),
        ),
      ),
    );

    if (result == true) {
      await _loadMatches();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Link added for ${match.team1} vs ${match.team2}')),
        );
      }
    }
  }

  Future<void> _confirmDeleteMatch(CookieRequest request, TicketMatch match) async {
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
      final success = await _service.deleteMatch(request: request, matchUuid: match.matchId);
      if (success) {
        await _loadMatches();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ticket deleted')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete ticket')),
          );
        }
      }
    }
  }

  Future<void> _confirmDeleteLink({
    required CookieRequest request,
    required TicketLink link,
    required TicketMatch match,
  }) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete link?'),
        content: Text('Remove ${link.vendor} from ${match.team1} vs ${match.team2}?'),
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
        await _loadMatches();
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
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({
    required this.match,
    required this.canManage,
    required this.onView,
    this.onEdit,
    this.onDelete,
    this.onAddLink,
    this.onDeleteLink,
  });

  final TicketMatch match;
  final bool canManage;
  final VoidCallback onView;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onAddLink;
  final void Function(TicketLink link)? onDeleteLink;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: InkWell(
        onTap: onView,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 6),
              Text(
                _formatDate(match.date) + (match.place != null ? ' · ${match.place}' : ''),
                style: const TextStyle(color: Color(0xFF4B5563)),
              ),
              if (canManage) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    TextButton(
                      onPressed: onEdit,
                      child: const Text('Edit Match'),
                    ),
                    TextButton(
                      onPressed: onAddLink,
                      child: const Text('Add Link'),
                    ),
                    TextButton(
                      onPressed: onDelete,
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 6),
              _buildLinks(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              _avatar(match.imgTeam1),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  match.team1,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF111827)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.0),
          child: Text('vs', style: TextStyle(color: Color(0xFF6B7280))),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  match.team2,
                  textAlign: TextAlign.end,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF111827)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              _avatar(match.imgTeam2),
            ],
          ),
        ),
      ],
    );
  }

  Widget _avatar(String url) {
    return CircleAvatar(
      radius: 18,
      backgroundImage: NetworkImage(url),
      onBackgroundImageError: (_, __) {},
      backgroundColor: const Color(0xFFE5E7EB),
    );
  }

  Widget _buildLinks() {
    if (match.links.isEmpty) {
      return const Text('No links yet.', style: TextStyle(color: Color(0xFF6B7280)));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: match.links.map((link) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      link.vendor,
                      style: const TextStyle(
                        color: Color(0xFFB91C1C),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatPrice(link.price),
                      style: const TextStyle(color: Color(0xFF4B5563)),
                    ),
                  ],
                ),
              ),
              if (onDeleteLink != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => onDeleteLink!.call(link),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _formatDate(DateTime d) => d.toIso8601String().split('T').first;

  String _formatPrice(int price) {
    final p = price.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < p.length; i++) {
      final idxFromEnd = p.length - i;
      buffer.write(p[i]);
      if (idxFromEnd > 1 && idxFromEnd % 3 == 1) {
        buffer.write('.');
      }
    }
    return 'Rp$buffer';
  }
}
