import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFFE8654A);
  static const Color primaryDark = Color(0xFFB84035);
  static const Color secondary = Color(0xFFFF9A8B);
  static const Color background = Color(0xFF1A0A0A);
  static const Color surface = Color(0xFF2D1515);
  static const Color surfaceLight = Color(0xFF3D2020);
  static const Color gold = Color(0xFFD4AF37);
  static const Color textPrimary = Color(0xFFF5E6D3);
  static const Color textSecondary = Color(0xFFBFA090);
  static const Color error = Color(0xFFFF5252);

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF3D1515),
      Color(0xFF1A0505),
      Color(0xFF0D0000),
    ],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient coralGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFF8A70),
      Color(0xFFE8654A),
      Color(0xFFB84035),
    ],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF3D2020),
      Color(0xFF2D1515),
    ],
  );

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: surface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        error: error,
      ),
      scaffoldBackgroundColor: background,
      fontFamily: 'Cinzel',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Cinzel',
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          fontFamily: 'Cinzel',
        ),
        displayMedium: TextStyle(
          color: textPrimary,
          fontSize: 26,
          fontWeight: FontWeight.bold,
          fontFamily: 'Cinzel',
        ),
        headlineMedium: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Cinzel',
        ),
        bodyLarge: TextStyle(
          color: textPrimary,
          fontSize: 16,
          height: 1.6,
          fontFamily: 'Cinzel',
        ),
        bodyMedium: TextStyle(
          color: textSecondary,
          fontSize: 14,
          height: 1.5,
          fontFamily: 'Cinzel',
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF5D3030)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF5D3030)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: error, width: 2),
        ),
        labelStyle: const TextStyle(color: textSecondary, fontFamily: 'Cinzel'),
        hintStyle: const TextStyle(color: Color(0xFF7A5050), fontFamily: 'Cinzel'),
        prefixIconColor: textSecondary,
        suffixIconColor: textSecondary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cinzel',
          ),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: surface,
        contentTextStyle: TextStyle(color: textPrimary, fontFamily: 'Cinzel'),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF200A0A),
        selectedItemColor: primary,
        unselectedItemColor: Color(0xFF7A5050),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      dividerColor: const Color(0xFF3D2020),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF4D2525)),
        ),
      ),
    );
  }
}
