import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/funko.dart';
import 'funko_details_dialog.dart'; // Importa il nuovo file

const Color colorTealDark = Color(0xFF0A3038);
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

class _FunkoCardState extends State<FunkoCard> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  bool _isOwned = false;

  String get _funkoImagePath => widget.variant.type == 'standard'
      ? 'assets/images/${widget.number}.png'
      : 'assets/images/${widget.number}_${widget.variant.type}.png';

  String get _typeImagePath => 'assets/funkoType/${widget.variant.type}.png';

  String get _heroTag => 'funko_hero_${widget.number}_${widget.variant.type}${widget.variant.isChase ? '_chase' : ''}';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scaleAnimation = Tween(begin: 1.0, end: 0.96).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _loadOwnedStatus();
  }

  Future<void> _loadOwnedStatus() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) setState(() => _isOwned = prefs.getBool(_prefsKey) ?? false);
  }

  Future<void> _toggleOwnedStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final newValue = !_isOwned;
    setState(() => _isOwned = newValue);
    await prefs.setBool(_prefsKey, newValue);
    HapticFeedback.mediumImpact();
  }

  String get _prefsKey => 'owned_${widget.number}_${widget.variant.type}${widget.variant.isChase ? '_chase' : ''}';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openDetails() {
    showFunkoDetails(
      context,
      variant: widget.variant,
      number: widget.number,
      funkoName: widget.funkoName,
      saga: widget.saga,
      date: widget.date,
      heroTag: _heroTag,
    );
  }

  @override
  Widget build(BuildContext context) {
    final margin = widget.isGrid ? const EdgeInsets.all(6) : const EdgeInsets.symmetric(horizontal: 20, vertical: 12);

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: _controller.reverse,
      onTap: _openDetails,
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
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  AspectRatio(
                    aspectRatio: 1.0,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(25, 35, 25, 25),
                      child: Hero(
                        tag: _heroTag,
                        child: Image.asset(
                          _funkoImagePath,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => const Icon(Icons.image_not_supported, color: Colors.white24, size: 40),
                        ),
                      ),
                    ),
                  ),
                  _buildOwnedBadge(),
                  _buildNumberBadge(),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(_typeImagePath, width: 18, height: 18, errorBuilder: (_, _, _) => const Icon(Icons.error, size: 16, color: Colors.white24)),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            widget.funkoName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: widget.isGrid ? 14 : 18),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildInfoButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoButton() {
    return InkWell(
      onTap: _openDetails,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1A374D).withOpacity(0.4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: const Text("INFO", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
      ),
    );
  }

  Widget _buildOwnedBadge() {
    return Positioned(
      top: 12, right: 12,
      child: GestureDetector(
        onTap: _toggleOwnedStatus,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 28, height: 28,
          decoration: BoxDecoration(color: _isOwned ? colorGreen : colorRed, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
          child: Icon(_isOwned ? Icons.check : Icons.close, size: 16, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildNumberBadge() {
    return Positioned(
      top: 12, left: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), borderRadius: BorderRadius.circular(8)),
        child: Text('#${widget.number}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
      ),
    );
  }
}