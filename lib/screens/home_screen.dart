import 'package:flutter/material.dart';
import 'package:funko_catalog/models/funko.dart'; // Importa il modello
import 'package:funko_catalog/services/funko_service.dart'; // Importa il servizio
import 'package:funko_catalog/widgets/funko_card.dart'; // Importa il widget della card

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Funko> allFunkos = [];
  List<MapEntry<int, FunkoVariant>> displayVariants = [];
  String searchText = '';

  @override
  void initState() {
    super.initState();
    _initLoad();
  }

  Future<void> _initLoad() async {
    try {
      final funkos = await loadFunkos();
      setState(() {
        allFunkos = funkos;
        // Crea una lista di MapEntry per mappare il numero del Funko alla variante
        displayVariants = funkos
            .expand((f) => f.variants.map((v) => MapEntry(f.number, v)))
            .toList();
      });
    } catch (e) {
      debugPrint("Errore: $e");
    }
  }

  void filter(String query) {
    setState(() {
      searchText = query.toLowerCase();
      // Filtra le varianti in base al nome o al numero
      displayVariants = allFunkos
          .expand((f) => f.variants.map((v) => MapEntry(f.number, v)))
          .where((entry) =>
              entry.value.name.toLowerCase().contains(searchText) ||
              entry.key.toString().contains(searchText))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      // Usiamo il colore di sfondo del tema
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        // Usiamo il colore di superficie del tema per l'AppBar
        backgroundColor: colorScheme.surface,
        elevation: 1,
        title: TextField(
          decoration: InputDecoration(
            hintText: 'Search by name or number',
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search, color: colorScheme.onSurface),
          ),
          onChanged: filter,
          style: TextStyle(color: colorScheme.onSurface),
        ),
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      body: displayVariants.isEmpty
          ? Center(
              child: Text(
                'No Funkos found',
                style: TextStyle(color: colorScheme.onSurface),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: displayVariants.length,
              itemBuilder: (context, index) {
                final entry = displayVariants[index];
                // Troviamo il Funko originale per ottenere saga e data
                final parentFunko =
                    allFunkos.firstWhere((f) => f.number == entry.key);

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: FunkoCard(
                    variant: entry.value,
                    number: entry.key,
                    saga: parentFunko.saga, // Passiamo la saga
                    date: parentFunko.date, // Passiamo la data
                  ),
                );
              },
            ),
    );
  }
}