import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/services/auth_service.dart';
import 'login_page.dart';

class ResetPasswordOtpPage extends StatefulWidget {
  final String phone;
  const ResetPasswordOtpPage({super.key, required this.phone});

  @override
  State<ResetPasswordOtpPage> createState() => _ResetPasswordOtpPageState();
}

class _ResetPasswordOtpPageState extends State<ResetPasswordOtpPage> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final TextEditingController _otpController = TextEditingController();
  bool _loading = false;
  String _message = "";

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
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyResetOtp(AuthService auth) async {
    if (_otpController.text.length < 4) {
      setState(() => _message = "Please enter a valid OTP");
      return;
    }

    setState(() {
      _loading = true;
      _message = "";
    });

    try {
      // ✅ Now correctly matches the AuthService resetPassword signature (only phone and otp)
      final res = await auth.resetPassword(
        phone: widget.phone,
        otp: _otpController.text.trim(),
      );

      if (!mounted) return;
      setState(() => _loading = false);

      final bool isSuccess = res["status"] == "success" || 
                             res["status"] == true || 
                             res["success"] == true;

      if (isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password reset successful! Please login.")),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      } else {
        setState(() {
          _message = res["message"] ?? "OTP verification failed";
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
    final auth = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(image: AssetImage("assets/images/background.png"), fit: BoxFit.cover),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  Hero(
                    tag: "app_logo",
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.asset("assets/images/logo_app.jpeg", width: 100, height: 100),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: Colors.white.withOpacity(0.25)),
                        ),
                        child: Column(
                          children: [
                            const Text("Reset Password", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                            const SizedBox(height: 12),
                            Text("Enter the OTP sent to\n${widget.phone}", textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
                            const SizedBox(height: 25),
                            TextField(
                              controller: _otpController,
                              keyboardType: TextInputType.number,
                              maxLength: 6,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold, color: Colors.white),
                              decoration: InputDecoration(
                                counterText: "",
                                hintText: "------",
                                hintStyle: const TextStyle(color: Colors.white24),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.05),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.white.withOpacity(0.3))),
                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.deepPurpleAccent, width: 1.5)),
                              ),
                            ),
                            const SizedBox(height: 25),
                            if (_message.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 15),
                                child: Text(_message, style: const TextStyle(color: Colors.blue), textAlign: TextAlign.center),
                              ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              onPressed: _loading ? null : () => _verifyResetOtp(auth),
                              child: _loading
                                  ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : const Text("Verify & Reset", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
