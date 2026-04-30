import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'screens/auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final prefs = await SharedPreferences.getInstance();
  
  // Recupero token e preferenza "Ricordami"
  final bool hasToken = prefs.getString('jwt_token') != null;
  final bool rememberMe = prefs.getBool('remember_me') ?? false;

  Widget initialScreen;

  // Logica di persistenza: se ricordato, vai in Home
  if (hasToken && rememberMe) {
    initialScreen = const HomeScreen();
  } else {
    // Altrimenti puliamo e chiediamo il login
    await prefs.remove('jwt_token');
    initialScreen = const AuthScreen();
  }

  runApp(FunkoApp(startScreen: initialScreen));
}

class FunkoApp extends StatelessWidget {
  final Widget startScreen;
  const FunkoApp({super.key, required this.startScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pirate Pop',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        // AGGIORNAMENTO: Usiamo il blu Funko come sfondo base
        scaffoldBackgroundColor: const Color(0xFF0071BB), 
        colorScheme: const ColorScheme.dark(
          primary: Colors.amber, // Colore pirata per eccellenza
          secondary: Color(0xFF5D4037), // Il marrone del legno della nave
          surface: Color(0xFF0071BB),
        ),
        // Stile globale per i testi per renderli più leggibili sul blu
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
        ),
      ),
      home: startScreen,
      routes: {
        '/home': (context) => const HomeScreen(),
        '/auth': (context) => const AuthScreen(),
      },
    );
  }
}