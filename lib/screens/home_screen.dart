import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';
import '../models/funko.dart'; 
import '../services/funko_service.dart'; 
import '../widgets/funko_card.dart'; 
import 'package:flutter/services.dart';

const Color colorTealDark = Color(0xFF0A3038); 
const Color colorTealAccent = Color.fromARGB(255, 255, 255, 255); 
const Color colorOffWhite = Color(0xFFF3F5F7);
const Color colorRed = Color(0xFFE57373);
const Color colorGreen = Color(0xFF81C784);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Funko> allFunkos = [];
  List<MapEntry<int, FunkoVariant>> displayVariants = [];
  List<MapEntry<int, FunkoVariant>> ownedVariants = []; // Per l'armadio
  
  int _selectedIndex = 0; 
  String _searchText = '';
  int _filterOwnedStatus = 0; 

  @override
  void initState() {
    super.initState();
    _initLoad();
  }

  Future<void> _initLoad() async {
    try {
      final funkos = await loadFunkos();
      allFunkos = funkos;
      await _applyFilters();
    } catch (e) {
      debugPrint("Errore: $e");
    }
  }

  Future<void> _applyFilters() async {
    final prefs = await SharedPreferences.getInstance();
    List<MapEntry<int, FunkoVariant>> tempAll = [];
    List<MapEntry<int, FunkoVariant>> tempOwned = [];

    for (var f in allFunkos) {
      for (var v in f.variants) {
        final isOwned = prefs.getBool('owned_${f.number}_${v.name}') ?? false;
        
        bool matchesSearch = v.name.toLowerCase().contains(_searchText) ||
                            f.number.toString().contains(_searchText) ||
                            f.saga.toLowerCase().contains(_searchText);

        bool matchesStatus = true;
        if (_filterOwnedStatus == 1) matchesStatus = isOwned;
        if (_filterOwnedStatus == 2) matchesStatus = !isOwned;

        if (matchesSearch && matchesStatus) {
          tempAll.add(MapEntry(f.number, v));
        }
        
        if (isOwned) {
          tempOwned.add(MapEntry(f.number, v));
        }
      }
    }

    setState(() {
      displayVariants = tempAll;
      ownedVariants = tempOwned;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _selectedIndex == 0 ? colorOffWhite : const Color(0xFF05191D), // Sfondo più scuro per l'armadio
      extendBody: true,
      appBar: _selectedIndex == 0 ? _buildAppBar() : null, // Nascondiamo l'appbar nell'armadio per più immersione
      body: _selectedIndex == 0 
          ? _buildFunkoList() 
          : _buildArmadio3D(),

      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // --- WIDGET ARMADIO 3D (IL PEZZO WOW) ---
  Widget _buildArmadio3D() {
    if (ownedVariants.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 100, color: colorTealAccent.withOpacity(0.2)),
            const SizedBox(height: 20),
            const Text("L'armadio è vuoto...", style: TextStyle(color: Colors.white70, fontSize: 18)),
            const Text("Aggiungi i tuoi Funko dalla lista!", style: TextStyle(color: Colors.white38)),
          ],
        ),
      );
    }

    return Stack(
      children: [
        // Sfondo con gradiente radiale per profondità
        Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.5,
              colors: [Color(0xFF0A3038), Color(0xFF020A0B)],
            ),
          ),
        ),
        
        ListWheelScrollView.useDelegate(
          itemExtent: 380, // Altezza di ogni card nell'armadio
          perspective: 0.004, // Effetto curvatura 3D
          diameterRatio: 2.0,
          physics: const BouncingScrollPhysics(),
          onSelectedItemChanged: (index) {
            HapticFeedback.lightImpact();
          },
          childDelegate: ListWheelChildBuilderDelegate(
            childCount: ownedVariants.length,
            builder: (context, index) {
              final entry = ownedVariants[index];
              final parentFunko = allFunkos.firstWhere((f) => f.number == entry.key);

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Hero(
                  tag: 'cabinet_${entry.key}_${entry.value.name}',
                  child: _buildCabinetCard(entry.value, parentFunko),
                ),
              );
            },
          ),
        ),

        // Titolo Fluttuante Armadio
        PositionStatus(),
      ],
    );
  }

  Widget _buildCabinetCard(FunkoVariant variant, Funko parent) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: colorTealAccent.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  child: Image.network(
                    variant.image,
                    fit: BoxFit.contain,
                    errorBuilder: (c, e, s) => const Icon(Icons.toys, size: 80, color: Colors.white24),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  width: double.infinity,
                  color: Colors.white.withOpacity(0.05),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(variant.name, 
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      Text("#${parent.number} - ${parent.saga}", 
                        style: TextStyle(color: colorTealAccent.withOpacity(0.7), fontSize: 14)),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // --- RESTO DEI METODI ESISTENTI (PULITI) ---
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      toolbarHeight: 110,
      backgroundColor: colorOffWhite,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      title: _buildSearchBox(),
    );
  }

  Widget _buildSearchBox() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: colorTealDark.withOpacity(0.4)),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              onChanged: (value) { _searchText = value.toLowerCase(); _applyFilters(); },
              decoration: const InputDecoration(hintText: 'Search...', border: InputBorder.none),
            ),
          ),
          _buildFilterToggle(),
        ],
      ),
    );
  }

  Widget _buildFilterToggle() {
    return GestureDetector(
      onTap: () {
        setState(() => _filterOwnedStatus = (_filterOwnedStatus + 1) % 3);
        _applyFilters();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 34, height: 34,
        decoration: BoxDecoration(
          color: _filterOwnedStatus == 0 ? Colors.grey.withOpacity(0.2) : (_filterOwnedStatus == 1 ? colorGreen : colorRed),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Icon(
          _filterOwnedStatus == 0 ? Icons.filter_list : (_filterOwnedStatus == 1 ? Icons.check : Icons.close),
          size: 16, color: _filterOwnedStatus == 0 ? Colors.black54 : Colors.white,
        ),
      ),
    );
  }

  Widget _buildFunkoList() {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 10, bottom: 140), 
      itemCount: displayVariants.length,
      itemBuilder: (context, index) {
        final entry = displayVariants[index];
        final parentFunko = allFunkos.firstWhere((f) => f.number == entry.key);
        return FunkoCard(variant: entry.value, number: entry.key, saga: parentFunko.saga, date: parentFunko.date);
      },
    );
  }

  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 30),
      height: 75,
      decoration: BoxDecoration(
        color: colorTealDark,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [BoxShadow(color: colorTealDark.withOpacity(0.4), blurRadius: 25, offset: const Offset(0, 12))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.auto_awesome_motion_rounded, "Lista", 0),
          _buildNavItem(Icons.inventory_2_rounded, "Armadio", 1),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedIndex = index);
        _applyFilters(); // Aggiorna l'armadio ogni volta che ci entri
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isSelected ? colorTealAccent : Colors.white.withOpacity(0.4), size: 28),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.white.withOpacity(0.4), fontSize: 12)),
        ],
      ),
    );
  }
}

// Widget extra per l'etichetta dell'armadio
class PositionStatus extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 60, left: 0, right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white10),
          ),
          child: const Text("Armadio", 
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 12)),
        ),
      ),
    );
  }
}