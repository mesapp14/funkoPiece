import 'package:flutter/material.dart';

const Color colorDarkNavy = Color(0xFF0A2647);
const Color colorCyanAccent = Color(0xFFFFFFFF);

class BottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const BottomNav({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 30),
      height: 75,
      decoration: BoxDecoration(
        color: colorDarkNavy.withOpacity(0.9),
        borderRadius: BorderRadius.circular(35),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _item(Icons.home_filled, "Home", 0),
          _item(Icons.grid_view_rounded, "Lista", 1),
          _item(Icons.inventory_2_rounded, "Forziere", 2),
        ],
      ),
    );
  }

  Widget _item(IconData icon, String label, int i) {
    bool isSelected = selectedIndex == i;

    return GestureDetector(
      onTap: () => onTap(i),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isSelected ? colorCyanAccent : Colors.white30),
          Text(label,
              style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white30)),
        ],
      ),
    );
  }
}