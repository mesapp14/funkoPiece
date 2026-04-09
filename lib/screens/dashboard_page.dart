import 'package:flutter/material.dart';
import '../widgets/percent_container.dart';
import '../widgets/horizontal_forziere.dart';
import '../widgets/registro_card.dart';
import '../widgets/last_releases_carousel.dart';
import '../../models/funko.dart';

class DashboardPage extends StatelessWidget {
  final List<MapEntry<int, FunkoVariant>> ownedVariants;
  final int total;
  final List<Funko> allFunkos;

  const DashboardPage({
    super.key,
    required this.ownedVariants,
    required this.total,
    required this.allFunkos,
  });

  @override
  Widget build(BuildContext context) {
    double progress = total > 0 ? ownedVariants.length / total : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(height: 5),

          // 🔁 1. Percentuale (ORA SOPRA)
          PercentContainer(
            progress: progress,
            owned: ownedVariants.length,
            total: total,
          ),

                   // 4. Registro
     


          // 3. Forziere
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 8.0, bottom: 12),
                child: Text(
                  "Il Tuo Forziere",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              HorizontalForziere(ownedVariants: ownedVariants),
            ],
          ),
          RegistroCard(
            ownedVariants: ownedVariants,
            allFunkos: allFunkos,
          ),
          LastReleasesCarousel(allFunkos: allFunkos),


          const SizedBox(height: 110),
        ],
      ), 
    );
  }
}