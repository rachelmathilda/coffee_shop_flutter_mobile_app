import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class NotchedField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback? onToggleObscure;
  final TextInputType? keyboardType;
  final TextInputAction? action;
  final ValueChanged<String>? onSubmitted;

  const NotchedField({
    super.key,
    required this.label,
    required this.controller,
    this.obscure = false,
    this.onToggleObscure,
    this.keyboardType,
    this.action,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.black, width: 1),
      gapPadding: 14,
    );
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      textInputAction: action,
      onSubmitted: onSubmitted,
      autocorrect: false,
      enableSuggestions: !obscure,
      style: AppText.s(16, weight: FontWeight.w400),
      decoration: InputDecoration(
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelStyle: AppText.s(20, weight: FontWeight.w300),
        floatingLabelStyle: AppText.s(20, weight: FontWeight.w300),
        contentPadding: const EdgeInsets.fromLTRB(26, 16, 16, 14),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(borderSide: const BorderSide(color: AppColors.charcoal, width: 1.4)),
        suffixIcon: onToggleObscure == null
            ? null
            : IconButton(
                onPressed: onToggleObscure,
                icon: Icon(
                  obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 20,
                  color: AppColors.charcoal,
                ),
              ),
      ),
    );
  }
}

class RingCheck extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String label;

  const RingCheck({super.key, required this.value, required this.onChanged, required this.label});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 14,
              height: 11,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.black, width: 1.8),
              ),
              alignment: Alignment.center,
              child: Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: value ? Colors.black : Colors.transparent,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(label, style: AppText.s(12, weight: FontWeight.w300)),
          ],
        ),
      ),
    );
  }
}

class DarkPillButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool loading;

  const DarkPillButton({super.key, required this.label, required this.onTap, this.loading = false});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.charcoal,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: loading ? null : onTap,
        child: SizedBox(
          width: 148,
          height: 38,
          child: Center(
            child: loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text(label, style: AppText.s(20, weight: FontWeight.w300, color: Colors.white)),
          ),
        ),
      ),
    );
  }
}

class GoogleButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const GoogleButton({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      height: 30,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 4, offset: Offset(0, 3))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/google.png', width: 22, height: 22),
              const SizedBox(width: 12),
              Text(label, style: AppText.s(12, weight: FontWeight.w400)),
            ],
          ),
        ),
      ),
    );
  }
}
