import 'package:flutter/material.dart';
import '../../../models/funko.dart';

class ForzierePage extends StatelessWidget {
  final List<MapEntry<int, FunkoVariant>> ownedVariants;
  final List<Funko> allFunkos;

  const ForzierePage({
    super.key,
    required this.ownedVariants,
    required this.allFunkos,
  });

  @override
  Widget build(BuildContext context) {
    if (ownedVariants.isEmpty) {
      return const Center(child: Text("Forziere vuoto"));
    }

    return ListWheelScrollView.useDelegate(
      itemExtent: 150,
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: ownedVariants.length,
        builder: (_, i) {
          final e = ownedVariants[i];
          final parent = allFunkos.firstWhere((f) => f.number == e.key);

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Qui non abbiamo più l'immagine, quindi possiamo mostrare solo testo
              Text(
                "#${parent.number} ${parent.name}",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 4),
              Text(
                "${e.value.type}${e.value.isChase ? ' 🔥 Chase' : ''}",
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 2),
              Text(
                "Categoria: ${parent.category}, Size: ${parent.size}",
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          );
        },
      ),
    );
  }
}