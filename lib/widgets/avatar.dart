import 'package:flutter/material.dart';
import 'app_image.dart';

class Avatar extends StatelessWidget {
  final String data;
  final double size;
  const Avatar({super.key, required this.data, this.size = 120});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE7C3B2), Color(0xFFD9A994)],
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: data.isEmpty
          ? Icon(Icons.person, size: size * 0.7, color: const Color(0xFF4A3426))
          : AppImage(data, fit: BoxFit.cover, width: size, height: size),
    );
  }
}
