import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const FunkoApp());
}

class FunkoApp extends StatelessWidget {
  const FunkoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FunkoPiece',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A2647), // Deep Navy
        colorScheme: const ColorScheme.dark(
          primary: Color.from(alpha: 1, red: 1, green: 1, blue: 1), // Cyan Accent
          secondary: Color(0xFF205295), // Steel Blue
          surface: Color(0xFF144272), // Mid Blue
        ),
      ),
      home: const HomeScreen(),
    );
  }
}