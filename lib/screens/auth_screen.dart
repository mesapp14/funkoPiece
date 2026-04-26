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

  // --- LOGICA ORIGINALE PRESERVATA ---
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
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Arruolato! Ora effettua il login.")));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'])));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Errore di connessione")));
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
        title: const Text("Recupero Password", style: TextStyle(color: Colors.white)),
        content: _buildTextField(resetEmailCtrl, "Tua Email", Icons.email),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Chiudi", style: TextStyle(color: Colors.white70))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            onPressed: () => Navigator.pop(context), 
            child: const Text("Invia", style: TextStyle(color: Colors.black))
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. SFONDO BLU FUNKO POP
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
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    // 2. LOGO TITOLO
                    Image.asset('ui/authScreen/logo_funkopiece.png', height: 110),
                    const SizedBox(height: 30),

                    // 3. FORM MARRONE COMPATTO
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5D4037),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: Colors.amber, width: 3),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 15)],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!isLogin) ...[
                            _buildTextField(_nameCtrl, "Nome Pirata", Icons.person),
                            const SizedBox(height: 10),
                            // CAMPO CITTA' (Indispensabile per Signup)
                            TextField(
                              controller: _cityCtrl,
                              onChanged: _onCityChanged,
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                              decoration: InputDecoration(
                                hintText: "Città (Base Operativa)",
                                hintStyle: const TextStyle(color: Colors.white54),
                                prefixIcon: const Icon(Icons.location_city, color: Colors.amber, size: 20),
                                filled: true,
                                fillColor: Colors.black.withOpacity(0.2),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                                suffixIcon: _isSearchingCity ? const SizedBox(width: 20, height: 20, child: Padding(padding: EdgeInsets.all(10), child: CircularProgressIndicator(strokeWidth: 2, color: Colors.amber))) : null,
                              ),
                            ),
                            if (_citySuggestions.isNotEmpty)
                              Container(
                                margin: const EdgeInsets.only(top: 5),
                                decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(10)),
                                constraints: const BoxConstraints(maxHeight: 150),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: _citySuggestions.length,
                                  itemBuilder: (context, i) => ListTile(
                                    title: Text(_citySuggestions[i]['display_name'], style: const TextStyle(color: Colors.white, fontSize: 12)),
                                    onTap: () => _selectCity(_citySuggestions[i]),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 10),
                          ],
                          _buildTextField(_emailCtrl, "Email", Icons.email, isEmail: true),
                          const SizedBox(height: 10),
                          _buildTextField(_passCtrl, "Password", Icons.lock, isPassword: true),
                          const SizedBox(height: 15),

                          // ICONE PERSONALIZZATE (RICORDAMI E FORGOT)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () => setState(() => _rememberMe = !_rememberMe),
                                child: Row(
                                  children: [
                                    Image.asset(_rememberMe ? 'ui/authScreen/icon_check_on.png' : 'ui/authScreen/icon_check_off.png', width: 22),
                                    const SizedBox(width: 8),
                                    const Text("Ricordami", style: TextStyle(color: Colors.white, fontSize: 12)),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: _showForgotPasswordDialog,
                                child: Row(
                                  children: [
                                    const Text("Perso Rotta?", style: TextStyle(color: Colors.amber, fontSize: 12)),
                                    const SizedBox(width: 5),
                                    Image.asset('ui/authScreen/icon_forgot.png', width: 22),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // 4. PULSANTE LOGIN/SIGNUP ESTERNO
                    isLoading
                      ? const CircularProgressIndicator(color: Colors.amber)
                      : GestureDetector(
                          onTap: _submit,
                          child: Image.asset('ui/authScreen/btn_entra_rotta.png', height: 65),
                        ),

                    const SizedBox(height: 15),

                    // 5. TOGGLE REGISTRAZIONE
                    TextButton(
                      onPressed: () => setState(() { isLogin = !isLogin; _citySuggestions = []; }),
                      child: Text(
                        isLogin ? "Non hai una ciurma? Arruolati." : "Hai già una nave? Accedi.",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
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

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {bool isPassword = false, bool isEmail = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: Colors.amber, size: 20),
        filled: true,
        fillColor: Colors.black.withOpacity(0.2),
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      ),
    );
  }
}