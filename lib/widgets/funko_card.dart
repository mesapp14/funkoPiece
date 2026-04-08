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
  final bool isGrid;

  const FunkoCard({
    super.key,
    required this.variant,
    required this.number,
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

  String get _imagePath => 'assets/images/${widget.number}.png';

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

    if (mounted) {
      setState(() => _isOwned = value);
    }
  }

  Future<void> _toggleOwnedStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final newValue = !_isOwned;

    setState(() => _isOwned = newValue);
    await prefs.setBool(_prefsKey, newValue);

    HapticFeedback.mediumImpact();
  }

  String get _prefsKey =>
      'owned_${widget.number}_${widget.variant.name}';

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
      barrierColor: Colors.black.withValues(alpha: 0.6),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, _, _) {
        final screenWidth = MediaQuery.of(context).size.width;

        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: screenWidth * 0.88,
              decoration: BoxDecoration(
                color: colorTealDark,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
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
              scale: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutBack,
              ),
              child: child,
            ),
          ),
        );
      },
    );
  }

  Widget _buildPopupImage() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: colorOffWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Hero(
        tag: _heroTag,
        child: ColorFiltered(
          colorFilter:
              const ColorFilter.mode(colorOffWhite, BlendMode.multiply),
          child: Image.asset(
            _imagePath,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => const Icon(
              Icons.image_not_supported,
              color: Colors.white24,
              size: 40,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPopupInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        children: [
          Text(
            widget.variant.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: widget.isGrid ? 15 : 22,
            ),
          ),
          SizedBox(height: widget.isGrid ? 18 : 12),
          _buildInfoButton(context),
        ],
      ),
    );
  }

  Widget _buildInfoButton(BuildContext context) {
    return InkWell(
      onTap: () => _showDetailsPopup(context),
      borderRadius: BorderRadius.circular(100),
      child: Container(
        width: 150,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: colorTealAccent.withValues(alpha: 0.3),
          ),
        ),
        child: Center(
          child: Text(
            "INFO",
            style: TextStyle(
              color: colorTealAccent.withValues(alpha: 0.9),
              fontWeight: FontWeight.bold,
              fontSize: 14,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  String get _heroTag =>
      'funko_hero_${widget.number}_${widget.variant.name}';

  @override
  Widget build(BuildContext context) {
    final margin = widget.isGrid
        ? const EdgeInsets.all(2)
        : const EdgeInsets.symmetric(horizontal: 24, vertical: 14);

    final imagePadding = widget.isGrid
        ? const EdgeInsets.all(8)
        : const EdgeInsets.fromLTRB(15, 45, 15, 5);

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
              colors: [Color(0xFF144272), Color(0xFF0A2647)],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: Column(
            children: [
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: widget.isGrid ? 1.0 : 1.1,
                    child: Padding(
                      padding: imagePadding,
                      child: Hero(
                        tag: _heroTag,
                        child: ColorFiltered(
                          colorFilter: const ColorFilter.mode(
                            Color(0xFFF9F9F9),
                            BlendMode.multiply,
                          ),
                          child: Image.asset(
                            _imagePath,
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) => const Icon(
                              Icons.image_not_supported,
                              color: Colors.white24,
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  _buildOwnedBadge(),
                  _buildNumberBadge(),
                ],
              ),
              _buildBottomInfo(context),
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
          duration: const Duration(milliseconds: 300),
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: _isOwned ? colorGreen : colorRed,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Icon(
            _isOwned ? Icons.check : Icons.close,
            size: 12,
            color: Colors.white,
          ),
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
          color: Colors.black26,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white12),
        ),
        child: Text(
          '#${widget.number}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 10,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        children: [
          Text(
            widget.variant.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: widget.isGrid ? 15 : 22,
            ),
          ),
          SizedBox(height: widget.isGrid ? 18 : 12),
          _buildInfoButton(context),
        ],
      ),
    );
  }
}