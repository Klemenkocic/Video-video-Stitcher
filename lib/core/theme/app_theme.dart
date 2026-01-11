import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors
  static const terracotta = Color(0xFFE07B54); // Keep as subtle accent
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);
  static const sunsetGold = Color(0xFFF5C842); // Warm gold for highlights
  
  // Monochrome Scale
  static const surfaceDark = Color(0xFF121212); // Slightly lighter black for cards
  static const surfaceLight = Color(0xFF1E1E1E); // Even lighter for specialized inputs
  static const greyMedium = Color(0xFF8E8E93); // Apple-style grey
  static const greyLight = Color(0xFFD1D1D6); 
  
  // Additional Colors
  static const charcoal = Color(0xFF2A2A2A); // Dark grey for buttons
  static const parchment = Color(0xFFF5F5F5); // Light beige for text
  static const stone = Color(0xFFB0B0B0); // Medium grey for secondary text

  // Dark Theme
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: black, // Pure Black Background
    primaryColor: white, // Primary is now White
    colorScheme: const ColorScheme.dark(
      primary: white,
      secondary: greyMedium,
      surface: surfaceDark,
      onPrimary: black,
      onSecondary: white,
      onSurface: white,
    ),
    fontFamily: 'Inter', 
    // SF Pro Display feel: Bold, Tight spacing
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w800, // Extra Bold
        letterSpacing: -0.5,
        color: white,
      ),
      displayMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: white,
      ),
      bodyLarge: TextStyle(
        fontSize: 17, // iOS Standard
        fontWeight: FontWeight.w500,
        color: white,
      ),
      bodyMedium: TextStyle(
        fontSize: 15, // iOS Subtext
        color: greyMedium,
      ),
    ),
    cardTheme: const CardThemeData(
      color: surfaceDark,
      elevation: 0, // Flat design
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)), // Wispr-style Squircle
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceDark,
      hintStyle: const TextStyle(color: greyMedium),
      contentPadding: const EdgeInsets.all(16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none, // No borders, just fill
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: white, width: 1), // Minimal white focus
      ),
    ),
  );
}
