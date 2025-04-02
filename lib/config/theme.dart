import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AmrricTheme {
  // Primary Colors
  static const Color primary = Color(0xFF512BD4); // Deep Purple
  static const Color secondary = Color(0xFFDFD8F7); // Light Purple
  static const Color tertiary = Color(0xFF2B0B98); // Dark Blue

  // Grayscale
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color gray100 = Color(0xFFE1E1E1);
  static const Color gray200 = Color(0xFFC8C8C8);
  static const Color gray300 = Color(0xFFACACAC);
  static const Color gray400 = Color(0xFF919191);
  static const Color gray500 = Color(0xFF6E6E6E);
  static const Color gray600 = Color(0xFF404040);
  static const Color gray900 = Color(0xFF212121);
  static const Color gray950 = Color(0xFF141414);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA500);
  static const Color error = Color(0xFFFF0000);

  // Typography
  static TextTheme textTheme = TextTheme(
    displayLarge: GoogleFonts.openSans(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: gray900,
    ),
    displayMedium: GoogleFonts.openSans(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: gray900,
    ),
    bodyLarge: GoogleFonts.openSans(
      fontSize: 16,
      color: gray900,
    ),
    bodyMedium: GoogleFonts.openSans(
      fontSize: 14,
      color: gray900,
    ),
    labelLarge: GoogleFonts.openSans(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: gray900,
    ),
  );

  // Button Styles
  static final ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primary,
    foregroundColor: white,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    minimumSize: const Size(200, 44),
  );

  static final ButtonStyle secondaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: secondary,
    foregroundColor: primary,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    minimumSize: const Size(200, 44),
  );

  // Input Decoration
  static InputDecoration inputDecoration = InputDecoration(
    filled: true,
    fillColor: white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: gray300),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: gray300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: primary),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: error),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  );

  // App Theme
  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.light(
          primary: primary,
          secondary: secondary,
          tertiary: tertiary,
          surface: white,
          background: gray100,
          error: error,
        ),
        textTheme: textTheme,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: primaryButtonStyle,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: gray300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: gray300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: primary),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: error),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: primary,
          foregroundColor: white,
          elevation: 0,
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
} 