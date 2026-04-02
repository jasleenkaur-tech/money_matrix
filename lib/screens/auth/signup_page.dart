import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/services/auth_service.dart';
import 'otp_page.dart';
import 'login_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String _selectedCountryCode = "+91"; // Default
  final List<String> _countryCodes = ["+91", "+1", "+44", "+971", "+61", "+81"];

  bool _loading = false;
  bool _obscurePass = true;
  String _message = "";

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup(AuthService auth) async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _message = "";
    });

    try {
      // ✅ Combine country code with phone number
      final fullPhone = "$_selectedCountryCode${phoneController.text.trim()}";

      final res = await auth.signup(
        name: nameController.text.trim(),
        phone: fullPhone,
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (!mounted) return;
      setState(() => _loading = false);

      final String status = (res["status"] ?? "").toString().toLowerCase();
      final String msg = (res["message"] ?? "").toString().toLowerCase();
      
      bool isSuccess = status.contains("success") || 
                       status.contains("otp") || 
                       msg.contains("otp") || 
                       msg.contains("sent") ||
                       res["success"] == true;

      if (isSuccess) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => OtpPage(phone: fullPhone),
          ),
        );
      } else {
        setState(() => _message = res["message"] ?? "Signup failed");
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _message = "Connection error. Please try again.";
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
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  Hero(
                    tag: "app_logo",
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.asset("assets/images/logo_app.jpeg", width: 80, height: 80),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text("Create Account", style: TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Form(
                        key: _formKey,
                        child: _glassCard(auth),
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

  Widget _glassCard(AuthService auth) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildField(controller: nameController, hint: "Full Name", icon: Icons.person_outline),
              const SizedBox(height: 14),

              // ✅ PHONE FIELD WITH COUNTRY CODE DROPDOWN
              Row(
                children: [
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
                          return DropdownMenuItem<String>(
                            value: code,
                            child: Text(code),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedCountryCode = val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildField(controller: phoneController, hint: "Phone Number", icon: Icons.phone_outlined, keyboard: TextInputType.phone),
                  ),
                ],
              ),

              const SizedBox(height: 14),
              _buildField(controller: emailController, hint: "Email", icon: Icons.email_outlined, keyboard: TextInputType.emailAddress),
              const SizedBox(height: 14),
              _buildField(controller: passwordController, hint: "Password", icon: Icons.lock_outline, isPassword: true),
              const SizedBox(height: 22),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, 
                  minimumSize: const Size(double.infinity, 50), 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))
                ),
                onPressed: _loading ? null : () => _handleSignup(auth),
                child: _loading 
                  ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                  : const Text("Sign Up", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              if (_message.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(_message, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
                ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage())),
                child: const Text("Already have an account? Login", style: TextStyle(color: Colors.white70)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({required TextEditingController controller, required String hint, required IconData icon, bool isPassword = false, TextInputType keyboard = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? _obscurePass : false,
      keyboardType: keyboard,
      style: const TextStyle(color: Colors.white),
      validator: (v) => (v == null || v.isEmpty) ? "Enter $hint" : null,
      decoration: InputDecoration(
        labelText: hint,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70, size: 20),
        suffixIcon: isPassword ? IconButton(icon: Icon(_obscurePass ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.white54, size: 20), onPressed: () => setState(() => _obscurePass = !_obscurePass)) : null,
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.white.withOpacity(0.3))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.deepPurpleAccent, width: 1.5)),
      ),
    );
  }
}
