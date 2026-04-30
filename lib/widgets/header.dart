import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        height: 60,
        alignment: Alignment.center,
        child: const Text(
          "PiratePop",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 4,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}