import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';
import '../models/funko.dart'; 
import '../services/funko_service.dart'; 
import '../widgets/funko_card.dart'; 
import 'package:flutter/services.dart';

// Palette Deep Sea raffinata
const Color colorDarkNavy = Color(0xFF0A2647);
const Color colorMidBlue = Color(0xFF144272);
const Color colorSteelBlue = Color(0xFF205295);
const Color colorCyanAccent = Color(0xFFFFFFFF);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Funko> allFunkos = [];
  List<MapEntry<int, FunkoVariant>> displayVariants = [];
  List<MapEntry<int, FunkoVariant>> ownedVariants = []; 
  
  int _selectedIndex = 0; 
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _initLoad();
  }

  // Caricamento iniziale
  Future<void> _initLoad() async {
    try {
      final funkos = await loadFunkos();
      setState(() => allFunkos = funkos);
      await _applyFilters();
    } catch (e) {
      debugPrint("Errore: $e");
    }
  }

  // Funzione CRUCIALE: rilegge le SharedPreferences e aggiorna le liste
  Future<void> _applyFilters() async {
    final prefs = await SharedPreferences.getInstance();
    List<MapEntry<int, FunkoVariant>> tempAll = [];
    List<MapEntry<int, FunkoVariant>> tempOwned = [];

    for (var f in allFunkos) {
      for (var v in f.variants) {
        // Verifica se posseduto
        final isOwned = prefs.getBool('owned_${f.number}_${v.name}') ?? false;
        
        bool matchesSearch = v.name.toLowerCase().contains(_searchText) ||
                            f.number.toString().contains(_searchText) ||
                            f.saga.toLowerCase().contains(_searchText);

        if (matchesSearch) tempAll.add(MapEntry(f.number, v));
        if (isOwned) tempOwned.add(MapEntry(f.number, v));
      }
    }
    setState(() {
      displayVariants = tempAll;
      ownedVariants = tempOwned;
    });
  }

  int get _totalCatalogCount {
    int count = 0;
    for (var f in allFunkos) count += f.variants.length;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      // SFONDO CON GRADIENTE MODERNO
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [colorDarkNavy, Color(0xFF0D345D)], 
          ),
        ),
        child: Column(
          children: [
            _buildModernHeader(),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildCurrentPage(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildModernHeader() {
    return SafeArea(
      bottom: false,
      child: Container(
        height: 60,
        alignment: Alignment.center,
        child: const Text(
          "FunkoPiece",
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 4, fontSize: 22, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildCurrentPage() {
    switch (_selectedIndex) {
      case 0: return _buildHomeDashboard();
      case 1: return _buildFunkoList();
      case 2: return _buildForziere3D();
      default: return const SizedBox();
    }
  }

  // --- DASHBOARD HOME ---
  Widget _buildHomeDashboard() {
    int total = _totalCatalogCount;
    double progress = total > 0 ? (ownedVariants.length / total) : 0;

    return SingleChildScrollView(
      key: const ValueKey(0),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("LA TUA ROTTA"),
          const SizedBox(height: 15),
          _buildPercentContainer(progress, total),
          
          const SizedBox(height: 35),
          
          _buildSectionTitle("FORZIERE"),
          const SizedBox(height: 15),
          _buildHorizontalForziere(),

          const SizedBox(height: 35),

          // Label "Logbook" eliminata come richiesto
          _buildRegistroBordoCard(),
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _buildPercentContainer(double progress, int totalCount) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        // Gradiente interno alla card
        gradient: LinearGradient(
          colors: [colorMidBlue.withOpacity(0.6), colorDarkNavy.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Completamento", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w500)),
              Text("${(progress * 100).toStringAsFixed(1)}%", 
                style: const TextStyle(fontWeight: FontWeight.bold, color: colorCyanAccent, fontSize: 18)),
            ],
          ),
          const SizedBox(height: 15),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.white.withOpacity(0.05),
              valueColor: const AlwaysStoppedAnimation<Color>(colorCyanAccent),
            ),
          ),
          const SizedBox(height: 12),
          Text("${ownedVariants.length} / $totalCount pezzi nel forziere", 
            style: const TextStyle(fontSize: 12, color: Colors.white38, letterSpacing: 0.5)),
        ],
      ),
    );
  }

  Widget _buildHorizontalForziere() {
    if (ownedVariants.isEmpty) {
      return const Text("Il forziere è vuoto...", style: TextStyle(color: Colors.white24));
    }
    return SizedBox(
      height: 190,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: ownedVariants.length,
        itemBuilder: (context, index) {
          final v = ownedVariants[index].value;
          final num = ownedVariants[index].key;
          
          return Container(
            width: 140,
            margin: const EdgeInsets.only(right: 15),
            // GLASSMORPHISM CARD
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Image.network(v.image, fit: BoxFit.contain),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 15),
                        child: Text(
                          "#$num ${v.name}", 
                          maxLines: 1, 
                          overflow: TextOverflow.ellipsis, // Gestione nomi lunghi (...)
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRegistroBordoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Registro di Bordo", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          const Text("Esplora le statistiche della tua collezione.", style: TextStyle(color: Colors.white54, fontSize: 13)),
          const SizedBox(height: 25),
          ElevatedButton(
            onPressed: () {}, 
            style: ElevatedButton.styleFrom(
              backgroundColor: colorSteelBlue,
              minimumSize: const Size(double.infinity, 55),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text("APRI REGISTRO", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          )
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: colorCyanAccent));
  }

  Widget _buildFunkoList() {
    return Column(
      children: [
        _buildSearchBox(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 140), 
            itemCount: displayVariants.length,
            itemBuilder: (context, index) {
              final entry = displayVariants[index];
              final parent = allFunkos.firstWhere((f) => f.number == entry.key);
              return FunkoCard(variant: entry.value, number: entry.key, saga: parent.saga, date: parent.date);
            },
          ),
        ),
      ],
    );
  }

  // --- SEZIONE FORZIERE (3D) ---
  Widget _buildForziere3D() {
    if (ownedVariants.isEmpty) return const Center(child: Text("Forziere vuoto"));
    
    return ListWheelScrollView.useDelegate(
      itemExtent: 350,
      perspective: 0.003,
      physics: const BouncingScrollPhysics(),
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: ownedVariants.length,
        builder: (context, index) {
          final entry = ownedVariants[index];
          final parent = allFunkos.firstWhere((f) => f.number == entry.key);
          return _build3DCard(entry.value, parent);
        },
      ),
    );
  }

  Widget _build3DCard(FunkoVariant variant, Funko parent) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          Expanded(child: Image.network(variant.image, fit: BoxFit.contain)),
          Text("#${parent.number} ${variant.name}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSearchBox() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: TextField(
        onChanged: (v) { _searchText = v.toLowerCase(); _applyFilters(); },
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "Cerca tesori...",
          hintStyle: const TextStyle(color: Colors.white24),
          prefixIcon: const Icon(Icons.search, color: colorCyanAccent),
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 30),
      height: 75,
      decoration: BoxDecoration(
        color: colorDarkNavy.withOpacity(0.9),
        borderRadius: BorderRadius.circular(35),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home_filled, "Home", 0),
          _buildNavItem(Icons.grid_view_rounded, "Lista", 1),
          _buildNavItem(Icons.inventory_2_rounded, "Forziere", 2),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedIndex = index);
        _applyFilters(); // AGGIORNA I DATI OGNI VOLTA CHE CAMBI TAB
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isSelected ? colorCyanAccent : Colors.white30, size: 26),
          Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.white30, fontSize: 10)),
        ],
      ),
    );
  }
}