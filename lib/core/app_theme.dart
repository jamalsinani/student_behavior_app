import 'package:flutter/material.dart';

class AppTheme {

  /// 🔹 قبل تسجيل الدخول
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFFF8FAFC),

    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF064E3B),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF064E3B),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    ),
  );

  /// 👨‍🏫 ثيم المعلم (أزرق حديث)
  static ThemeData teacherTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFFF6F9FF),

    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF2563EB),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    ),
  );

  /// 👨‍👧 ثيم ولي الأمر (أخضر عصري مختلف)
  static ThemeData parentTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFFF0FDF4),

    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF16A34A),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF16A34A),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    ),
  );

}