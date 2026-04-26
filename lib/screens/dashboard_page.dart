import 'package:flutter/material.dart';
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

  String _getRank(double percentage) {
    if (percentage >= 1.0) return "King of Pirates";
    if (percentage >= 0.80) return "Yonko";
    if (percentage >= 0.70) return "Yonko Commander";
    if (percentage >= 0.50) return "New World Captain";
    return "East Blue Pirate";
  }

  @override
  Widget build(BuildContext context) {
    double progress = total > 0 ? ownedVariants.length / total : 0;
    String rank = _getRank(progress);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
        child: Column(
          children: [
            // --- 1. CAPTAIN'S STATUS (Box Pergamena) ---
            _buildStatusSection(rank, progress),

            const SizedBox(height: 25),

            // --- 2. IL FORZIERE (Cornice Legno) ---
           /* _buildChestSection(),

            const SizedBox(height: 25),*/

            // --- 3. SHIP'S LOG (Rotolo Pergamena) ---
            _buildLogSection(),

            const SizedBox(height: 25),

            // --- 4. ULTIMI ARRIVI (Monete d'oro) ---
            _buildBountiesSection(),

            const SizedBox(height: 100), // Padding per BottomNav
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection(String rank, double progress) {
  return LayoutBuilder(
    builder: (context, constraints) {
      // Calcoliamo proporzioni basate sulla larghezza del container per la responsività
      double containerWidth = constraints.maxWidth;
      double containerHeight = containerWidth * 0.5; // Mantiene il rapporto dell'immagine

      return Container(
        width: double.infinity,
        height: 220, // Altezza fissa o dinamica per contenere il design
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('ui/parchment_box.png'),
            fit: BoxFit.fill,
          ),
        ),
        child: Stack(
          children: [
            // 1. RANK: Ingrandito e centrato nella sezione superiore di legno
            Positioned(
              top: 35,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  rank.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 26, // Ingrandito
                    fontWeight: FontWeight.w900,
                    color: Colors.brown[900]?.withOpacity(0.8),
                    letterSpacing: 2.0,
                    shadows: const [
                      Shadow(offset: Offset(1, 1), blurRadius: 2, color: Colors.black26)
                    ],
                  ),
                ),
              ),
            ),

            // 2. PROGRESS BAR: Posizionata sopra il sentiero della mappa
            // Situata tra la nave disegnata e le isole
            Positioned(
              top: 135,
              left: containerWidth * 0.22, // Inizia dopo la nave disegnata
              right: containerWidth * 0.22, // Finisce prima delle isole
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 12,
                      backgroundColor: Colors.brown.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.brown[800]!),
                    ),
                  ),
                ],
              ),
            ),

            // 3. COMPLETION %: Spostata in basso sulla pergamena arrotolata
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  "COMPLETION: ${(progress * 100).toStringAsFixed(1)}%",
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown[900],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
  
  /*Widget _buildChestSection() {
    return Column(
      children: [
        Image.asset('ui//label_treasure_chest.png', width: 220), // TITOLO IN LEGNO
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('ui//wood_frame_bg.png'), // SFONDO CORNICE LEGNO
              fit: BoxFit.fill,
            ),
          ),
          child: HorizontalForziere(ownedVariants: ownedVariants),
        ),
      ],
    );
  }
*/
  
  Widget _buildLogSection() {
  return LayoutBuilder(
    builder: (context, constraints) {
      double containerWidth = constraints.maxWidth;
      // Il rapporto dell'immagine fornita è 1144x680
      double containerHeight = containerWidth * (680 / 1144);

      final TextStyle headerStyle = TextStyle(
        fontFamily: 'serif',
        fontSize: containerWidth * 0.065,
        fontWeight: FontWeight.w900,
        color: Colors.brown[900],
        shadows: const [Shadow(offset: Offset(1, 1), blurRadius: 2, color: Colors.black26)],
      );

      final TextStyle descriptionStyle = TextStyle(
        fontFamily: 'serif',
        fontSize: containerWidth * 0.032,
        fontWeight: FontWeight.w500,
        color: Colors.brown[800],
      );

      final TextStyle buttonTextStyle = TextStyle(
        fontFamily: 'serif',
        fontSize: containerWidth * 0.035, // Leggermente ridotto per stare nel rettangolo
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: 1.2,
        shadows: const [Shadow(offset: Offset(1, 1), blurRadius: 2, color: Colors.black)],
      );

      return Container(
        width: double.infinity,
        height: containerHeight,
        margin: const EdgeInsets.symmetric(horizontal: 10),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('ui/ships_log_container.PNG'), // Usiamo il file corretto
            fit: BoxFit.fill,
          ),
        ),
        child: Stack(
          children: [
            // --- 1. ICONA ANCORA (Invariata) ---
            Positioned(
              top: containerHeight * 0.12,
              left: containerWidth * 0.06,
              child: Transform.rotate(
                angle: -0.25,
                child: Image.asset('ui/anchor_icon.png', width: containerWidth * 0.12),
              ),
            ),

            // --- 2. ICONA TESCHIO (Invariata) ---
            Positioned(
              top: containerHeight * 0.10,
              right: containerWidth * 0.05,
              child: Transform.rotate(
                angle: 0.20,
                child: Image.asset('ui/strawhat_skull_icon.png', width: containerWidth * 0.14),
              ),
            ),

            // --- 3. SHIP'S LOG: Titolo (Alzato ancora un po') ---
            Positioned(
              top: containerHeight * 0.09, // Alzato ulteriormente
              left: 0,
              right: 0,
              child: Text(
                "SHIP'S LOG",
                textAlign: TextAlign.center,
                style: headerStyle,
              ),
            ),

            // --- 4. SOTTOTITOLO (Alzato vicino al titolo) ---
            Positioned(
              top: containerHeight * 0.23, // Alzato (era 0.21)
              left: containerWidth * 0.20,
              right: containerWidth * 0.20,
              child: Text(
                "CHECK YOUR PIRATE STATUS",
                textAlign: TextAlign.center,
                style: descriptionStyle,
              ),
            ),

            // --- 5. VIEW LOGS BUTTON: CENTRATURA CHIRURGICA ---
            Positioned(
              bottom: containerHeight * 0.052, // Regolato per stare nel centro verticale del rosso
              left: containerWidth * 0.338,   // Inizio dell'area rossa (dopo il sigillo)
              child: InkWell(
                onTap: () { /* Logica navigazione */ },
                child: Container(
                  width: containerWidth * 0.38, // Larghezza esatta della barra rossa
                  height: containerHeight * 0.12, // Altezza dell'area cliccabile
                  alignment: Alignment.center, // Centra il testo nel rettangolo definito sopra
                  child: Text(
                    "VIEW LOGS",
                    style: buttonTextStyle,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
 
 
  Widget _buildBountiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 10, bottom: 15),
          child: Text(
            "LATEST BOUNTIES",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              shadows: [Shadow(blurRadius: 4, color: Colors.black)],
            ),
          ),
        ),
        SizedBox(
          height: 120,
          child: LastReleasesCarousel(allFunkos: allFunkos),
          // Suggerimento: nel widget FunkoCard del carousel, 
          // avvolgi l'immagine con ui//gold_coin.png
        ),
      ],
    );
  }
}