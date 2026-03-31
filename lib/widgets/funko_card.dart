import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/funko.dart'; 

const Color colorTealDark = Color(0xFF0A3038);
const Color colorTealAccent = Color(0xFFFFFFFF); 
const Color colorOffWhite = Color(0xFFF3F5F7);
const Color colorRed = Color(0xFFE57373);
const Color colorGreen = Color(0xFF81C784);

class FunkoCard extends StatefulWidget {
  final FunkoVariant variant;
  final int number;
  final String saga;
  final String date;
  final bool isGrid; // Nuovo parametro per gestire il layout

  const FunkoCard({
    super.key,
    required this.variant,
    required this.number,
    this.saga = "Unknown",
    this.date = "N/A",
    this.isGrid = false, // Default lista
  });

  @override
  State<FunkoCard> createState() => _FunkoCardState();
}

class _FunkoCardState extends State<FunkoCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isOwned = false;

  @override
  void initState() {
    super.initState();
    _loadOwnedStatus();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  Future<void> _loadOwnedStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isOwned = prefs.getBool('owned_${widget.number}_${widget.variant.name}') ?? false;
    });
  }

  Future<void> _toggleOwnedStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isOwned = !_isOwned;
    });
    await prefs.setBool('owned_${widget.number}_${widget.variant.name}', _isOwned);
    HapticFeedback.mediumImpact();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
                        colorFilter: const ColorFilter.mode(colorOffWhite, BlendMode.multiply),
                        child: Image.network(widget.variant.image, height: 220, fit: BoxFit.contain),
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
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow(Icons.auto_stories, "Saga", widget.saga),
                        _buildDetailRow(Icons.event, "Release", widget.date),
                        _buildDetailRow(Icons.layers, "Type", widget.variant.type.toUpperCase()),
                        const SizedBox(height: 24),
                        SizedBox(
                           width: 150,
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
                            child: const Text("CLOSE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
    // Margini adattivi: più piccoli se in griglia
    final margin = widget.isGrid 
        ? const EdgeInsets.all(4) 
        : const EdgeInsets.symmetric(horizontal: 24, vertical: 14);

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: () => _showDetailsPopup(context),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: margin,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF144272), Color(0xFF0A2647)],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: widget.isGrid ? 1.0 : 1.1,
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: widget.isGrid ? 35 : 45, 
                        left: 15, right: 15, bottom: 5
                      ),
                      child: Hero(
                        tag: 'funko_hero_${widget.number}_${widget.variant.name}',
                        child: ColorFiltered(
                          colorFilter: const ColorFilter.mode(Color(0xFFF9F9F9), BlendMode.multiply),
                          child: Image.network(widget.variant.image, fit: BoxFit.contain),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: _toggleOwnedStatus,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: _isOwned ? colorGreen : colorRed,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Icon(_isOwned ? Icons.check : Icons.close, size: 12, color: Colors.white),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Text(
                        '#${widget.number}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.variant.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white, 
                        fontWeight: FontWeight.w900, 
                        fontSize: widget.isGrid ? 16 : 22, 
                        height: 1.1
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: InkWell(
                        onTap: () => _showDetailsPopup(context),
                        borderRadius: BorderRadius.circular(100),
                        
                        child: Container(
                          width: 150,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(color: colorTealAccent.withOpacity(0.3)),
                          ),
                          child: Center(
                            child: Text("INFO",
                              style: TextStyle(
                                color: colorTealAccent.withOpacity(0.9), 
                                fontWeight: FontWeight.bold, 
                                fontSize: 14, 
                                letterSpacing: 1.2,
                                
                              )
                            ),
                          ),
                        ),
                      ),
                    )
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