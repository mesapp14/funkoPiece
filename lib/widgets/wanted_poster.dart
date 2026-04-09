import 'dart:typed_data';
import 'package:flutter/material.dart';

class WantedPoster extends StatefulWidget {
  final Uint8List? imageBytes;
  final String bounty;
  final VoidCallback onPickImage;
  final Matrix4? initialTransform;
  final Function(Matrix4) onTransformChanged;

  const WantedPoster({
    super.key,
    required this.imageBytes,
    required this.bounty,
    required this.onPickImage,
    required this.initialTransform,
    required this.onTransformChanged,
  });

  @override
  State<WantedPoster> createState() => _WantedPosterState();
}

class _WantedPosterState extends State<WantedPoster> {
  late TransformationController _controller;

  @override
  void initState() {
    super.initState();
    // Inizializza il controller con la posizione salvata o quella standard
    _controller = TransformationController(widget.initialTransform ?? Matrix4.identity());
  }

  @override
  void didUpdateWidget(WantedPoster oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Se l'immagine cambia (es. ne carichi una nuova), resettiamo la posizione
    if (oldWidget.imageBytes != widget.imageBytes && widget.imageBytes != null) {
      _controller.value = Matrix4.identity();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
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
                  // 1. AREA FOTO (Sotto la cornice)
                  Positioned(
                    top: h * 0.18,
                    bottom: h * 0.33,
                    left: w * 0.07,
                    right: w * 0.07,
                    child: ClipRRect(
                      child: Container(
                        color: const Color(0xFFDCC8A9),
                        child: widget.imageBytes != null
                            ? InteractiveViewer(
                                transformationController: _controller,
                                // Permette di muovere la foto anche fuori dai bordi per centrarla
                                boundaryMargin: const EdgeInsets.all(300), 
                                minScale: 0.1,
                                maxScale: 5.0,
                                onInteractionEnd: (details) {
                                  // Quando l'utente finisce di spostare/zoomare, salviamo
                                  widget.onTransformChanged(_controller.value);
                                },
                                child: Image.memory(
                                  widget.imageBytes!,
                                  fit: BoxFit.contain, // Usiamo contain così l'utente ha il controllo totale
                                ),
                              )
                            : GestureDetector(
                                onTap: widget.onPickImage,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_a_photo, color: Colors.brown.withOpacity(0.5), size: w * 0.15),
                                    const Text("TAP TO ADD", style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                      ),
                    ),
                  ),

                  // 2. CORNICE (Trasparente al centro)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Image.asset('assets/generic/wanted.png', fit: BoxFit.fill),
                    ),
                  ),

                  // 3. TAGLIA
                  Positioned(
                    bottom: h * 0.12,
                    left: 0,
                    right: 0,
                    child: IgnorePointer(
                      child: Center(
                        child: Text(
                          "฿ ${widget.bounty} -",
                          style: TextStyle(
                            fontSize: w * 0.10,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF3E2723).withOpacity(0.9),
                            fontFamily: 'serif',
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Bottone piccolo per cambiare immagine se già presente
                  if (widget.imageBytes != null)
                    Positioned(
                      top: h * 0.15,
                      right: w * 0.05,
                      child: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.brown),
                        onPressed: widget.onPickImage,
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}