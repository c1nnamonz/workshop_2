import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.color = Colors.blue, // Default background color
    this.textColor = Colors.white, // Default font color
  });

  final String label;
  final void Function()? onPressed;
  final Color color; // Background color
  final Color textColor; // Font color

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 42,
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
