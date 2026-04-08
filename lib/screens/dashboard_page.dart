import 'package:flutter/material.dart';
import '../widgets/percent_container.dart';
import '../widgets/horizontal_forziere.dart';
import '../widgets/registro_card.dart';
import '../widgets/last_releases_carousel.dart'; // Import del nuovo widget
import '../../models/funko.dart';

class DashboardPage extends StatelessWidget {
  final List<MapEntry<int, FunkoVariant>> ownedVariants;
  final int total;
  final List<Funko> allFunkos; // Aggiunto per passare i dati al carousel

  const DashboardPage({
    super.key,
    required this.ownedVariants,
    required this.total,
    required this.allFunkos, // Richiesto nel costruttore
  });

  @override
  Widget build(BuildContext context) {
    // Calcolo della percentuale di completamento
    double progress = total > 0 ? ownedVariants.length / total : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        // Distribuisce i widget in modo che lo spazio tra loro sia uguale
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Margine superiore ridotto per avvicinarsi all'header
          const SizedBox(height: 5),

          // NUOVO ELEMENTO: Carousel ultime uscite
          LastReleasesCarousel(allFunkos: allFunkos),

          // 1. Sezione Percentuale
          PercentContainer(
            progress: progress,
            owned: ownedVariants.length,
            total: total,
          ),

          // 2. Sezione Forziere Orizzontale
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

          // 3. Sezione Registro
          const RegistroCard(),

          // Spazio di sicurezza finale per la BottomNav (essendo extendBody: true)
          const SizedBox(height: 110),
        ],
      ),
    );
  }
}