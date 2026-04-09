import 'package:flutter/material.dart';
import '../../../models/funko.dart';
import '../../../widgets/funko_card.dart';
import '../widgets/search_bar.dart';

class ListPage extends StatefulWidget {
  final List<Funko> allFunkos;
  final List<MapEntry<int, FunkoVariant>> allVariants; // Lista completa
  final bool isGridInitial;

  const ListPage({
    super.key,
    required this.allFunkos,
    required this.allVariants,
    this.isGridInitial = false,
  });

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  late List<MapEntry<int, FunkoVariant>> displayVariants;
  late bool isGrid;

  @override
  void initState() {
    super.initState();
    displayVariants = List.from(widget.allVariants); // Copia dei dati
    isGrid = widget.isGridInitial;
  }

  void _onSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        displayVariants = List.from(widget.allVariants);
      } else {
        displayVariants = widget.allVariants
            .where((e) =>
                e.value.type.toLowerCase().contains(query.toLowerCase()) ||
                widget.allFunkos
                    .firstWhere((f) => f.number == e.key)
                    .name
                    .toLowerCase()
                    .contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _onToggle() {
    setState(() {
      isGrid = !isGrid;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SearchBarWidget(
          onSearch: _onSearch,
          onToggle: _onToggle,
          isGrid: isGrid,
        ),
        Expanded(
          child: displayVariants.isEmpty
              ? const Center(
                  child: Text(
                    "Nessun Funko trovato",
                    style: TextStyle(color: Colors.white),
                  ),
                )
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
        final parent = widget.allFunkos.firstWhere((f) => f.number == e.key);
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
        final parent = widget.allFunkos.firstWhere((f) => f.number == e.key);
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