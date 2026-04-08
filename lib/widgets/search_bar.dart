import 'package:flutter/material.dart';

const Color colorCyanAccent = Color(0xFFFFFFFF);

class SearchBarWidget extends StatelessWidget {
  final Function(String) onSearch;
  final VoidCallback onToggle;
  final bool isGrid;

  const SearchBarWidget({
    super.key,
    required this.onSearch,
    required this.onToggle,
    required this.isGrid,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (v) => onSearch(v),
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: "Cerca tesori...",
                hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: colorCyanAccent, size: 20),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onToggle,
            child: Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                isGrid ? Icons.format_list_bulleted_rounded : Icons.grid_view_rounded,
                color: colorCyanAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}