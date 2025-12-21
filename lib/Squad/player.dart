import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

import 'models/player.dart';
import 'services/api_service.dart';
import 'widgets/player_card.dart';
import '../right_drawer.dart';
import 'widgets/squad_header.dart';
import 'widgets/squad_navbar.dart';
import 'widgets/player_detail_page.dart';
import 'widgets/player_form_dialog.dart';

class SquadPage extends StatefulWidget {
  const SquadPage({super.key});

  @override
  State<SquadPage> createState() => _SquadPageState();
}

class _SquadPageState extends State<SquadPage> {
  String? selectedRole;
  bool _loading = true;
  List<Player> _players = [];

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  Future<void> _loadPlayers() async {
    final data = await ApiService.fetchPlayers();
    setState(() {
      _players = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final bool isAdmin = request.jsonData['is_admin'] == true;
    final bool isSuperuser = request.jsonData['is_superuser'] == true;

    List<Player> filtered = _players;
    if (selectedRole != null) {
      filtered = filtered.where((p) => p.roleTag == selectedRole).toList();
    }

    return Scaffold(
      endDrawer: RightDrawer(
        isAdmin: isAdmin,
        isSuperuser: isSuperuser,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Builder(
              builder: (ctx) => SquadNavbar(
                isAdmin: isAdmin,
                onMenuTap: () => Scaffold.of(ctx).openEndDrawer(),
                onAddPlayer: isAdmin ? () => _openForm(ctx) : null,
              ),
            ),
            SquadHeader(
              isAdmin: isAdmin,
              onAddPlayer: isAdmin ? () => _openForm(context) : () {},
            ),
            const SizedBox(height: 12),
            _buildFilter(),
            const SizedBox(height: 16),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildList(filtered, isAdmin),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<Player> players, bool isAdmin) {
    if (players.isEmpty) {
      return const Center(child: Text('DATA KOSONG'));
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: players.map((p) {
        return Center(
          child: PlayerCard(
            player: p,
            isAdmin: isAdmin,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PlayerDetailPage(player: p),
                ),
              );
            },
            onEdit: isAdmin ? () => _editPlayer(p) : () {},
            onDelete: isAdmin ? () => _deletePlayer(p) : () {},
          ),
        );
      }).toList(),
    );
  }

  

void _openForm(BuildContext context) async {
  final request = context.read<CookieRequest>();

  await ApiService.initCsrf(request);

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => PlayerFormDialog(
      onSubmit: (data) async {
        final created = await ApiService.createPlayer(
          request: request,
          data: data,
        );

        setState(() {
          _players.insert(0, created);
        });
      },
    ),
  );
}



void _editPlayer(Player p) {
  final request = context.read<CookieRequest>();

  showDialog(
    context: context,
    builder: (_) => PlayerFormDialog(
      player: p,
      onSubmit: (data) async {
        await ApiService.initCsrf(request);
        final updated = await ApiService.updatePlayer(
          request: request,
          playerId: p.id,
          data: data,
        );

        setState(() {
          final i = _players.indexWhere((x) => x.id == p.id);
          if (i != -1) _players[i] = updated;
        });
      },
    ),
  );
}


  Future<void> _deletePlayer(Player p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Player'),
        content: Text('Delete ${p.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (ok == true) {
      await ApiService.deletePlayer(
        request: context.read<CookieRequest>(),
        playerId: p.id,
      );
      setState(() => _players.removeWhere((x) => x.id == p.id));
    }
  }

  Widget _buildFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _filterBtn('GOALKEEPER'),
          _filterBtn('DEFENDER'),
          _filterBtn('MIDFIELDER'),
          _filterBtn('ATTACKER'),
        ],
      ),
    );
  }

  Widget _filterBtn(String role) {
    final active = selectedRole == role;
    return GestureDetector(
      onTap: () => setState(() {
        selectedRole = active ? null : role;
      }),
      child: Column(
        children: [
          Text(
            role,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: active ? Colors.black : Colors.grey,
            ),
          ),
          if (active)
            Container(
              width: 20,
              height: 3,
              color: Colors.red,
            ),
        ],
      ),
    );
  }
}
