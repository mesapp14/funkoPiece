// Location: lib/widgets/bottom_nav.dart
import 'package:flutter/material.dart';

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
    // The main container is now full-width, has zero margin, and uses
    // the full-width frame asset as its background.
    return Container(
      margin: EdgeInsets.zero, // Modified: Changed from a floating margin to zero.
      height: 90, // Modified: Increased height slightly to match the detailed frame.
      decoration: const BoxDecoration(
        image: DecorationImage(
          // MODIFIED: Use the new full-width wood/metal frame asset.
          image: AssetImage('ui/bottom_nav_frame_full.png'),
          fit: BoxFit.fill, // MODIFIED: Ensure the frame fills the entire width.
        ),
      ),
      // Padding ensures the contents don't hit the robust metal corners.
      padding: const EdgeInsets.symmetric(horizontal: 20), 
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Pass the specific image path and sizes for each standalone icon.
          _item('ui/icon_helm.png', "Home", 0, 40, 40),
          _item('ui/icon_scrolls.png', "Lista", 1, 40, 40),
          _item('ui/icon_chest.png', "Forziere", 2, 40, 40),
        ],
      ),
    );
  }

  // MODIFIED: The helper function now uses Image.asset and accepts specific image paths and sizes.
  Widget _item(String imgPath, String label, int i, double width, double height) {
    bool isSelected = selectedIndex == i;

    return GestureDetector(
      onTap: () => onTap(i),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // MODIFIED: Use Image.asset instead of Icon
          Image.asset(
            imgPath,
            width: width,
            height: height,
            // Apply a color filter to handle selected/unselected states
            color: isSelected ? null : Colors.white.withOpacity(0.4),
            colorBlendMode: isSelected ? BlendMode.dst : BlendMode.modulate,
          ),
          const SizedBox(height: 2), // Spacing between image and text
          // MODIFIED: Text is now added programmatically (using a font that matches the theme).
          Text(
            label,
            style: TextStyle(
              // Using a slightly more themed font color/style (e.g., light gold or off-white)
              color: isSelected ? const Color(0xFFFFFDE7) : Colors.white30,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}