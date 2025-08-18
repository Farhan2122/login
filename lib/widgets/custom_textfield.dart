import 'package:flutter/material.dart';

class CustomTextfield extends StatelessWidget {
  const CustomTextfield({super.key, required this.icon, required this.labelText, this.eyeIcon, required this.controller, required this.validator});
  final Icon icon;
  final String labelText;
  final Icon? eyeIcon;
  final String? Function(String?)? validator;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        prefixIcon: icon,
        suffixIcon: eyeIcon,
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
        )
      ),
    );
  }
}
