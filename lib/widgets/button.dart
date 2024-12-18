import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.color = Colors.blue, // Default background color
    this.textColor = Colors.white, // Default font color
    this.width = 170, // Default width
    this.height = 42, // Default height
  });

  final String label;
  final void Function()? onPressed;
  final Color color; // Background color
  final Color textColor; // Font color
  final double width; // Custom width
  final double height; // Custom height

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,  // Set the width directly on Container
      height: height,  // Set the height directly on Container
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color, // Use the color for the background
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 18,
            color: textColor, // Set the font color
          ),
        ),
      ),
    );
  }
}


