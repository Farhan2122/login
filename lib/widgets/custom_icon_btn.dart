import 'package:flutter/material.dart';

class CustomIconBtn extends StatelessWidget {
  const CustomIconBtn({super.key, required this.text, required this.icon});
  final String text;
  final Icon icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130,
      child: TextButton(
        onPressed: () {},
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(text), 
            icon,
            ],
            ),
            style: ElevatedButton.styleFrom(
              side: BorderSide(),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              backgroundColor: Colors.grey.shade200,
              foregroundColor: Colors.black
            ),
      ),
    );
  }
}
