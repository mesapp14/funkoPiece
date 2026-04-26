import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class WantedPoster extends StatefulWidget {
  final Uint8List? imageBytes;
  final String bounty;
  final VoidCallback onPickImage;
  final TransformationController controller;
  final Function(Matrix4) onTransformChanged;

  final ValueChanged<bool>? onInteractionChange;

  const WantedPoster({
    super.key,
    required this.imageBytes,
    required this.bounty,
    required this.onPickImage,
    required this.controller,
    required this.onTransformChanged,
    this.onInteractionChange,
  });

  @override
  State<WantedPoster> createState() => _WantedPosterState();
}

class _WantedPosterState extends State<WantedPoster> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SelectionContainer.disabled(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: AspectRatio(
            aspectRatio: 0.70,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                final h = constraints.maxHeight;

                return Stack(
                  children: [
                    Positioned(
                      top: h * 0.18,
                      bottom: h * 0.33,
                      left: w * 0.07,
                      right: w * 0.07,
                      child: ClipRRect(
                        child: Container(
                          color: const Color(0xFFDCC8A9),
                          child: widget.imageBytes != null
                              ? GestureDetector(
                                  // Se clicchi l'immagine esistente, resetta e cambia
                                  onTap: () {
                                    widget.controller.value = Matrix4.identity();
                                    widget.onTransformChanged(Matrix4.identity());
                                    widget.onPickImage();
                                  },
                                  child: Listener(
                                    onPointerSignal: (pointerSignal) {
                                      if (pointerSignal is PointerScrollEvent) {
                                        // Blocca lo scroll della pagina su Chrome
                                      }
                                    },
                                    child: InteractiveViewer(
                                      transformationController: widget.controller,
                                      boundaryMargin: const EdgeInsets.all(300),
                                      minScale: 0.1,
                                      maxScale: 5.0,
                                      panEnabled: true,
                                      scaleEnabled: true,
                                      clipBehavior: Clip.hardEdge,
                                      onInteractionStart: (_) {
                                        widget.onInteractionChange?.call(true);
                                      },
                                      onInteractionEnd: (_) {
                                        widget.onInteractionChange?.call(false);
                                        widget.onTransformChanged(
                                          widget.controller.value,
                                        );
                                      },
                                      child: Image.memory(
                                        widget.imageBytes!,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                )
                              : GestureDetector(
                                  onTap: widget.onPickImage,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_a_photo,
                                        color: Colors.brown.withOpacity(0.5),
                                        size: w * 0.15,
                                      ),
                                      const Text(
                                        "TAP TO ADD",
                                        style: TextStyle(
                                          color: Colors.brown,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ),
                    ),

                    // Frame del Poster (Sempre sopra ma ignora i tocchi)
                    Positioned.fill(
                      child: IgnorePointer(
                        ignoring: true,
                        child: Image.asset(
                          'assets/generic/wanted.png',
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),

                    // Testo Bounty
                    Align(
                      alignment: const Alignment(0, 0.65),
                      child: IgnorePointer(
                        child: Text(
                          "฿ ${widget.bounty} -",
                          style: TextStyle(
                            fontSize: w * 0.10,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF3E2723).withOpacity(0.9),
                            fontFamily: 'serif',
                            shadows: const [
                              Shadow(
                                color: Colors.black26,
                                blurRadius: 6,
                                offset: Offset(1, 2),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}