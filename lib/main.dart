import 'package:flutter/material.dart';
import 'screens/home_screen.dart'; // Assicurati che questo import sia corretto

void main() {
  runApp(const FunkoApp());
}

class FunkoApp extends StatelessWidget {
  const FunkoApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Definizione della palette basata sull'immagine fornita
    const Color colorDarkNavy = Color(0xFF0A2647);
    const Color colorSteelBlue = Color(0xFF205295);
    const Color colorMidBlue = Color(0xFF144272);
    const Color colorLightGrey = Color(0xFFE1E5EA);
    const Color colorOffWhite = Color(0xFFF8F9FA);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Funko Catalog',
      // Definizione del Tema Globale
      theme: ThemeData(
        useMaterial3: true,
        // Usiamo colorScheme per definire i colori principali
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: colorSteelBlue, // Colore per i pulsanti principali
          onPrimary: Colors.white,
          secondary: colorMidBlue, // Colore per i tag o accenti
          onSecondary: Colors.white,
          error: Colors.red,
          onError: Colors.white,
          surface: colorLightGrey, // Colore delle card o AppBar
          onSurface: colorDarkNavy,
        ),
        // Stile per i pulsanti Elevati
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: colorDarkNavy, // Colore di sfondo scuro
            foregroundColor: Colors.white,   // Colore del testo
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}