import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/services/auth_service.dart';
import 'resetPasswordotp.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {

  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();

  String _selectedCountryCode = "+91"; // Default
  final List<String> _countryCodes = ["+91", "+1", "+44", "+971", "+61", "+81"];

  bool _loading = false;
  String _message = "";

  Future<void> _sendOtp() async {
    final phoneInput = _phoneCtrl.text.trim();
    final newPassword = _passwordCtrl.text.trim();

    if (phoneInput.isEmpty || phoneInput.length < 10) {
      setState(() => _message = "Enter a valid phone number");
      return;
    }

    if (newPassword.isEmpty) {
      setState(() => _message = "Enter a new password");
      return;
    }

    final fullPhone = "$_selectedCountryCode$phoneInput";
    final auth = Provider.of<AuthService>(context, listen: false);

    setState(() {
      _loading = true;
      _message = "";
    });

    try {
      // ✅ Step 1: Call forgot-password to send OTP to the phone
      final res = await auth.forgotPassword(
        phone: fullPhone,
        newPassword: newPassword,
      );

      if (!mounted) return;
      setState(() => _loading = false);

      if (res["status"] == "success" || res["success"] == true) {
        // ✅ Step 2: Navigate to ResetPasswordOtpPage
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResetPasswordOtpPage(
              phone: fullPhone,
            ),
          ),
        );
      } else {
        setState(() {
          _message = res["message"] ?? "Failed to send OTP";
        });
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
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/background.png",
              fit: BoxFit.cover,
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 40),
                const CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage("assets/images/user.png"),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Forgot Password",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Enter your phone to reset password",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 30),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: Colors.white.withOpacity(0.25)),
                          ),
                          child: Column(
                            children: [
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
                                    child: TextField(
                                      controller: _phoneCtrl,
                                      keyboardType: TextInputType.phone,
                                      style: const TextStyle(color: Colors.white),
                                      decoration: _inputDecoration("Phone Number", Icons.phone),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),
                              TextField(
                                controller: _passwordCtrl,
                                obscureText: true,
                                style: const TextStyle(color: Colors.white),
                                decoration: _inputDecoration("New Password", Icons.lock),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: _loading ? null : _sendOtp,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  minimumSize: const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                                child: _loading
                                    ? const SizedBox(
                                        height: 22,
                                        width: 22,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                      )
                                    : const Text(
                                        "Verify & Send OTP",
                                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                              ),
                              if (_message.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 15),
                                  child: Text(
                                    _message,
                                    style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w500),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
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
          
          Positioned(
            top: 10,
            left: 10,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: Colors.white70),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.deepPurpleAccent, width: 1.5),
      ),
    );
  }
}
