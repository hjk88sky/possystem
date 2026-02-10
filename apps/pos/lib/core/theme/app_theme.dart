import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1565C0),
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Color(0xFF1565C0),
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 48),
          textStyle: const TextStyle(fontSize: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
      ),
      chipTheme: const ChipThemeData(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: TextStyle(fontSize: 14),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontSize: 16),
        bodyMedium: TextStyle(fontSize: 14),
        labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  // Category colors for visual distinction
  static const List<Color> categoryColors = [
    Color(0xFF1565C0), // Blue
    Color(0xFF2E7D32), // Green
    Color(0xFFC62828), // Red
    Color(0xFFF57F17), // Amber
    Color(0xFF6A1B9A), // Purple
    Color(0xFF00838F), // Teal
    Color(0xFFEF6C00), // Orange
    Color(0xFF37474F), // Blue Grey
  ];

  static Color getCategoryColor(int index) {
    return categoryColors[index % categoryColors.length];
  }
}
