import 'package:flutter/material.dart';

class PostCard extends StatelessWidget {
  final String author;
  final String date;
  final String title;
  final String content;
  final String category;
  final bool isLiked;
  final int likeCount;
  final VoidCallback onLike;
  final bool canDelete;
  final VoidCallback? onDelete;
  final VoidCallback onTapTitle;

  const PostCard({
    super.key,
    required this.author,
    required this.date,
    required this.title,
    required this.content,
    required this.category,
    required this.isLiked,
    required this.likeCount,
    required this.onLike,
    required this.canDelete,
    this.onDelete,
    required this.onTapTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: author,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.black,
                          ),
                        ),
                        const TextSpan(text: '   '),
                        TextSpan(
                          text: date,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  category,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (canDelete && onDelete != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                    tooltip: 'Hapus post',
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: onTapTitle,
              child: Text(
                title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Text(content, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  onPressed: onLike,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    size: 18,
                    color: isLiked ? const Color(0xFFB71C1C) : Colors.grey,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '$likeCount',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
