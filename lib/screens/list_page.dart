import 'package:flutter/material.dart';
import '../../../models/funko.dart';
import '../../../widgets/funko_card.dart';
import '../widgets/search_bar.dart';

class ListPage extends StatelessWidget { // Trasformato in StatelessWidget per semplicità
  final List<Funko> allFunkos;
  final List<MapEntry<int, FunkoVariant>> displayVariants; // Riceve i dati filtrati
  final Function(String) onSearch; // Riceve la funzione di ricerca
  final bool isGrid;
  final VoidCallback onToggle;

  const ListPage({
    super.key,
    required this.allFunkos,
    required this.displayVariants,
    required this.onSearch,
    required this.isGrid,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SearchBarWidget(
          onSearch: onSearch, // Passa il comando al padre
          onToggle: onToggle,
          isGrid: isGrid,
        ),
        Expanded(
          child: displayVariants.isEmpty 
            ? const Center(child: Text("Nessun Funko trovato", style: TextStyle(color: Colors.white)))
            : (isGrid ? _grid() : _list()),
        ),
      ],
    );
  }

  Widget _list() {
    return ListView.builder(
      itemCount: displayVariants.length,
      itemBuilder: (_, i) {
        final e = displayVariants[i];
        final parent = allFunkos.firstWhere((f) => f.number == e.key);
        return FunkoCard(
          variant: e.value,
          number: e.key,
          funkoName: parent.name,
          date: parent.date,
          isGrid: false,
        );
      },
    );
  }

  Widget _grid() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.70,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: displayVariants.length,
      itemBuilder: (_, i) {
        final e = displayVariants[i];
        final parent = allFunkos.firstWhere((f) => f.number == e.key);
        return FunkoCard(
          variant: e.value,
          number: e.key,
          funkoName: parent.name,
          date: parent.date,
          isGrid: true,
        );
      },
    );
  }
}