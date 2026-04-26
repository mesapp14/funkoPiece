import 'package:flutter/material.dart';
import '../../models/funko.dart';
import '../../services/funko_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Pages
import 'dashboard_page.dart';
import 'list_page.dart';
import 'forziere_page.dart';

// Widgets
import '../widgets/header.dart';
import '../widgets/bottom_nav.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Funko> allFunkos = [];
  List<MapEntry<int, FunkoVariant>> displayVariants = [];
  List<MapEntry<int, FunkoVariant>> ownedVariants = [];

  int selectedIndex = 0;
  String searchText = '';
  bool isGridView = true;

  @override
  void initState() {
    super.initState();
    _initLoad();
  }

  Future<void> _initLoad() async {
    final funkos = await loadFunkos();
    setState(() => allFunkos = funkos);
    await applyFilters();
  }

  Future<void> applyFilters() async {
    final prefs = await SharedPreferences.getInstance();
    List<MapEntry<int, FunkoVariant>> tempAll = [];
    List<MapEntry<int, FunkoVariant>> tempOwned = [];

    final query = searchText.toLowerCase().trim();

    for (var f in allFunkos) {
      for (var v in f.variants) {
        final isOwned = prefs.getBool('owned_${f.number}_${v.type}') ?? false;

        bool matchesSearch = 
            f.name.toLowerCase().contains(query) ||
            f.number.toString().contains(query) ||
            f.category.toLowerCase().contains(query) ||
            f.date.toLowerCase().contains(query) ||
            v.type.toLowerCase().contains(query);

        if (matchesSearch) {
          tempAll.add(MapEntry(f.number, v));
          if (isOwned) tempOwned.add(MapEntry(f.number, v));
        }
      }
    }

    setState(() {
      displayVariants = tempAll;
      ownedVariants = tempOwned;
    });
  }

  int get totalCatalogCount {
    int count = 0;
    for (var f in allFunkos) {
      count += f.variants.length;
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // MODIFIED: Remove extendBody: true to make the navbar sit normally at the bottom of the screen content area.
      // extendBody: true, // REMOVED THIS LINE
      
      // SFONDO MAPPA GLOBALE covers the whole body, but the navbar sits *below* this container.
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('ui/old_map_full_bg.png'), // SFONDO MAPPA ANTICA (the container of image_1.png)
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            const Header(), 
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _currentPage(),
              ),
            ),
            // The updated BottomNav is full-width. Ensure it is placed within this Column or the Scaffold's bottomNavigationBar slot.
          ],
        ),
      ),
      // MODIFIED: Placing the new full-width BottomNav in the Scaffold's bottomNavigationBar slot.
      bottomNavigationBar: BottomNav(
        selectedIndex: selectedIndex,
        onTap: (i) {
          setState(() => selectedIndex = i);
          applyFilters();
        },
      ),
    );
  }
  Widget _currentPage() {
    switch (selectedIndex) {
      case 0:
        return DashboardPage(
          key: const ValueKey(0),
          ownedVariants: ownedVariants,
          total: totalCatalogCount,
          allFunkos: allFunkos,
        );
      case 1:
        return ListPage(
          key: const ValueKey(1),
          allFunkos: allFunkos,
          allVariants: allFunkos
              .expand((f) => f.variants.map((v) => MapEntry(f.number, v)))
              .toList(),
          isGridInitial: isGridView,
        );
      case 2:
        return ForzierePage(
          key: const ValueKey(2),
          ownedVariants: ownedVariants,
          allFunkos: allFunkos,
        );
      default:
        return const SizedBox();
    }
  }
}