import 'package:flutter/material.dart';
import '../models/funko.dart';
import '../screens/registro_page.dart';

const Color colorSteelBlue = Color(0xFF205295);

class RegistroCard extends StatelessWidget {
  final List<MapEntry<int, FunkoVariant>> ownedVariants;
  final List<Funko> allFunkos;

  const RegistroCard({
    super.key,
    required this.ownedVariants,
    required this.allFunkos,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Ship's Log",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 8),
          const Text("Check your status in the pirate hierarchy.",
              style: TextStyle(color: Colors.white54, fontSize: 13)),
          const SizedBox(height: 25),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RegistroPage(
                    ownedVariants: ownedVariants,
                    allFunkos: allFunkos,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorSteelBlue,
              minimumSize: const Size(double.infinity, 55),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text("VIEW LOGS",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white)),
          )
        ],
      ),
    );
  }
}