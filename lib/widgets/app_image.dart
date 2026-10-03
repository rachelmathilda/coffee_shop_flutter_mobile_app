import 'dart:convert';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppImage extends StatelessWidget {
  final String path;
  final BoxFit fit;
  final double? width;
  final double? height;

  const AppImage(this.path, {super.key, this.fit = BoxFit.contain, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    Widget fallback() => SizedBox(
          width: width,
          height: height,
          child: const Center(child: Icon(Icons.local_cafe, color: AppColors.terracotta)),
        );
    if (path.isEmpty) return fallback();
    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (_, _, _) => fallback(),
      );
    }
    if (path.startsWith('data:') || path.length > 500) {
      try {
        final data = path.contains(',') ? path.split(',').last : path;
        return Image.memory(
          base64Decode(data),
          fit: fit,
          width: width,
          height: height,
          gaplessPlayback: true,
          errorBuilder: (_, _, _) => fallback(),
        );
      } catch (_) {
        return fallback();
      }
    }
    return Image.asset(
      path,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (_, _, _) => fallback(),
    );
  }
}
