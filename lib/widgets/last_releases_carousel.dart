import 'package:flutter/material.dart';
import '../../../models/funko.dart';
import '../../widgets/funko_details_dialog.dart';

class LastReleasesCarousel extends StatelessWidget {
  final List<Funko> allFunkos;

  const LastReleasesCarousel({
    super.key,
    required this.allFunkos,
  });

  @override
  Widget build(BuildContext context) {
    // Creiamo una lista completa di oggetti con i metadati necessari
    List<Map<String, dynamic>> allItems = [];
    for (var f in allFunkos) {
      for (var v in f.variants) {
        allItems.add({
          'funko': f,
          'variant': v,
        });
      }
    }

    // Ordiniamo per numero decrescente (dal più recente al più vecchio)
    allItems.sort((a, b) => (b['funko'] as Funko).number.compareTo((a['funko'] as Funko).number));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8.0, bottom: 12),
          child: Text(
            "ULTIMI ARRIVI",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(), // Mantieni lo scroll morbido
            itemCount: allItems.length, // Nessun limite, li prende tutti
            itemBuilder: (context, index) {
              final item = allItems[index];
              final Funko f = item['funko'];
              final FunkoVariant v = item['variant'];
              
              final heroTag = 'carousel_hero_${f.number}_${v.type}';

              return Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: GestureDetector(
                  onTap: () {
                    showFunkoDetails(
                      context,
                      variant: v,
                      number: f.number,
                      funkoName: f.name,
                      saga: f.category,
                      date: f.date,
                      heroTag: heroTag,
                    );
                  },
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
                        child: Hero(
                          tag: heroTag,
                          child: Image.asset(
                            v.type == 'standard' 
                                ? "assets/images/${f.number}.png" 
                                : "assets/images/${f.number}_${v.type}.png",
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) => const Icon(
                              Icons.toys_outlined,
                              color: Colors.white24,
                              size: 30,
                            ),
                          ),
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