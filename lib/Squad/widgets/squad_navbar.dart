import 'package:flutter/material.dart';

class SquadNavbar extends StatelessWidget {
  final VoidCallback onMenuTap;
  final bool isAdmin;
  final VoidCallback? onAddPlayer;

  const SquadNavbar({
    super.key,
    required this.onMenuTap,
    required this.isAdmin,
    required this.onAddPlayer,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      titleSpacing: 12,
      title: Row(
        children: [
          Image.asset(
            'assets/images/logo_top.png',
            height: 32,
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
        if (isAdmin)
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black),
            tooltip: 'Add Player',
            onPressed: onAddPlayer,
          ),
        IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: onMenuTap,
        ),
      ],
    );
  }
}
