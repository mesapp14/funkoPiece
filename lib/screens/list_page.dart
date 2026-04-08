import 'package:flutter/material.dart';
import '../../../models/funko.dart';
import '../../../widgets/funko_card.dart';
import '../widgets/search_bar.dart';

class ListPage extends StatelessWidget {
  final List<MapEntry<int, FunkoVariant>> displayVariants;
  final List<Funko> allFunkos;
  final bool isGrid;
  final VoidCallback onToggle;
  final Function(String) onSearch;

  const ListPage({
    super.key,
    required this.displayVariants,
    required this.allFunkos,
    required this.isGrid,
    required this.onToggle,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SearchBarWidget(onSearch: onSearch, onToggle: onToggle, isGrid: isGrid),
        Expanded(child: isGrid ? _grid() : _list()),
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
          funkoName: parent.name, // <-- aggiunto
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
        childAspectRatio: 0.58,
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
          funkoName: parent.name, // <-- aggiunto
          date: parent.date,
          isGrid: true,
        );
      },
    );
  }
}