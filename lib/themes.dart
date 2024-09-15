import 'package:flutter/material.dart';


ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme(
    brightness: Brightness.light,
    background: Colors.white,
    primary: Colors.white,
    secondary: Colors.white,
    onSecondary: Colors.grey.withOpacity(0.5),
    onError: Colors.white,
    surface: const Color(0xFFEFEDED),
    onSurface: Colors.white,
    error: const Color(0xFF383838),
    onPrimary: Colors.white

  )
);

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme(
    brightness: Brightness.dark,
    background: const Color(0xFF161616),
    primary: const Color(0xFF0E0D1D),
    secondary: Colors.white,
    onSecondary: Colors.grey.withOpacity(0.2),
    onError: Colors.white,
    surface: const Color(0xFF393939),
    onSurface: Colors.white,
    error: Colors.white,
    onPrimary: const Color(0xFF383838)
  )
);