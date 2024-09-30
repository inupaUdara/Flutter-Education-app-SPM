import 'package:flutter/material.dart';

ThemeData colorMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
      surface: const Color(0xFFF5F8FF),
      primary: const Color(0xFF1F276F),
      secondary: Colors.grey.shade400,
      inversePrimary: Colors.grey.shade600),
  textTheme: ThemeData.light().textTheme.apply(
        bodyColor: Colors.grey[800],
        displayColor: Colors.black,
      ),
);
