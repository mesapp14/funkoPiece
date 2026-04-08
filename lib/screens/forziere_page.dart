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
      itemExtent: 350,
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: ownedVariants.length,
        builder: (_, i) {
          final e = ownedVariants[i];
          final parent = allFunkos.firstWhere((f) => f.number == e.key);

          return Column(
            children: [
              Expanded(child: Image.network(e.value.image)),
              Text("#${parent.number} ${e.value.name}")
            ],
          );
        },
      ),
    );
  }
}