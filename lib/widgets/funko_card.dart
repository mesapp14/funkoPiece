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
  final String funkoName;
  final String saga;
  final String date;
  final bool isGrid;

  const FunkoCard({
    super.key,
    required this.variant,
    required this.number,
    required this.funkoName,
    this.saga = "Unknown",
    this.date = "N/A",
    this.isGrid = false,
  });

  @override
  State<FunkoCard> createState() => _FunkoCardState();
}

class _FunkoCardState extends State<FunkoCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  bool _isOwned = false;

  // Percorso immagine aggiornato per varianti
  String get _funkoImagePath {
    if (widget.variant.type == 'standard') {
      return 'images/${widget.number}.png';
    } else {
      return 'images/${widget.number}_${widget.variant.type}.png';
    }
  }

  String get _typeImagePath => 'funkoType/${widget.variant.type}.png';

  @override
  void initState() {
    super.initState();
    _initAnimation();
    _loadOwnedStatus();
  }

  void _initAnimation() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    _scaleAnimation = Tween(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  Future<void> _loadOwnedStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getBool(_prefsKey) ?? false;
    if (mounted) setState(() => _isOwned = value);
  }

  Future<void> _toggleOwnedStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final newValue = !_isOwned;
    setState(() => _isOwned = newValue);
    await prefs.setBool(_prefsKey, newValue);
    HapticFeedback.mediumImpact();
  }

  String get _prefsKey =>
      'owned_${widget.number}_${widget.variant.type}${widget.variant.isChase ? '_chase' : ''}';

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
      pageBuilder: (dialogContext, _, _) {
        // DEFINIZIONE MANCANTE: Recuperiamo la larghezza dello schermo
        final double screenWidth = MediaQuery.of(context).size.width;

        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: screenWidth * 0.88, // Ora screenWidth è definito
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1A374D), Color(0xFF06101D)],
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Colors.white.withOpacity(0.15),
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildPopupImage(),
                  _buildPopupInfo(context),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (_, animation, _, child) {
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
  Widget _buildPopupImage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: colorOffWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Hero(
        tag: _heroTag,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 250),
          child: Image.asset(
            _funkoImagePath,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) =>
                const Icon(Icons.image_not_supported, color: colorTealDark, size: 40),
          ),
        ),
      ),
    );
  }

  Widget _buildPopupInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      child: Column(
        children: [
          // Titolo e Icona Tipo
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                _typeImagePath,
                width: 28,
                height: 28,
                errorBuilder: (_, _, _) => const Icon(Icons.stars, size: 28, color: Colors.amber),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  widget.funkoName.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 24),

          // Griglia Dettagli
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildDetailTile("NUMBER", "#${widget.number}", Icons.tag),
              _buildDetailTile("TYPE", widget.variant.type.toUpperCase(), Icons.category_outlined),
              _buildDetailTile("SAGA", widget.saga, Icons.auto_stories),
              _buildDetailTile("RELEASE", widget.date, Icons.calendar_today),
              if (widget.variant.isChase)
                _buildDetailTile("EDITION", "CHASE", Icons.local_fire_department, isSpecial: true),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Bottone di chiusura stilizzato
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "CHIUDI",
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailTile(String label, String value, IconData icon, {bool isSpecial = false}) {
    return Container(
      width: 130,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSpecial ? Colors.orange.withOpacity(0.1) : Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSpecial ? Colors.orange.withOpacity(0.3) : Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: isSpecial ? Colors.orange : Colors.white38),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSpecial ? Colors.orange : Colors.white38,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
 
  Widget _buildInfoButton(BuildContext context) {
  return InkWell(
    onTap: () => _showDetailsPopup(context),
    borderRadius: BorderRadius.circular(20),
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A374D).withOpacity(0.4), // Blu scuro trasparente
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: const Text(
        "INFO",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          fontSize: 12,
        ),
      ),
    ),
  );
}
  String get _heroTag =>
      'funko_hero_${widget.number}_${widget.variant.type}${widget.variant.isChase ? '_chase' : ''}';

  @override
  Widget build(BuildContext context) {
    final margin = widget.isGrid
        ? const EdgeInsets.all(6)
        : const EdgeInsets.symmetric(horizontal: 20, vertical: 12);

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: _controller.reverse,
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
            border: Border.all(color: Colors.white.withOpacity(0.12), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  // Box dell'immagine con AspectRatio fisso e padding di sicurezza
                  AspectRatio(
                    aspectRatio: 1.0,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(25, 35, 25, 25), // TOP aumentato a 35
                      child: Hero(
                        tag: _heroTag,
                        child: Image.asset(
                          _funkoImagePath,
                          fit: BoxFit.contain,
                          alignment: Alignment.center,
                          errorBuilder: (_, _, _) =>
                              const Icon(Icons.image_not_supported, color: Colors.white24, size: 40),
                        ),
                      ),
                    ),
                  ),
                  _buildOwnedBadge(),
                  _buildNumberBadge(),
                ],
              ),
              // Sezione Testo e Bottone
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12), // BOTTOM ridotto da 16 a 12
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          _typeImagePath,
                          width: 18,
                          height: 18,
                          errorBuilder: (_, _, _) => const Icon(Icons.error, size: 16, color: Colors.white24),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            widget.funkoName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: widget.isGrid ? 14 : 18,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),
                    _buildInfoButton(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOwnedBadge() {
    return Positioned(
      top: 12,
      right: 12,
      child: GestureDetector(
        onTap: _toggleOwnedStatus,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: _isOwned ? colorGreen : colorRed,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
          ),
          child: Icon(_isOwned ? Icons.check : Icons.close, size: 16, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildNumberBadge() {
    return Positioned(
      top: 12,
      left: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '#${widget.number}',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
        ),
      ),
    );
  }
}