import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final void Function()? ontap;

  const CustomButton({
    super.key,
    required this.text,
    required this.ontap,
  });

  @override
  Widget build(BuildContext context) {
    // Get the screen size
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: ontap,
      child: Container(
        width: screenWidth * 0.8, // Set width relative to screen width (80%)
        padding: EdgeInsets.symmetric(
          vertical:
              screenHeight * 0.02, // Vertical padding is 2% of screen height
          horizontal:
              screenWidth * 0.04, // Horizontal padding is 4% of screen width
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize:
                  screenWidth * 0.045, // Font size is 4.5% of screen width
            ),
          ),
        ),
      ),
    );
  }
}
