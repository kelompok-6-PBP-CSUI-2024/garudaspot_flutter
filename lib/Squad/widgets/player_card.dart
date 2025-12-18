import 'package:flutter/material.dart';
import '../models/player.dart';
import '../pages/player_detail_page.dart';

class PlayerCard extends StatelessWidget {
  final Player player;

  const PlayerCard({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
return GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlayerDetailPage(player: player),
      ),
    );
  },
  child: Container(
    margin: const EdgeInsets.symmetric(vertical: 18),
    width: 260,
    height: 380,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 16,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Column(
      children: [
        /// ===== FOTO AREA =====
        ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(28),
          ),
          child: SizedBox(
            height: 250, // <-- ini kunci besarnya foto
            width: double.infinity,
            child: Image.network(
              player.photoUrl,
              fit: BoxFit.cover, // <<< INI PENTING
              alignment: Alignment.topCenter,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey.shade200,
                child: const Icon(
                  Icons.person,
                  size: 120,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 14),

        /// ===== NAMA DEPAN =====
        Text(
          player.fname.toUpperCase(),
          style: const TextStyle(
            fontSize: 13,
            color: Colors.grey,
            letterSpacing: 1,
          ),
        ),

        const SizedBox(height: 4),

        /// ===== NAMA BELAKANG =====
        Text(
          player.lname.toLowerCase(),
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.red,
            letterSpacing: 1,
          ),
        ),

        const SizedBox(height: 6),

        /// ===== GARIS MERAH =====
        Container(
          width: 32,
          height: 3,
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    ),
  ),
);
}
}
