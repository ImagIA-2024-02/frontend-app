import 'package:flutter/material.dart';

class AuthButton extends StatelessWidget {
  const AuthButton({
    super.key,
    this.onTap,
    required this.text,
    this.buttonColor = Colors.black, // Default button color
    this.textColor = Colors.white,  // Default text color
  });

  final String text;
  final Function()? onTap;
  final Color buttonColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(25),
        margin: const EdgeInsets.symmetric(horizontal: 25),
        decoration: BoxDecoration(
          color: buttonColor, // Use the buttonColor parameter
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: textColor, // Use the textColor parameter
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
