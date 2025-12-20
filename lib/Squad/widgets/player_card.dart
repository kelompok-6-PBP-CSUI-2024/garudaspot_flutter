import 'package:flutter/material.dart';
import '../models/player.dart';

class PlayerCard extends StatelessWidget {
  final Player player;
  final bool isAdmin;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PlayerCard({
    super.key,
    required this.player,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    this.isAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 14),
            width: 260,
            height: 360,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                    child: Image.network(
                      player.photoUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.person),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  player.fname.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    letterSpacing: 2,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  player.lname,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: 26,
                  height: 3,
                  color: Colors.red,
                ),
                const SizedBox(height: 18),
              ],
            ),
          ),
        ),

        if (isAdmin)
          Positioned(
            top: 12,
            right: 12,
            child: Row(
              children: [
                _icon(Icons.edit, onEdit),
                const SizedBox(width: 8),
                _icon(Icons.delete_outline, onDelete),
              ],
            ),
          ),
      ],
    );
  }

  Widget _icon(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}
