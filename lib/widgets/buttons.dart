import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool loading;
  final double height;
  final double radius;
  final Color color;
  final double fontSize;
  final double? width;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.loading = false,
    this.height = 58,
    this.radius = 10,
    this.color = AppColors.brown,
    this.fontSize = 20,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        child: InkWell(
          borderRadius: BorderRadius.circular(radius),
          onTap: loading ? null : onTap,
          child: Center(
            child: loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
                  )
                : Text(label, style: AppText.s(fontSize, weight: FontWeight.w500, color: Colors.white)),
          ),
        ),
      ),
    );
  }
}

class OutlineButtonX extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final double height;
  final double radius;
  final double fontSize;
  final Color textColor;
  final double? width;
  final bool loading;

  const OutlineButtonX({
    super.key,
    required this.label,
    required this.onTap,
    this.height = 58,
    this.radius = 10,
    this.fontSize = 20,
    this.textColor = AppColors.textBrown,
    this.width,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: const BorderSide(color: AppColors.textBrown, width: 1),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(radius),
          onTap: loading ? null : onTap,
          child: Center(
            child: loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.2, color: AppColors.brown),
                  )
                : Text(label, style: AppText.s(fontSize, weight: FontWeight.w400, color: textColor)),
          ),
        ),
      ),
    );
  }
}

class CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final Color color;
  final Color iconColor;

  const CircleIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 28,
    this.color = AppColors.terracotta,
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, size: size * 0.7, color: iconColor),
        ),
      ),
    );
  }
}

void showMessage(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));
}
