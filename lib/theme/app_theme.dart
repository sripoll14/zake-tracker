import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Paleta de colores de la app (los mismos que en los diseños).
class AppColors {
  AppColors._();

  static const bg = Color(0xFF1C1416);
  static const surface = Color(0xFF2A1F22);
  static const surfaceHigh = Color(0xFF35282B);
  static const line = Color(0xFF3A2A2D);
  static const lineStrong = Color(0xFF5A3F3A);
  static const text = Color(0xFFF6EFE7);
  static const muted = Color(0xFFC4B4AE);
  static const faint = Color(0xFF8E7A75);
  static const salmon = Color(0xFFFF8A5B);
  static const salmonLight = Color(0xFFFFB08F);
  static const win = Color(0xFF6FD08C);
  static const winBg = Color(0xFF1F3A2A);
  static const gold = Color(0xFFF2C14E);
  static const goldBg = Color(0xFF3D3220);
  static const limitedBg = Color(0xFF5A2328);
  static const limitedText = Color(0xFFFFC2C2);
  static const warningBg = Color(0xFF3A2A1E);
  static const warningText = Color(0xFFF3E3C4);
}

/// Estilos de texto. "display" para títulos y números grandes,
/// "body" para el resto.
class AppText {
  AppText._();

  static TextStyle display(
    double size, {
    FontWeight weight = FontWeight.w800,
    Color color = AppColors.text,
  }) {
    try {
      return GoogleFonts.getFont(
        'Bricolage Grotesque',
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: 1.1,
      );
    } catch (_) {
      // Si la versión de google_fonts no tiene esta fuente, usamos DM Sans.
      return GoogleFonts.dmSans(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: 1.1,
      );
    }
  }

  static TextStyle body(
    double size, {
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.text,
  }) =>
      GoogleFonts.dmSans(fontSize: size, fontWeight: weight, color: color);

  /// Etiqueta de sección en mayúsculas.
  static TextStyle label() => GoogleFonts.dmSans(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.muted,
        letterSpacing: 1,
      );
}

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.salmon,
      brightness: Brightness.dark,
      primary: AppColors.salmon,
      surface: AppColors.surface,
    ),
    scaffoldBackgroundColor: AppColors.bg,
  );
  return base.copyWith(
    textTheme: GoogleFonts.dmSansTextTheme(base.textTheme).apply(
      bodyColor: AppColors.text,
      displayColor: AppColors.text,
    ),
  );
}
