import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const brown = Color(0xFF735639);
  static const brownDark = Color(0xFF6B5034);
  static const terracotta = Color(0xFFB5735A);
  static const terracottaLight = Color(0xFFC68B6E);
  static const header = Color(0xFFAD8467);
  static const cream = Color(0xFFF7F3EA);
  static const creamLight = Color(0xFFFAF6EE);
  static const searchBg = Color(0xFFECE7DE);
  static const beige = Color(0xFFEDE4D3);
  static const sand = Color(0xFFDAD5C5);
  static const sandDark = Color(0xFFB3AD94);
  static const caramel = Color(0xFFBD8C62);
  static const charcoal = Color(0xFF4A4846);
  static const textPrimary = Color(0xFF000000);
  static const textGrey = Color(0xFF8E8E8E);
  static const textBrown = Color(0xFF6E5036);
  static const star = Color(0xFFFFC107);
  static const failBg = Color(0xFFB5AE95);
  static const sliderTrack = Color(0xFFC9BF8E);
  static const navGrey = Color(0xFF9E9E9E);
  static const red = Color(0xFFB71C1C);
}

class AppText {
  static TextStyle s(
    double size, {
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.textPrimary,
    double? height,
    double? spacing,
  }) {
    return GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: spacing,
    );
  }
}

class AppTheme {
  static ThemeData get theme {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.brown,
        primary: AppColors.brown,
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: Colors.white,
    );
    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.brown,
        selectionHandleColor: AppColors.brown,
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.charcoal,
      ),
    );
  }
}
