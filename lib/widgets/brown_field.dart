import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BrownField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData? icon;
  final bool obscure;
  final VoidCallback? onToggle;
  final TextInputType? keyboardType;
  final bool enabled;

  const BrownField({
    super.key,
    required this.controller,
    required this.hint,
    this.icon,
    this.obscure = false,
    this.onToggle,
    this.keyboardType,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.textBrown, width: 1),
    );
    return SizedBox(
      height: 50,
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        enabled: enabled,
        style: AppText.s(16, color: AppColors.textBrown),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppText.s(16, color: AppColors.textBrown),
          contentPadding: EdgeInsets.fromLTRB(icon == null ? 34 : 0, 14, 12, 14),
          prefixIcon: icon == null
              ? null
              : Padding(
                  padding: const EdgeInsets.only(left: 22, right: 22),
                  child: Icon(icon, color: AppColors.textBrown, size: 26),
                ),
          suffixIcon: onToggle == null
              ? null
              : IconButton(
                  onPressed: onToggle,
                  icon: Icon(
                    obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: AppColors.textBrown,
                    size: 20,
                  ),
                ),
          border: border,
          enabledBorder: border,
          disabledBorder: border,
          focusedBorder: border.copyWith(borderSide: const BorderSide(color: AppColors.brown, width: 1.5)),
        ),
      ),
    );
  }
}
