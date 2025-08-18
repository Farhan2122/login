import 'package:flutter/material.dart';

class Loginbutton extends StatelessWidget {
  const Loginbutton({super.key, required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Color(0xFF456246),
          borderRadius: BorderRadius.circular(40)
        ),
        child: Center(child: Text("Login", style: TextStyle(color: Colors.white, fontSize: 18),)),
      ),
    );
  }
}
