import 'package:flutter/material.dart';

class NewsHeader extends StatelessWidget {
  const NewsHeader({
    super.key,
    required this.isAdmin,
    required this.onAddNews,
  });

  final bool isAdmin;
  final VoidCallback onAddNews;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: 200,
          width: double.infinity,
          child: Image.asset(
            'assets/images/background.png',
            fit: BoxFit.cover,
          ),
        ),
        Container(
          height: 200,
          width: double.infinity,
          color: Colors.white.withOpacity(0.8),
        ),
        SizedBox(
          height: 200,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
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
                const SizedBox(height: 6),
                const Text(
                  'BERITA TERKINI',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 60,
                  height: 3,
                  color: Colors.red.shade700,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Berita terbaru sepak bola Indonesia',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black87,
                  ),
                ),
                if (isAdmin) ...[
                  const SizedBox(height: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    onPressed: onAddNews,
                    child: const Text('Add News'),
                  ),
                ]
              ],
            ),
          ),
        ),
      ],
    );
  }
}
