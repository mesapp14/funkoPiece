import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart'; // NECESSARIO PER IL LOCAL STORAGE
import '../models/funko.dart'; 

// Palette Colori
const Color colorTealDark = Color(0xFF0A3038);
const Color colorTealAccent = Color(0xFF70D4D6); 
const Color colorOffWhite = Color(0xFFF3F5F7);
const Color colorRed = Color(0xFFE57373);
const Color colorGreen = Color(0xFF81C784);

class FunkoCard extends StatefulWidget {
  final FunkoVariant variant;
  final int number;
  final String saga;
  final String date;

  const FunkoCard({
    super.key,
    required this.variant,
    required this.number,
    this.saga = "Unknown",
    this.date = "N/A",
  });

  @override
  State<FunkoCard> createState() => _FunkoCardState();
}

class _FunkoCardState extends State<FunkoCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isOwned = false; // Stato del pallino

  @override
  void initState() {
    super.initState();
    _loadOwnedStatus(); // Carica lo stato dal local storage all'avvio
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  // --- LOGICA LOCAL STORAGE (ARMADIO) ---
  
  // Carica se il Funko è nell'armadio
  Future<void> _loadOwnedStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Uso una chiave univoca basata sul numero e nome variante
      _isOwned = prefs.getBool('owned_${widget.number}_${widget.variant.name}') ?? false;
    });
  }

  // Cambia lo stato e salva nel storage
  Future<void> _toggleOwnedStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isOwned = !_isOwned;
    });
    await prefs.setBool('owned_${widget.number}_${widget.variant.name}', _isOwned);
    
    // Feedback aptico per l'utente
    HapticFeedback.mediumImpact();
    
    // SnackBar opzionale per conferma
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isOwned ? "Aggiunto all'armadio! 📦" : "Rimosso dall'armadio"),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // --- POPUP DETTAGLIO (Qui rimane il TYPE) ---
  void _showDetailsPopup(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Chiudi',
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        final screenWidth = MediaQuery.of(context).size.width;

        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: screenWidth * 0.88,
              decoration: BoxDecoration(
                color: colorTealDark,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      color: colorOffWhite,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                    ),
                    child: Hero(
                      tag: 'funko_hero_${widget.number}_${widget.variant.name}',
                      child: ColorFiltered(
                        colorFilter: const ColorFilter.mode(
                          colorOffWhite, 
                          BlendMode.multiply,
                        ),
                        child: Image.network(
                          widget.variant.image,
                          height: 220,
                          fit: BoxFit.contain, 
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "#${widget.number} ${widget.variant.name}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 22,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow(Icons.auto_stories, "Saga", widget.saga),
                        _buildDetailRow(Icons.event, "Release", widget.date),
                        // IL TYPE RESTA SOLO QUI
                        _buildDetailRow(Icons.layers, "Type", widget.variant.type.toUpperCase()),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Colors.white.withOpacity(0.1),
                              foregroundColor: colorTealAccent,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(color: colorTealAccent.withOpacity(0.5)),
                              ),
                            ),
                            child: const Text(
                              "CLOSE",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
              child: child,
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colorTealAccent),
          const SizedBox(width: 12),
          Text("$label: ", style: TextStyle(color: Colors.white.withOpacity(0.6), fontWeight: FontWeight.w600, fontSize: 15)),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: () => _showDetailsPopup(context),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF9F9F9), Color(0xFF86A8AB), Color(0xFF0A3038)],
              stops: [0.35, 0.65, 1.0],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 1.1,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 45, left: 20, right: 40, bottom: 10),
                      child: Hero(
                        tag: 'funko_hero_${widget.number}_${widget.variant.name}',
                        child: ColorFiltered(
                          colorFilter: const ColorFilter.mode(Color(0xFFF9F9F9), BlendMode.multiply),
                          child: Image.network(widget.variant.image, fit: BoxFit.contain),
                        ),
                      ),
                    ),
                  ),
                  
                  // --- PALLINO POSSEDUTO (SINISTRA) ---
                  // --- PALLINO POSSEDUTO (SINISTRA) ---
                  Positioned(
                    top: 20,
                    right: 20,
                    child: GestureDetector(
                      onTap: _toggleOwnedStatus,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: _isOwned ? colorGreen : colorRed,
                          shape: BoxShape.circle, // <-- CORRETTO QUI
                          border: Border.all(color: Colors.white, width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: (_isOwned ? colorGreen : colorRed).withOpacity(0.4),
                              blurRadius: 8,
                              spreadRadius: 2,
                            )
                          ],
                        ),
                        child: Icon(
                          _isOwned ? Icons.check : Icons.close,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  // --- NUMBER BADGE (DESTRA) ---
                  Positioned(
                    top: 20,
                    left: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF387B86), Color(0xFF13424A)],
                        ),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
                      ),
                      child: Text(
                        '#${widget.number}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
              
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.variant.name,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 24, height: 1.1),
                    ),
                    const SizedBox(height: 24), // Spazio pulito (TYPE rimosso da qui)
                    
                    // Bottone VIEW DETAILS
                    InkWell(
                      onTap: () => _showDetailsPopup(context),
                      borderRadius: BorderRadius.circular(100),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(color: colorTealAccent.withOpacity(0.6), width: 1.5),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("VIEW DETAILS", style: TextStyle(color: colorTealAccent.withOpacity(0.9), fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1.2)),
                                const SizedBox(width: 6),
                                Icon(Icons.arrow_forward_ios, color: colorTealAccent.withOpacity(0.9), size: 14)
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}