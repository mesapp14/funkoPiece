import 'package:flutter/material.dart';
import '../../../models/funko.dart';

class LastReleasesCarousel extends StatelessWidget {
  final List<Funko> allFunkos;

  const LastReleasesCarousel({
    super.key,
    required this.allFunkos,
  });

  @override
  Widget build(BuildContext context) {
    // Creiamo una lista piatta di tutti i variant
    List<MapEntry<int, FunkoVariant>> allVariants = [];
    for (var f in allFunkos) {
      for (var v in f.variants) {
        allVariants.add(MapEntry(f.number, v));
      }
    }

    // Ordiniamo per numero decrescente (dal più recente)
    allVariants.sort((a, b) => b.key.compareTo(a.key));

    // Prendiamo i primi 10 (o meno se la collezione è piccola)
    final lastTen = allVariants.take(10).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8.0, bottom: 12),
          child: Text(
            "ULTIMI ARRIVI: TOP 10",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ),
        SizedBox(
          height: 80, // Altezza del cerchietto + padding
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: lastTen.length,
            itemBuilder: (context, index) {
              final num = lastTen[index].key;
              
              return Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                  child: ClipOval(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        "assets/images/$num.png",
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => Icon(
                          Icons.toys_outlined,
                          color: Colors.white24,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}