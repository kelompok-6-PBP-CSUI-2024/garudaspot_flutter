import 'package:flutter/material.dart';

class SquadHeader extends StatelessWidget {
  const SquadHeader({
    super.key,
    required this.isAdmin,
    required this.onAddPlayer,
  });

  final bool isAdmin;
  final VoidCallback? onAddPlayer; //


  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        /// BACKGROUND IMAGE
        SizedBox(
          height: 220,
          width: double.infinity,
          child: Image.asset(
            'assets/images/hero.png',
            fit: BoxFit.cover,
          ),
        ),

        /// OVERLAY
Container(
  height: 220,
  width: double.infinity,
  decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.white.withOpacity(0),
        Colors.red.withOpacity(0.55),
      ],
    ),
  ),
),


        /// CONTENT
        SizedBox(
          height: 220,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /// TOP ROW (TITLE + MENU)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Garuda Spot',
                      style: TextStyle(
                        letterSpacing: 3,
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                /// TITLE
                const Text(
                  'SQUAD GARUDA',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white
                  ),
                ),

                const SizedBox(height: 6),

                /// RED LINE
                Container(
                  width: 60,
                  height: 3,
                  color: Colors.red.shade700,
                ),

                const SizedBox(height: 8),

                /// SUBTITLE
                const Text(
                  'Skuad resmi tim nasional Indonesia',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white
                  ),
                ),

                if (isAdmin) ...[
                  const SizedBox(height: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                    ),
                    onPressed: onAddPlayer,
                    child: const Text('Add Player'),
                  ),
                ],

              ],
            ),
          ),
        ),
      ],
    );
  }
}
