import 'package:flutter/material.dart';

class AppTheme {
  static const Color cream = Color(0xffF5F1E6);
  static const Color brown = Color(0xff8B5E3C);
  static const Color autumn = Color(0xffC97B3D);

  static ThemeData get lightTheme {
    return ThemeData(
      scaffoldBackgroundColor: cream,
      primaryColor: brown,
      appBarTheme: const AppBarTheme(
        backgroundColor: brown,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: brown,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
