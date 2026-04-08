import 'package:flutter/material.dart';

const Color colorSteelBlue = Color(0xFF205295);

class RegistroCard extends StatelessWidget {
  const RegistroCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
     decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Registro di Bordo",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 8),
          const Text("Esplora le statistiche della tua collezione.",
              style: TextStyle(color: Colors.white54, fontSize: 13)),
          const SizedBox(height: 25),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: colorSteelBlue,
              minimumSize: const Size(double.infinity, 55),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text("APRI REGISTRO",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white)),
          )
        ],
      ),
    );
  }
}