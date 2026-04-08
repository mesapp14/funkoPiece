import 'package:flutter/material.dart';

const Color colorDarkNavy = Color(0xFF0A2647);
const Color colorMidBlue = Color(0xFF144272);
const Color colorCyanAccent = Color(0xFFFFFFFF);

class PercentContainer extends StatelessWidget {
  final double progress;
  final int owned;
  final int total;

  const PercentContainer({
    super.key,
    required this.progress,
    required this.owned,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorMidBlue.withValues(alpha: 0.6),
            colorDarkNavy.withValues(alpha: 0.8)
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Completamento",
                  style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w500)),
              Text("${(progress * 100).toStringAsFixed(1)}%",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colorCyanAccent,
                      fontSize: 18)),
            ],
          ),
          const SizedBox(height: 15),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.white.withValues(alpha: 0.05),
              valueColor: const AlwaysStoppedAnimation<Color>(colorCyanAccent),
            ),
          ),
          const SizedBox(height: 12),
          Text("$owned / $total pezzi nel forziere",
              style: const TextStyle(
                  fontSize: 12, color: Colors.white38, letterSpacing: 0.5)),
        ],
      ),
    );
  }
}