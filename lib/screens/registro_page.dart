import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:typed_data';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/funko.dart';
import '../widgets/horizontal_forziere.dart';
import '../widgets/wanted_poster.dart';

class RegistroPage extends StatefulWidget {
  final List<MapEntry<int, FunkoVariant>> ownedVariants;
  final List<Funko> allFunkos;

  const RegistroPage({
    super.key,
    required this.ownedVariants,
    required this.allFunkos,
  });

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  bool _isStatsExpanded = true;
  Uint8List? _imageBytes;

  final TransformationController _controller =
      TransformationController();

  @override
  void initState() {
    super.initState();
    _loadSavedData();
    _loadImage();
  }

  String getLevelName(double percentage) {
    if (percentage >= 1.0) return "King of Pirates";
    if (percentage >= 0.90) return "Will of D.";
    if (percentage >= 0.80) return "Yonko";
    if (percentage >= 0.70) return "Yonko Commander";
    if (percentage >= 0.60) return "Shichibukai";
    if (percentage >= 0.50) return "New World Captain";
    if (percentage >= 0.40) return "Worst Gen. Supernova";
    if (percentage >= 0.25) return "Rookie";
    return "East Blue Pirate";
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? matrixList = prefs.getStringList('poster_transform');

    if (matrixList != null) {
      final values = matrixList.map((e) => double.parse(e)).toList();
      _controller.value = Matrix4.fromList(values);
    }
  }

  Future<void> _saveTransform(Matrix4 matrix) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'poster_transform',
      matrix.storage.map((e) => e.toString()).toList(),
    );
  }

  Future<void> _saveImage(Uint8List bytes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('poster_image', base64Encode(bytes));
  }

  Future<void> _loadImage() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('poster_image');

    if (data != null) {
      setState(() {
        _imageBytes = base64Decode(data);
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
    );

    if (image != null) {
      final bytes = await image.readAsBytes();

      setState(() {
        _imageBytes = bytes;
        _controller.value = Matrix4.identity();
      });

      await _saveImage(bytes);
    }
  }

  String calculateBounty() {
    int totalBounty = widget.ownedVariants.fold(0, (sum, entry) {
      if (entry.value.isChase) return sum + 25000000;
      return sum +
          (entry.value.type != 'standard'
              ? 10000000
              : 2000000);
    });

    return totalBounty.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    int totalPossible =
        widget.allFunkos.fold(0, (sum, f) => sum + f.variants.length);

    double progress =
        totalPossible > 0 ? widget.ownedVariants.length / totalPossible : 0;

    Map<String, int> totalByType = {};
    Map<String, int> ownedByType = {};

    for (var f in widget.allFunkos) {
      for (var v in f.variants) {
        totalByType[v.type] = (totalByType[v.type] ?? 0) + 1;
      }
    }

    for (var entry in widget.ownedVariants) {
      ownedByType[entry.value.type] =
          (ownedByType[entry.value.type] ?? 0) + 1;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A2647),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(progress),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  WantedPoster(
                    imageBytes: _imageBytes,
                    bounty: calculateBounty(),
                    onPickImage: _pickImage,
                    controller: _controller,
                    onTransformChanged: _saveTransform,
                  ),

                  const SizedBox(height: 30),

                  _buildStatCard(
                    totalByType,
                    ownedByType,
                    progress,
                    widget.ownedVariants.length,
                    totalPossible,
                  ),

                  const SizedBox(height: 35),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "TREASURE BOX",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  HorizontalForziere(
                    ownedVariants: widget.ownedVariants,
                  ),

                  const SizedBox(height: 60),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAppBar(double progress) {
    return SliverAppBar(
      expandedHeight: 100,
      backgroundColor: Colors.transparent,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1B4965), Color(0xFF0A2647)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                getLevelName(progress).toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              Text(
                "COLLECTION RANK: ${(progress * 100).toStringAsFixed(1)}%",
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    Map<String, int> totalByType,
    Map<String, int> ownedByType,
    double progress,
    int owned,
    int total,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            children: [
              ListTile(
                onTap: () => setState(
                  () => _isStatsExpanded = !_isStatsExpanded,
                ),
                title: const Text(
                  "Log of the Journey",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  "$owned / $total Funko collected",
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
                  ),
                ),
                trailing: Icon(
                  _isStatsExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.white54,
                ),
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox(),
                secondChild: Padding(
                  padding: const EdgeInsets.fromLTRB(25, 0, 25, 25),
                  child: Column(
                    children: totalByType.keys.map((type) {
                      double p = (totalByType[type] ?? 0) > 0
                          ? (ownedByType[type] ?? 0) /
                              totalByType[type]!
                          : 0;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  type.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                Text(
                                  "${ownedByType[type] ?? 0}/${totalByType[type]}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: p,
                              backgroundColor: Colors.white10,
                              color: Colors.blueAccent,
                              minHeight: 8,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                crossFadeState: _isStatsExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 300),
              )
            ],
          ),
        ),
      ),
    );
  }
}