import 'package:flutter/material.dart';

class AppThemes {
  static final light = ThemeData(
    primarySwatch: Colors.orange,
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(fontSize: 24),
    ),
  );

  static final dark = ThemeData(
    primarySwatch: Colors.deepPurple,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.black,
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(fontSize: 24, color: Colors.grey),
    ),
  );
}
