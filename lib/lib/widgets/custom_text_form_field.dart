import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
    super.key,
    required this.controller,
    this.obscureText = false,
    required this.label,
    this.validator,
    this.maxLines = 1,
    this.keyBoardType,
    this.enabled = true, 
  });

  final TextEditingController controller;
  final bool obscureText;
  final String label;
  final String? Function(String?)? validator;
  final int maxLines;
  final TextInputType? keyBoardType;
  final bool enabled; 

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      maxLines: maxLines,
      keyboardType: keyBoardType,
      enabled: enabled, 
      decoration: InputDecoration(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        labelText: label,
        labelStyle: const TextStyle(
          color: Color(0xFF757575),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFBDBDBD)), // Borde gris claro
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFF7B7A3)), // Borde pastel salmón
          borderRadius: BorderRadius.circular(8),
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFEEEEEE)), // Borde gris muy claro
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      style: const TextStyle(
        color: Color(0xFF212121),
        fontSize: 16,
      ),
    );
  }
}
