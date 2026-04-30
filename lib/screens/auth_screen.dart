import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../flow/signup_flow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final auth = AuthService();
  final storage = StorageService();

  bool showEntry = true;
  bool showChoice = false;

  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  bool rememberMe = false;
  bool loading = false;

  // ======================================================
  // ENTRY SCREEN
  // ======================================================
 Widget entry() {
  return Scaffold(
    body: Stack(
      children: [
        /// 1. 🌊 SFONDO GRADIENTE
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF001B33), Color(0xFF0071BB)],
            ),
          ),
        ),

        /// 2. 🌀 LOTTIE WAVES
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: MediaQuery.of(context).size.height * 0.4,
          child: Lottie.asset(
            "ui/lottie/waves.json",
            fit: BoxFit.cover,
            repeat: true,
          ),
        ),

        /// 3. 🏴‍☠️ IMMAGINE PRINCIPALE (con trasparenza GIMP)
        Positioned.fill(
          child: Image.asset(
            "ui/logo_piratepop.png", 
            fit: BoxFit.cover,
          )
          .animate()
          .fade(duration: 800.ms)
          .slideY(begin: 0.05, duration: 800.ms, curve: Curves.easeOut),
        ),

        /// 5. ✨ UI OVERLAY
        SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                const Spacer(),

                /// ✨ TESTO "JOURNEY" (Più audace)
                Text(
                  "YOUR JOURNEY AWAITS",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    letterSpacing: 3,
                    fontSize: 14,
                    fontWeight: FontWeight.bold, // Più peso!
                    shadows: const [
                      Shadow(color: Colors.black87, blurRadius: 8, offset: Offset(0, 2)),
                    ],
                  ),
                ).animate(delay: 600.ms).fade().slideY(begin: 0.2),

                const SizedBox(height: 28),

                /// 💰 CTA BUTTON (Stile Clay/3D)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      showEntry = false;
                      showChoice = true;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFC107), // Giallo ambra solido
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.black.withOpacity(0.15), width: 2),
                      boxShadow: [
                        // Ombra profonda (Sotto)
                        BoxShadow(
                          color: const Color(0xFF8B6B00).withOpacity(0.6),
                          offset: const Offset(0, 8),
                          blurRadius: 0,
                        ),
                        // Bagliore esterno
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          offset: const Offset(0, 12),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: const Text(
                      "ENTER THE GRAND LINE",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3E2723), // Marrone scuro invece di nero puro
                        fontSize: 16,
                        letterSpacing: 1.2,
                      ),
                    ),
                  )
                  .animate(onPlay: (controller) => controller.repeat(reverse: true))
                  .moveY(begin: 0, end: -6, duration: 1500.ms, curve: Curves.easeInOutSine) // Galleggiamento
                  .animate(delay: 900.ms)
                  .fade()
                  .scale(begin: const Offset(0.9, 0.9)),
                ),

                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
 
  Widget choice() {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF001B33), Color(0xFF0071BB)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "CHOOSE YOUR PATH",
                style: TextStyle(color: Colors.white, fontSize: 22),
              ),

              const SizedBox(height: 40),

              _card(
                title: "LOG IN",
                subtitle: "Welcome back Captain",
                icon: Icons.lock,
                onTap: showLoginPopup,
              ),

              const SizedBox(height: 20),

              _card(
                title: "JOIN CREW",
                subtitle: "Start your legend",
                icon: Icons.flag,
                onTap: openSignup,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.amber),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ======================================================
  // LOGIN POPUP
  // ======================================================
  void showLoginPopup() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0B2239),
        title: const Text(
          "LOG IN",
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Email",
                hintStyle: TextStyle(color: Colors.white54),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: passCtrl,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Password",
                hintStyle: TextStyle(color: Colors.white54),
              ),
            ),
            Row(
              children: [
                Checkbox(
                  value: rememberMe,
                  onChanged: (v) =>
                      setState(() => rememberMe = v ?? false),
                ),
                const Text(
                  "Remember me",
                  style: TextStyle(color: Colors.white70),
                )
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: login,
            child: const Text("LOGIN"),
          )
        ],
      ),
    );
  }

  // ======================================================
  // LOGIN
  // ======================================================
  Future<void> login() async {
    setState(() => loading = true);

    final res = await auth.login(
      emailCtrl.text,
      passCtrl.text,
    );

    if (res.success) {
      await storage.saveToken(res.token ?? "", rememberMe);

      if (!mounted) return;

      Navigator.pop(context);
      Navigator.pushReplacementNamed(context, "/home");
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res.message ?? "Login failed")),
        );
      }
    }

    setState(() => loading = false);
  }

  // ======================================================
  // SIGNUP FLOW
  // ======================================================
  void openSignup() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SignupFlow(
          onComplete: (data) async {
            final res = await auth.signup(
              email: data["email"],
              password: data["password"],
              pirateName: data["pirate_name"],
              city: data["city"],
              lat: data["lat"],
              lon: data["lon"],
            );

            if (res.success) {
              if (!mounted) return;

              Navigator.pop(context);
              setState(() {
                showChoice = false;
                showEntry = true;
              });

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Crew joined! Now login")),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(res.message ?? "Signup failed")),
              );
            }
          },
        ),
      ),
    );
  }

  // ======================================================
  // BUILD
  // ======================================================
  @override
  Widget build(BuildContext context) {
    if (showEntry) return entry();
    if (showChoice) return choice();

    return const SizedBox();
  }
}