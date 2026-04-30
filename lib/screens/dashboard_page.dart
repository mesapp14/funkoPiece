import 'package:flutter/material.dart';
import '../widgets/last_releases_carousel.dart';
import '../../models/funko.dart';
import 'registro_page.dart'; 

class DashboardPage extends StatefulWidget {
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
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Funzione di navigazione aggiornata con i parametri richiesti
  void _navigateToRegistro() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegistroPage(
          ownedVariants: widget.ownedVariants, // Passa i dati richiesti
          allFunkos: widget.allFunkos,         // Passa i dati richiesti
        ),
      ),
    );
  }

  String _getRank(double percentage) {
    if (percentage >= 1.0) return "King of Pirates";
    if (percentage >= 0.80) return "Yonko";
    if (percentage >= 0.70) return "Yonko Commander";
    if (percentage >= 0.50) return "New World Captain";
    return "East Blue Pirate";
  }

  @override
  Widget build(BuildContext context) {
    double progress = widget.total > 0 ? widget.ownedVariants.length / widget.total : 0;
    String rank = _getRank(progress);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
        child: Column(
          children: [
            // --- 1. CAPTAIN'S STATUS ---
            _buildStatusSection(rank, progress),

            const SizedBox(height: 25),

            // --- 2. SHIP'S LOG ---
            _buildLogSection(_navigateToRegistro), 

            const SizedBox(height: 25),

            // --- 3. LATEST BOUNTIES ---
            _buildBountiesSection(),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection(String rank, double progress) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double containerWidth = constraints.maxWidth;
        return Container(
          width: double.infinity,
          height: 220,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('ui/parchment_box.png'),
              fit: BoxFit.fill,
            ),
          ),
          child: Stack(
            children: [
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
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Colors.brown[900]?.withOpacity(0.8),
                      letterSpacing: 2.0,
                      shadows: const [Shadow(offset: Offset(1, 1), blurRadius: 2, color: Colors.black26)],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 135,
                left: containerWidth * 0.22,
                right: containerWidth * 0.22,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 12,
                    backgroundColor: Colors.brown.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.brown[800]!),
                  ),
                ),
              ),
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

  Widget _buildLogSection(VoidCallback onTap) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double containerWidth = constraints.maxWidth;
        double containerHeight = containerWidth * (680 / 1144);

        return Container(
          width: double.infinity,
          height: containerHeight,
          margin: const EdgeInsets.symmetric(horizontal: 10),
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('ui/ships_log_container.PNG'),
              fit: BoxFit.fill,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: containerHeight * 0.09,
                left: 0,
                right: 0,
                child: Text(
                  "SHIP'S LOG",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: containerWidth * 0.065,
                    fontWeight: FontWeight.w900,
                    color: Colors.brown[900],
                  ),
                ),
              ),
              Positioned(
                bottom: containerHeight * 0.052,
                left: containerWidth * 0.338,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onTap,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: containerWidth * 0.38,
                      height: containerHeight * 0.12,
                      alignment: Alignment.center,
                      child: const Text(
                        "VIEW LOGS",
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [Shadow(blurRadius: 2, color: Colors.black)],
                        ),
                      ),
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
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 120,
          child: LastReleasesCarousel(allFunkos: widget.allFunkos),
        ),
      ],
    );
  }
}