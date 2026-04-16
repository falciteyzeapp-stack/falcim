import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFFE8433A);
  static const Color primaryDark = Color(0xFFB82020);
  static const Color primaryBright = Color(0xFFFF6B55);
  static const Color secondary = Color(0xFFFF9A8B);
  static const Color background = Color(0xFF6A0A0A);
  static const Color surface = Color(0x33000000);
  static const Color surfaceLight = Color(0x44FFFFFF);
  static const Color gold = Color(0xFFFFD700);
  static const Color goldLight = Color(0xFFFFF0A0);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFFFE0D0);
  static const Color error = Color(0xFFFF5252);

  // Font aileleri
  static const String fontLogo = 'GreatVibes';
  static const String fontBody = 'Cinzel';

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFE8433A),
      Color(0xFFCC2A22),
      Color(0xFF9A1010),
      Color(0xFF5A0505),
    ],
    stops: [0.0, 0.3, 0.65, 1.0],
  );

  static const LinearGradient coralGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF7A65), Color(0xFFE8433A), Color(0xFFB82020)],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFE066), Color(0xFFFFD700), Color(0xFFCCA000)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x55FF6B55), Color(0x33CC2A22)],
  );

  static TextStyle logoStyle({
    double fontSize = 36,
    Color color = textPrimary,
    double letterSpacing = 1.0,
  }) {
    return TextStyle(
      fontFamily: fontLogo,
      fontSize: fontSize,
      color: color,
      letterSpacing: letterSpacing,
      height: 1.2,
    );
  }

  static TextStyle cinzel({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    Color color = textPrimary,
    double height = 1.5,
    FontStyle fontStyle = FontStyle.normal,
    double letterSpacing = 0,
  }) {
    return TextStyle(
      fontFamily: fontBody,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
    );
  }

  static ThemeData get theme {
    const bodyStyle = TextStyle(fontFamily: fontBody, color: textPrimary);
    return ThemeData(
      useMaterial3: true,
      fontFamily: fontBody,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: Color(0xFF9A1010),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        error: error,
      ),
      scaffoldBackgroundColor: const Color(0xFF9A1010),
      textTheme: TextTheme(
        displayLarge: bodyStyle.copyWith(fontSize: 32, fontWeight: FontWeight.bold),
        displayMedium: bodyStyle.copyWith(fontSize: 26, fontWeight: FontWeight.bold),
        headlineMedium: bodyStyle.copyWith(fontSize: 20, fontWeight: FontWeight.bold),
        // bodyLarge: TextField/TextFormField input text buradan alır — sistem fontu şart (Cinzel sadece büyük harf)
        bodyLarge: const TextStyle(fontFamily: null, color: textPrimary, fontSize: 16, height: 1.6),
        bodyMedium: bodyStyle.copyWith(color: textSecondary, fontSize: 14, height: 1.5),
        bodySmall: bodyStyle.copyWith(color: textSecondary, fontSize: 12),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: fontBody,
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0x44000000),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: gold, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: error, width: 2),
        ),
        // Sistem fontu — Cinzel sadece büyük harf içeriyor, input'ta kullanılamaz
        labelStyle: TextStyle(fontFamily: null, color: textSecondary, fontSize: 14),
        hintStyle: TextStyle(fontFamily: null, color: Colors.white54, fontSize: 14),
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
            fontFamily: fontBody,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          elevation: 8,
          shadowColor: Color.fromRGBO(232, 67, 58, 0.5),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: Color(0xFF3D1010),
        contentTextStyle: TextStyle(fontFamily: fontBody, color: textPrimary),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: const Color(0xFF4A0505),
        selectedItemColor: gold,
        unselectedItemColor: Colors.white.withOpacity(0.4),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: const TextStyle(
          fontFamily: fontBody,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: const TextStyle(fontFamily: fontBody, fontSize: 10),
      ),
      dividerColor: Colors.white.withOpacity(0.15),
      cardTheme: CardThemeData(
        color: const Color(0x33000000),
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppTheme.gold.withOpacity(0.35), width: 1.5),
        ),
      ),
    );
  }
}
