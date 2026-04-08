import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../models/funko.dart';

class HorizontalForziere extends StatelessWidget {
  final List<MapEntry<int, FunkoVariant>> ownedVariants;

  const HorizontalForziere({
    super.key,
    required this.ownedVariants,
  });

  @override
  Widget build(BuildContext context) {
    if (ownedVariants.isEmpty) {
      return const Text("Il forziere è vuoto...",
          style: TextStyle(color: Colors.white24));
    }

    return SizedBox(
      height: 190,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: ownedVariants.length,
        itemBuilder: (context, index) {
          final v = ownedVariants[index].value;
          final num = ownedVariants[index].key;

          return Container(
            width: 140,
            margin: const EdgeInsets.only(right: 15),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Image.asset(
                                  "assets/images/$num.png",
                                  fit: BoxFit.contain,
                                  filterQuality: FilterQuality.high,
                                  errorBuilder: (_, _, _) {
                                    return const Icon(
                                      Icons.image_not_supported,
                                      color: Colors.white24,
                                      size: 40,
                                    );
                                  },
                                ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 15),
                        child: Text(
                          "#$num ${v.name}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}