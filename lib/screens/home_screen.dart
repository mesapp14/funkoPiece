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

const Color colorDarkNavy = Color(0xFF0A2647);

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

    for (var f in allFunkos) {
      for (var v in f.variants) {
        // Chiave per saved preferences aggiornata
        final isOwned = prefs.getBool('owned_${f.number}_${v.type}') ?? false;

        bool matchesSearch =
            v.type.toLowerCase().contains(searchText) ||
            f.number.toString().contains(searchText) ||
            f.category.toLowerCase().contains(searchText);

        if (matchesSearch) tempAll.add(MapEntry(f.number, v));
        if (isOwned) tempOwned.add(MapEntry(f.number, v));
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
      extendBody: true,
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
            const Header(), 
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeIn,
                switchOutCurve: Curves.easeOut,
                child: _currentPage(),
              ),
            ),
          ],
        ),
      ),
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
          displayVariants: displayVariants,
          allFunkos: allFunkos,
          isGrid: isGridView,
          onToggle: () => setState(() => isGridView = !isGridView),
          onSearch: (v) {
            searchText = v.toLowerCase();
            applyFilters();
          },
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