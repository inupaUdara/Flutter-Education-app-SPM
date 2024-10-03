import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final TextEditingController controller;
  final Color borderColor; // Color for the border
  final Color textColor; // Color for the text
  final Color hintColor; // Color for the hint text
  final Color focusedBorderColor; // Color for the focused border
  final Color enabledBorderColor; // Color for the enabled border
  final Widget? suffixIcon; // Suffix icon for showing/hiding password

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.obscureText,
    required this.controller,
    this.borderColor = Colors.grey, // Default border color
    this.textColor = Colors.black, // Default text color
    this.hintColor = const Color(0xFF1F276F), // Default hint color
    this.focusedBorderColor = Colors.blue, // Default focused border color
    this.enabledBorderColor = Colors.grey, // Default enabled border color
    this.suffixIcon, // Add the suffixIcon parameter
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      cursorColor: Colors.black,
      style: TextStyle(color: textColor), // Text color
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hintText,
        hintStyle: TextStyle(color: hintColor), // Hint text color
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Colors.white), // Enabled border color
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: focusedBorderColor), // Focused border color
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
              color: Color(0xFFC1E3FD)), // Enabled border color
        ),
        suffixIcon: suffixIcon, // Add the suffixIcon widget
      ),
    );
  }
}
