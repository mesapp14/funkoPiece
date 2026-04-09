import 'package:flutter/material.dart';
import 'dart:ui';
import '../models/funko.dart';
import '../widgets/horizontal_forziere.dart';

class RegistroPage extends StatefulWidget {
  final List<MapEntry<int, FunkoVariant>> ownedVariants;
  final List<Funko> allFunkos;

  const RegistroPage({
    super.key,
    required this.ownedVariants,
    required this.allFunkos,
  });

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  bool _isStatsExpanded = true;

  // GERARCHIA DEFINITIVA (9 LIVELLI)
  String getLevelName(double percentage) {
    if (percentage >= 1.0)  return "King of Pirates";
    if (percentage >= 0.90) return "Will of D.";
    if (percentage >= 0.80) return "Yonko";
    if (percentage >= 0.70) return "Yonko Commander";
    if (percentage >= 0.60) return "Shichibukai";
    if (percentage >= 0.50) return "New World Captain";
    if (percentage >= 0.40) return "Worst Gen. Supernova";
    if (percentage >= 0.25) return "Rookie";
    return "East Blue Pirate"; // Livello base da 0% a 24%
  }

  // Genera il percorso asset (es: assets/level/east_blue_pirate.png)
  String getLevelImage(String levelName) {
    String fileName = levelName.toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll('.', '')
        .replaceAll('(', '')
        .replaceAll(')', '');
    return "assets/level/$fileName.png";
  }

  // Calcolo Taglia (Bounty)
  String calculateBounty() {
    int totalBounty = 0;
    for (var entry in widget.ownedVariants) {
      if (entry.value.isChase) {
        totalBounty += 25000000; 
      } else if (entry.value.type != 'standard') {
        totalBounty += 10000000; 
      } else {
        totalBounty += 2000000;  
      }
    }
    return totalBounty.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }

  @override
  Widget build(BuildContext context) {
    int totalPossible = widget.allFunkos.fold(0, (sum, f) => sum + f.variants.length);
    double progress = totalPossible > 0 ? widget.ownedVariants.length / totalPossible : 0;
    String levelName = getLevelName(progress);

    // Mappatura statistiche per i progress bar
    Map<String, int> totalByType = {};
    Map<String, int> ownedByType = {};
    for (var f in widget.allFunkos) {
      for (var v in f.variants) {
        totalByType[v.type] = (totalByType[v.type] ?? 0) + 1;
      }
    }
    for (var entry in widget.ownedVariants) {
      ownedByType[entry.value.type] = (ownedByType[entry.value.type] ?? 0) + 1;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A2647),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 380,
            backgroundColor: Colors.transparent,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF1B4965), Color(0xFF0A2647)],
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 50),
                      Hero(
                        tag: 'rank_img',
                        child: Container(
                          width: 190,
                          height: 190,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF205295).withOpacity(0.5),
                                blurRadius: 40,
                              )
                            ],
                            image: DecorationImage(
                              image: AssetImage(getLevelImage(levelName)),
                              fit: BoxFit.cover,
                            ),
                            border: Border.all(color: Colors.white24, width: 4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      Text(
                        levelName.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "COLLECTION RANK: ${(progress * 100).toStringAsFixed(1)}%",
                        style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildWantedPoster(calculateBounty()),
                  const SizedBox(height: 25),
                  _buildStatCard(totalPossible, widget.ownedVariants.length, totalByType, ownedByType),
                  const SizedBox(height: 35),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Text(
                        "TREASURE BOX", 
                        style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  HorizontalForziere(ownedVariants: widget.ownedVariants),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildWantedPoster(String bounty) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: const Color(0xFFD4B483),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 15, offset: const Offset(0, 8))],
        border: Border.all(color: const Color(0xFF432818), width: 2),
      ),
      child: Column(
        children: [
          const Text("WANTED", 
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Color(0xFF432818), letterSpacing: 12)),
          const Text("DEAD OR ALIVE", 
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF432818))),
          const SizedBox(height: 15),
          Container(height: 2, color: const Color(0xFF432818), width: 220),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("฿ ", style: TextStyle(fontSize: 28, color: Color(0xFF432818), fontWeight: FontWeight.bold)),
              Text(bounty, 
                style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Color(0xFF432818), fontFamily: 'monospace')),
              const Text(" -", style: TextStyle(fontSize: 28, color: Color(0xFF432818), fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 5),
          const Text("MARINE ENFORCEMENT", style: TextStyle(fontSize: 8, color: Color(0xFF432818), fontWeight: FontWeight.bold, letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _buildStatCard(int total, int owned, Map<String, int> totalByType, Map<String, int> ownedByType) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            children: [
              ListTile(
                onTap: () => setState(() => _isStatsExpanded = !_isStatsExpanded),
                contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                title: const Text("Log of the Journey", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                subtitle: Text("$owned / $total Funko collected", style: const TextStyle(color: Colors.white38, fontSize: 12)),
                trailing: Icon(_isStatsExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.white54, size: 28),
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox(width: double.infinity),
                secondChild: Padding(
                  padding: const EdgeInsets.fromLTRB(25, 0, 25, 25),
                  child: Column(
                    children: totalByType.keys.map((type) {
                      int tCount = totalByType[type] ?? 0;
                      int oCount = ownedByType[type] ?? 0;
                      double p = tCount > 0 ? oCount / tCount : 0;
                      
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(type.toUpperCase(), style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w900)),
                                Text("$oCount/$tCount", style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Stack(
                              children: [
                                Container(
                                  height: 8,
                                  width: double.infinity,
                                  decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10)),
                                ),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 800),
                                  height: 8,
                                  width: (MediaQuery.of(context).size.width - 90) * p,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(colors: [Color(0xFF205295), Color(0xFF64B5F6)]),
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 4)],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                crossFadeState: _isStatsExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 300),
              )
            ],
          ),
        ),
      ),
    );
  }
}