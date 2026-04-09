import 'dart:async';
import 'package:flutter/material.dart';

const Color colorCyanAccent = Color(0xFFFFFFFF);

class SearchBarWidget extends StatefulWidget {
  final Function(String) onSearch;
  final VoidCallback onToggle;
  final bool isGrid;

  const SearchBarWidget({
    Key? key,
    required this.onSearch,
    required this.onToggle,
    required this.isGrid,
  }) : super(key: key);

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  Timer? _debounce;

  void _onChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () {
      widget.onSearch(value);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: _onChanged,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: "Cerca tesori...",
                hintStyle: const TextStyle(
                  color: Colors.white24,
                  fontSize: 14,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: colorCyanAccent,
                  size: 20,
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: widget.onToggle,
            child: Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                widget.isGrid
                    ? Icons.format_list_bulleted_rounded
                    : Icons.grid_view_rounded,
                color: colorCyanAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}