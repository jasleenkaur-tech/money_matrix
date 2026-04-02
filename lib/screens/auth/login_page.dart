import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/services/auth_service.dart';
import '../home_page.dart';
import 'change_password_page.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {

  final TextEditingController _inputCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();

  bool _isPhoneLogin = false; // Toggle state
  String _selectedCountryCode = "+91";
  final List<String> _countryCodes = ["+91", "+1", "+44", "+971", "+61", "+81"];

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  bool _loading = false;
  String _msg = "";

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _inputCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin(AuthService auth) async {
    final input = _inputCtrl.text.trim();
    final password = _passCtrl.text.trim();

    if (input.isEmpty || password.isEmpty) {
      setState(() => _msg = "All fields are required");
      return;
    }

    setState(() {
      _loading = true;
      _msg = "";
    });

    try {
      String identifier = input;
      if (_isPhoneLogin) {
        identifier = "$_selectedCountryCode$input";
      }

      final res = await auth.login(identifier: identifier, password: password);
      
      if (!mounted) return;
      setState(() => _loading = false);

      if (res["status"] == "success" || res["success"] == true) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
          (route) => false,
        );
      } else {
        setState(() => _msg = res["message"] ?? "Login failed");
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _msg = "Error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/images/background.png", fit: BoxFit.cover),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Hero(
                    tag: "app_logo",
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.asset("assets/images/logo_app.jpeg", width: 100, height: 100),
                    ),
                  ),

                  const SizedBox(height: 25),
                  const Text("Welcome Back!", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 6),
                  const Text("Please login to continue", style: TextStyle(fontSize: 16, color: Colors.white70)),
                  
                  const SizedBox(height: 25),

                  // SCROLLABLE FORM
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                          child: Container(
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(color: Colors.white.withOpacity(0.25)),
                            ),
                            child: Column(
                              children: [
                                
                                // ✅ TOGGLE FOR EMAIL / PHONE
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _modeIcon(Icons.email_outlined, "Email", !_isPhoneLogin),
                                    const SizedBox(width: 20),
                                    _modeIcon(Icons.person_outline, "Phone", _isPhoneLogin),
                                  ],
                                ),
                                
                                const SizedBox(height: 25),

                                // ✅ DYNAMIC INPUT FIELD
                                Row(
                                  children: [
                                    if (_isPhoneLogin) ...[
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.05),
                                          borderRadius: BorderRadius.circular(14),
                                          border: Border.all(color: Colors.white.withOpacity(0.3)),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            value: _selectedCountryCode,
                                            dropdownColor: Colors.black87,
                                            style: const TextStyle(color: Colors.white),
                                            items: _countryCodes.map((String code) {
                                              return DropdownMenuItem<String>(value: code, child: Text(code));
                                            }).toList(),
                                            onChanged: (val) {
                                              if (val != null) setState(() => _selectedCountryCode = val);
                                            },
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                    ],
                                    Expanded(
                                      child: _customField(
                                        _inputCtrl, 
                                        _isPhoneLogin ? "Phone Number" : "Email Address", 
                                        _isPhoneLogin ? Icons.phone_outlined : Icons.email_outlined
                                      ),
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(height: 18),
                                _customField(_passCtrl, "Password", Icons.lock_outline, isPassword: true),
                                
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordPage())),
                                    child: const Text("Forgot Password?", style: TextStyle(color: Colors.white70, decoration: TextDecoration.underline)),
                                  ),
                                ),

                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    minimumSize: const Size(double.infinity, 50),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  ),
                                  onPressed: _loading ? null : () => _handleLogin(auth),
                                  child: _loading 
                                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                    : const Text("Login", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                                ),

                                if (_msg.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: Text(_msg, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
                                  ),

                                const SizedBox(height: 20),
                                TextButton(
                                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupPage())),
                                  child: const Text("Create an Account", style: TextStyle(color: Colors.white, fontSize: 16, decoration: TextDecoration.underline)),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _modeIcon(IconData icon, String label, bool isActive) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isPhoneLogin = (label == "Phone");
          _inputCtrl.clear();
          _msg = "";
        });
      },
      child: Column(
        children: [
          Icon(icon, color: isActive ? Colors.blue : Colors.white54, size: 28),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: isActive ? Colors.blue : Colors.white54, fontSize: 12, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
          if (isActive)
            Container(margin: const EdgeInsets.only(top: 2), height: 2, width: 20, color: Colors.blue),
        ],
      ),
    );
  }

  Widget _customField(TextEditingController ctrl, String hint, IconData icon, {bool isPassword = false}) {
    return TextField(
      controller: ctrl,
      obscureText: isPassword,
      keyboardType: _isPhoneLogin && !isPassword ? TextInputType.phone : TextInputType.emailAddress,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: hint,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.white.withOpacity(0.3))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.deepPurpleAccent, width: 1.5)),
      ),
    );
  }
}
