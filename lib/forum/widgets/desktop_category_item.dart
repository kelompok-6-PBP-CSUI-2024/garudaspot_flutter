import 'package:flutter/material.dart';

class DesktopCategoryItem extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const DesktopCategoryItem({
    super.key,
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: onTap,
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            decoration:
                isSelected ? TextDecoration.underline : TextDecoration.none,
          ),
        ),
      ),
    );
  }
}
