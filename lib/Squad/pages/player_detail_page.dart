import 'package:flutter/material.dart';
import '../models/player.dart';

class PlayerDetailPage extends StatelessWidget {
  final Player player;

  const PlayerDetailPage({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isDesktop = constraints.maxWidth > 900;

            return Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// ===== TOP BAR =====
                  Row(
                    children: [
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        child: const Row(
                          children: [
                            Icon(Icons.arrow_back, color: Colors.red),
                            SizedBox(width: 6),
                            Text(
                              'Return to squad',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Profile',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  /// ===== CONTENT =====
                  Expanded(
                    child: isDesktop
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: _leftContent()),
                              const SizedBox(width: 40),
                              Expanded(child: _rightImageDesktop()),
                            ],
                          )
                        : SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _rightImageMobile(),
                                const SizedBox(height: 24),
                                _leftContent(),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// ================= LEFT CONTENT =================
  Widget _leftContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// NAME
        Text(
          player.fname,
          style: const TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.w800,
            color: Colors.red,
            height: 1,
          ),
        ),
        Text(
          player.lname,
          style: const TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.w800,
            color: Colors.red,
            height: 1,
          ),
        ),

        const SizedBox(height: 40),

        /// INFO GRID
        Wrap(
          spacing: 60,
          runSpacing: 24,
          children: [
            _info('Position', player.positions.join(', ')),
            _info('Date of Birth', '-'),
            _info(
              'Height',
              player.heightCm != null ? '${player.heightCm} cm' : '-',
            ),
            _info(
              'Club',
              player.club.isNotEmpty ? player.club : '-',
            ),
          ],
        ),

        const SizedBox(height: 48),

        /// STATS
        Row(
          children: [
            _stat('Appearances', player.caps),
            const SizedBox(width: 60),
            _stat('Goals', player.goals),
            const SizedBox(width: 60),
            _stat('Assists', player.assists),
          ],
        ),
      ],
    );
  }

  /// ================= IMAGE (DESKTOP) =================
  Widget _rightImageDesktop() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Image.network(
        player.photoUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: Colors.grey.shade200,
          child: const Icon(
            Icons.person,
            size: 120,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  /// ================= IMAGE (MOBILE) =================
  Widget _rightImageMobile() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        height: 320,
        width: double.infinity,
        child: Image.network(
          player.photoUrl,
          fit: BoxFit.cover,
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
    );
  }

  /// ================= COMPONENTS =================
  Widget _info(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  Widget _stat(String label, int value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
      ],
    );
  }
}
