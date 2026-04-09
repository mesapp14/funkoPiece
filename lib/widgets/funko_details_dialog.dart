import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/funko.dart';

// Colori standard dell'app
const Color colorOffWhite = Color(0xFFF3F5F7);
const Color colorTealDark = Color(0xFF0A3038);

/// Funzione globale per mostrare il popup dei dettagli
void showFunkoDetails(
  BuildContext context, {
  required FunkoVariant variant,
  required int number,
  required String funkoName,
  required String saga,
  required String date,
  required String heroTag,
}) {
  // Helper per i percorsi immagini
  String getFunkoImagePath() {
    return variant.type == 'standard' 
        ? 'assets/images/$number.png' 
        : 'assets/images/${number}_${variant.type}.png';
  }

  String getTypeImagePath() => 'assets/funkoType/${variant.type}.png';

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Chiudi',
    barrierColor: Colors.black.withOpacity(0.6),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (dialogContext, _, _) {
      final double screenWidth = MediaQuery.of(context).size.width;

      return Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: screenWidth * 0.88,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1A374D), Color(0xFF06101D)],
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Immagine nel popup
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: colorOffWhite,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: Hero(
                    tag: heroTag,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 250),
                      child: Image.asset(
                        getFunkoImagePath(),
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.image_not_supported, 
                          color: colorTealDark, 
                          size: 40
                        ),
                      ),
                    ),
                  ),
                ),
                // Info nel popup
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            getTypeImagePath(),
                            width: 28,
                            height: 28,
                            errorBuilder: (_, _, _) => const Icon(Icons.stars, size: 28, color: Colors.amber),
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Text(
                              funkoName.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 22,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Divider(color: Colors.white10, height: 1),
                      const SizedBox(height: 24),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _buildDetailTile("NUMBER", "#$number", Icons.tag),
                          _buildDetailTile("TYPE", variant.type.toUpperCase(), Icons.category_outlined),
                          _buildDetailTile("SAGA", saga, Icons.auto_stories),
                          _buildDetailTile("RELEASE", date, Icons.calendar_today)
                        ],
                      ),
                      const SizedBox(height: 24),
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: Text(
                          "CHIUDI",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
    transitionBuilder: (_, animation, _, child) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
            child: child,
          ),
        ),
      );
    },
  );
}

Widget _buildDetailTile(String label, String value, IconData icon, {bool isSpecial = false}) {
  return Container(
    width: 130,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: isSpecial ? Colors.orange.withOpacity(0.1) : Colors.white.withOpacity(0.04),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isSpecial ? Colors.orange.withOpacity(0.3) : Colors.white.withOpacity(0.1),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: isSpecial ? Colors.orange : Colors.white38),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSpecial ? Colors.orange : Colors.white38,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}