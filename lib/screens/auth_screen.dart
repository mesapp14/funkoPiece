import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  bool isLoading = false;
  bool _rememberMe = false;

  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();

  Timer? _debounce;
  List<dynamic> _citySuggestions = [];
  bool _isSearchingCity = false;
  double? _selectedLat;
  double? _selectedLon;
  String? _selectedCityName;

  final String baseUrl = "https://alienbash.com/backend/auth";

  // --- LOGICA ---
  void _onCityChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    if (query.length < 3) {
      setState(() { _citySuggestions = []; _selectedLat = null; _selectedLon = null; });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 800), () async {
      setState(() => _isSearchingCity = true);
      final url = Uri.parse('https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&limit=5');
      try {
        final response = await http.get(url, headers: {'User-Agent': 'FunkoPieceApp/1.0'});
        if (response.statusCode == 200) {
          setState(() { _citySuggestions = json.decode(response.body); _isSearchingCity = false; });
        }
      } catch (e) { setState(() => _isSearchingCity = false); }
    });
  }

  void _selectCity(dynamic cityData) {
    setState(() {
      _selectedCityName = cityData['name'] ?? cityData['display_name'];
      _cityCtrl.text = _selectedCityName!;
      _selectedLat = double.tryParse(cityData['lat']);
      _selectedLon = double.tryParse(cityData['lon']);
      _citySuggestions = [];
    });
    FocusScope.of(context).unfocus();
  }

  Future<void> _submit() async {
    setState(() => isLoading = true);
    final url = isLogin ? "$baseUrl/login.php" : "$baseUrl/signup.php";
    try {
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode({
          'email': _emailCtrl.text,
          'password': _passCtrl.text,
          if (!isLogin) 'pirate_name': _nameCtrl.text,
          if (!isLogin) 'city_name': _selectedCityName,
          if (!isLogin) 'latitude': _selectedLat,
          if (!isLogin) 'longitude': _selectedLon,
        }),
        headers: {"Content-Type": "application/json"},
      );
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        if (isLogin) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('jwt_token', data['token']);
          await prefs.setBool('remember_me', _rememberMe);
          if (!mounted) return;
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          setState(() => isLogin = true);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Enlisted! Now login.")));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'])));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Connection error")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showForgotPasswordDialog() {
    final resetEmailCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF5D4037),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: const BorderSide(color: Colors.amber, width: 2)),
        title: const Text("Lost Your Log Pose?", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: _buildSimpleTextField(resetEmailCtrl, "Your Pirate Email", Icons.email),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close", style: TextStyle(color: Colors.white70))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            onPressed: () => Navigator.pop(context),
            child: const Text("Send Recover Request", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const double formWidth = 360.0;
    const double formHeight = 300.0; // Altezza leggermente aumentata per gestire la colonna centrale
    
    return Scaffold(
      body: Stack(
        children: [
          // 1. BACKGROUND (Sfondo Blu standard di One Piece / Funko)
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF0071BB), 
              image: DecorationImage(
                image: AssetImage('ui/authScreen/bg_pattern_funko.png'),
                fit: BoxFit.cover,
                opacity: 0.7,
              ),
            ),
          ),
          
          
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                              'ui/authScreen/logo_funkopiece.png', 
                              height: 100, 
                              // Usa errorBuilder invece di errorWidget
                              errorBuilder: (context, error, stackTrace) => const Text(
                                "FUNKO PIECE", 
                                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            ),
                    const SizedBox(height: 30),

                    // 2. EXTRA FIELDS FOR SIGNUP
                    if (!isLogin) ...[
                      SizedBox(
                        width: formWidth,
                        child: Column(
                          children: [
                            _buildSimpleTextField(_nameCtrl, "Pirate Name", Icons.person),
                            const SizedBox(height: 10),
                            _buildCityField(),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ],

                    // 3. MAIN BOX (formLogin.png) - ALLINEAMENTO CORRETTO
                    Container(
                      width: formWidth,
                      height: formHeight,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('ui/authScreen/formLogin.png'),
                          fit: BoxFit.contain, // Mantiene le proporzioni originali
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(30, 20, 30, 0), // Padding per centrarsi sul legno
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            // Titolo (opzionale, per stile)
                            const Text("LOG-IN TO THE CREW", style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                            
                            // AREA CENTRALE: Input allineati perfettamente alle scanalature
                            // Ho tolto i Positioned e usato un'area fissa centrale
                            const SizedBox(height: 15),
                            _buildTransparentInput(_emailCtrl, "Pirate Email", false),
                            
                            const SizedBox(height: 12), // Distanza corretta tra Email e Password
                            _buildTransparentInput(_passCtrl, "Password", true),
                            
                            // AREA CONTROLLI: Row per Remember Me e Lost Route
                            // Allineata tra il legno scuro e la targhetta chiara in basso
                            const SizedBox(height: 15),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // REMEMBER ME (sinistra)
                                  GestureDetector(
                                    onTap: () => setState(() => _rememberMe = !_rememberMe),
                                    child: Row(
                                      children: [
                                        Icon(
                                          _rememberMe ? Icons.check_box : Icons.check_box_outline_blank, 
                                          color: _rememberMe ? Colors.amber : Colors.white30, 
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "Remember Me", 
                                          style: TextStyle(
                                            color: _rememberMe ? Colors.amber : Colors.white70, 
                                            fontSize: 12, 
                                            fontWeight: FontWeight.bold
                                          )
                                        ),
                                      ],
                                    ),
                                  ),

                                  // LOG POSE / LOST ROUTE? (destra)
                                  InkWell(
                                    onTap: _showForgotPasswordDialog,
                                    child: Row(
                                      children: [
                                        const Text("Lost Route?", style: TextStyle(color: Colors.white70, fontSize: 12, decoration: TextDecoration.underline)),
                                        const SizedBox(width: 5),
                                        Icon(Icons.map_outlined, color: Colors.white30, size: 16),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // AREA BOTTONE: Spazio vuoto sopra la targhetta chiara
                            // Non metto niente qui, il bottone è "fuori" dal box principale per gestirlo meglio
                          ],
                        ),
                      ),
                    ),

                    // 4. MAIN ACTION BUTTON (Posizionato sulla targhetta chiara in fondo al form)
                    const SizedBox(height: 10),
                    isLoading 
                      ? const CircularProgressIndicator(color: Colors.amber)
                      : GestureDetector(
                          onTap: _submit,
                          child: Container(
                            width: formWidth - 80, // Leggermente più stretto del form
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
                            ),
                            child: const Center(
                              child: Text(
                                "ENLIST IN THE CREW!", 
                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                          ),
                        ),

                    const SizedBox(height: 25),

                    // 5. TOGGLE REGISTRAZIONE
                    TextButton(
                      onPressed: () => setState(() { isLogin = !isLogin; _citySuggestions = []; }),
                      child: Text(
                        isLogin ? "No crew? Join us." : "Already enlisted? Login.",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Input trasparente e centrato per i ripiani del legno
  Widget _buildTransparentInput(TextEditingController ctrl, String hint, bool obscure) {
  return Container(
    height: 50, // Mantiene l'altezza per allinearsi alle scanalature del legno
    decoration: const BoxDecoration(
      color: Colors.transparent, // Rende il contenitore totalmente trasparente
    ),
    padding: const EdgeInsets.symmetric(horizontal: 10),
    child: Center(
      child: TextField(
        controller: ctrl,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white30),
          // Rimuove qualsiasi colore di riempimento predefinito
          filled: false, 
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    ),
  );
}

  // Input standard (per Name/City)
  Widget _buildSimpleTextField(TextEditingController controller, String hint, IconData icon) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: Colors.amber),
        filled: true,
        fillColor: Colors.black26,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), 
          borderSide: BorderSide.none
        ),
      ),
    );
  }

  Widget _buildCityField() {
    return Column(
      children: [
        TextField(
          controller: _cityCtrl,
          onChanged: _onCityChanged,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "City (Operative Base)",
            hintStyle: const TextStyle(color: Colors.white54),
            prefixIcon: const Icon(Icons.location_on, color: Colors.amber),
            filled: true,
            fillColor: Colors.black26,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12), 
              borderSide: BorderSide.none
            ),
            suffixIcon: _isSearchingCity 
              ? const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ) 
              : null,
          ),
        ),
        if (_citySuggestions.isNotEmpty)
          Container(
            decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(10)),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _citySuggestions.length,
              itemBuilder: (ctx, i) => ListTile(
                title: Text(_citySuggestions[i]['display_name'], style: const TextStyle(color: Colors.white, fontSize: 12)),
                onTap: () => _selectCity(_citySuggestions[i]),
              ),
            ),
          ),
      ],
    );
  }
}