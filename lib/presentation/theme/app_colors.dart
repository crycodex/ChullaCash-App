import 'package:flutter/material.dart';

/// Clase que contiene todos los colores de la aplicación
class AppColors {
  // Colores principales
  static const Color primaryBlue = Color(0xFF16498C);
  static const Color primaryGreen = Color(0xFF91D983);

  // Colores neutros
  static const Color lightGray = Color(0xFFF2F2F2);
  static const Color darkGray = Color(0xFF181818);

  // Variantes de los colores principales
  static const Color primaryBlueDark = Color(0xFF0D2B54);
  static const Color primaryGreenDark = Color(0xFF6BA55F);

  // Colores de fondo
  static const Color background = lightGray;
  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = darkGray;

  // Colores de texto
  static const Color textPrimary = darkGray;
  static const Color textSecondary = Color(0xFF666666);
  static const Color textLight = Colors.white;

  // Colores de estado
  static const Color success = primaryGreen;
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFA726);
  static const Color info = primaryBlue;

  // Colores de gradiente
  static List<Color> primaryGradient = [
    primaryBlue,
    primaryBlueDark,
  ];

  static List<Color> greenGradient = [
    primaryGreen,
    primaryGreenDark,
  ];
}
