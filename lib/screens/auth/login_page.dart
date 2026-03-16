// import 'dart:convert';
// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '/services/auth_service.dart';
// import '../home_page.dart';
// import 'signup_page.dart';
//
// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});
//
//   @override
//   _LoginPageState createState() => _LoginPageState();
// }
//
// class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
//   final TextEditingController _mobileCtrl = TextEditingController();
//   final TextEditingController _passCtrl = TextEditingController();
//
//   late AnimationController _animCtrl;
//   late Animation<double> _fadeAnim;
//   late Animation<Offset> _slideAnim;
//
//   bool _loading = false;
//   String _msg = "";
//
//   @override
//   void initState() {
//     super.initState();
//
//     _animCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 700),
//     );
//
//     _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut);
//
//     _slideAnim = Tween<Offset>(
//       begin: const Offset(0, 0.25),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut));
//
//     _animCtrl.forward();
//   }
//
//   @override
//   void dispose() {
//     _animCtrl.dispose();
//     _mobileCtrl.dispose();
//     _passCtrl.dispose();
//     super.dispose();
//   }
//
//   Future<void> _handleLogin(AuthService auth) async {
//     final mobile = _mobileCtrl.text.trim();
//     final password = _passCtrl.text.trim();
//
//     if (mobile.isEmpty || password.isEmpty) {
//       setState(() => _msg = 'Mobile and Password are required');
//       return;
//     }
//
//     if (!RegExp(r'^\d{10}$').hasMatch(mobile)) {
//       setState(() => _msg = 'Enter a valid 10-digit mobile number');
//       return;
//     }
//
//     setState(() {
//       _loading = true;
//       _msg = "";
//     });
//
//     try {
//       final res = await auth.login(
//         mobile: "+91$mobile",
//         password: password,
//       );
//
//       Map<String, dynamic> parsed = res;
//
//       if (res["status"] == null && res["raw"] != null) {
//         final raw = res["raw"] as String;
//         final jsonMatch =
//         RegExp(r'\{(?:[^{}]|\{[^{}]*\})*\}').firstMatch(raw);
//         if (jsonMatch != null) {
//           parsed = Map<String, dynamic>.from(jsonDecode(jsonMatch.group(0)!));
//         }
//       }
//
//       setState(() => _loading = false);
//
//       if (parsed["status"] == "success") {
//         if (!mounted) return;
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => const HomePage()),
//         );
//       } else {
//         setState(() => _msg = parsed["message"] ?? "Login failed");
//       }
//     } catch (e) {
//       setState(() {
//         _loading = false;
//         _msg = "Error: $e";
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final auth = Provider.of<AuthService>(context, listen: false);
//
//     return Scaffold(
//       body: Container(
//         // decoration: const BoxDecoration(
//         //   gradient: LinearGradient(
//         //     colors: [Color(0xFF4A148C), Color(0xFF6A1B9A), Color(0xFF7B1FA2)],
//         //     begin: Alignment.topLeft,
//         //     end: Alignment.bottomRight,
//         //   ),
//         // ),
//         decoration: const BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage("assets/images/background.png"),
//             fit: BoxFit.cover,
//           ),
//         ),
//         child: Center(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.symmetric(horizontal: 24),
//             child: FadeTransition(
//               opacity: _fadeAnim,
//               child: SlideTransition(
//                 position: _slideAnim,
//                 child: Column(
//                   children: [
//                     Hero(
//                       tag: "app_logo",
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(18),
//                         child: Image.asset(
//                           "assets/images/logo_app.jpeg",
//                           width: 100,
//                           height: 100,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 25),
//                     const Text(
//                       "Welcome Back!",
//                       style: TextStyle(
//                         fontSize: 32,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                     const SizedBox(height: 6),
//                     const Text(
//                       "Please login to continue",
//                       style: TextStyle(fontSize: 16, color: Colors.white),
//                     ),
//                     const SizedBox(height: 25),
//
//                     // Glassmorphic Card
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(22),
//                       child: BackdropFilter(
//                         filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
//                         child: Container(
//                           padding: const EdgeInsets.all(22),
//                           decoration: BoxDecoration(
//                             color: Colors.white.withOpacity(0.12),
//                             borderRadius: BorderRadius.circular(22),
//                             border: Border.all(
//                               color: Colors.white.withOpacity(0.25),
//                             ),
//                           ),
//                           child: Column(
//                             children: [
//                               _customTextField(
//                                 controller: _mobileCtrl,
//                                 hint: "Mobile Number",
//                                 icon: Icons.phone,
//                               ),
//                               const SizedBox(height: 18),
//                               _customTextField(
//                                 controller: _passCtrl,
//                                 hint: "Password",
//                                 icon: Icons.lock,
//                                 isPassword: true,
//                               ),
//                               const SizedBox(height: 25),
//                               ElevatedButton(
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: Colors.blue,
//                                   minimumSize: const Size(double.infinity, 50),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(14),
//                                   ),
//                                 ),
//                                 onPressed: _loading ? null : () => _handleLogin(auth),
//                                 child: _loading
//                                     ? const SizedBox(
//                                   height: 24,
//                                   width: 24,
//                                   child: CircularProgressIndicator(
//                                     strokeWidth: 2.5,
//                                     color: Colors.white,
//                                   ),
//                                 )
//                                     : const Text(
//                                   "Login",
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//                               if (_msg.isNotEmpty)
//                                 Padding(
//                                   padding: const EdgeInsets.only(top: 12),
//                                   child: Text(
//                                     _msg,
//                                     style: const TextStyle(
//                                       color: Colors.redAccent,
//                                       fontSize: 14,
//                                     ),
//                                     textAlign: TextAlign.center,
//                                   ),
//                                 ),
//                               const SizedBox(height: 16),
//                               TextButton(
//                                 onPressed: () {
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (_) => const SignupPage(),
//                                     ),
//                                   );
//                                 },
//                                 child: const Text(
//                                   "Create an Account",
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 16,
//                                     decoration: TextDecoration.underline,
//                                   ),
//                                 ),
//                               )
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _customTextField({
//     required TextEditingController controller,
//     required String hint,
//     required IconData icon,
//     bool isPassword = false,
//   }) {
//     return TextField(
//       controller: controller,
//       obscureText: isPassword,
//       keyboardType: isPassword ? TextInputType.text : TextInputType.phone,
//       style: const TextStyle(color: Colors.white),
//       decoration: InputDecoration(
//         labelText: hint,
//         labelStyle: const TextStyle(color: Colors.white70),
//         prefixIcon: Icon(icon, color: Colors.white),
//         filled: true,
//         fillColor: Colors.white.withOpacity(0.05),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(14),
//           borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
//         ),
//         focusedBorder: const OutlineInputBorder(
//           borderRadius: BorderRadius.all(Radius.circular(14)),
//           borderSide: BorderSide(color: Colors.deepPurpleAccent),
//         ),
//       ),
//     );
//   }
// }
// import 'dart:convert';
// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '/services/auth_service.dart';
// import '../home_page.dart';
// import 'change_password_page.dart';
// import 'signup_page.dart';
//
// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});
//
//   @override
//   _LoginPageState createState() => _LoginPageState();
// }
//
// class _LoginPageState extends State<LoginPage>
//     with SingleTickerProviderStateMixin {
//   final TextEditingController _mobileCtrl = TextEditingController();
//   final TextEditingController _passCtrl = TextEditingController();
//
//   late AnimationController _animCtrl;
//   late Animation<double> _fadeAnim;
//   late Animation<Offset> _slideAnim;
//
//   bool _loading = false;
//   String _msg = "";
//
//   @override
//   void initState() {
//     super.initState();
//
//     _animCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 700),
//     );
//
//     _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut);
//
//     _slideAnim = Tween<Offset>(
//       begin: const Offset(0, 0.25),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut));
//
//     _animCtrl.forward();
//   }
//
//   @override
//   void dispose() {
//     _animCtrl.dispose();
//     _mobileCtrl.dispose();
//     _passCtrl.dispose();
//     super.dispose();
//   }
//
//     if (mobile.isEmpty || password.isEmpty) {
//       setState(() => _msg = 'Mobile and Password are required');
//       return;
//     }
//
//
//     if (!RegExp(r'^\d{10}$').hasMatch(mobile)) {
//       setState(() => _msg = 'Enter a valid 10-digit mobile number');
//       return;
//     }
//
//     setState(() {
//       _loading = true;
//       _msg = "";
//     });
//
//     // try {
//     //   final res = await auth.login(
//     //     mobile: "+91$mobile",
//     //     password: password,
//     //);
//     final res = await auth.login(
//       phoneOrEmail: phoneController.text,
//       password: passwordController.text,
//     );
//
//       Map<String, dynamic> parsed = res;
//
//       if (res["status"] == null && res["raw"] != null) {
//         final raw = res["raw"] as String;
//         final jsonMatch =
//         RegExp(r'\{(?:[^{}]|\{[^{}]*\})*\}').firstMatch(raw);
//         if (jsonMatch != null) {
//           parsed = Map<String, dynamic>.from(
//               jsonDecode(jsonMatch.group(0)!));
//         }
//       }
//
//       setState(() => _loading = false);
//
//       if (parsed["status"] == "success") {
//         if (!mounted) return;
//
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => const HomePage()),
//         );
//       } else {
//         setState(() => _msg = parsed["message"] ?? "Login failed");
//       }
//     } catch (e) {
//       setState(() {
//         _loading = false;
//         _msg = "Error: $e";
//       });
//     }
//   }
//
//   void _forgotPassword() {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text("Forgot Password feature coming soon"),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final auth = Provider.of<AuthService>(context, listen: false);
//
//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage("assets/images/background.png"),
//             fit: BoxFit.cover,
//           ),
//         ),
//         child: Center(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.symmetric(horizontal: 24),
//             child: FadeTransition(
//               opacity: _fadeAnim,
//               child: SlideTransition(
//                 position: _slideAnim,
//                 child: Column(
//                   children: [
//                     Hero(
//                       tag: "app_logo",
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(18),
//                         child: Image.asset(
//                           "assets/images/logo_app.jpeg",
//                           width: 100,
//                           height: 100,
//                         ),
//                       ),
//                     ),
//
//                     const SizedBox(height: 25),
//
//                     const Text(
//                       "Welcome Back!",
//                       style: TextStyle(
//                         fontSize: 32,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//
//                     const SizedBox(height: 6),
//
//                     const Text(
//                       "Please login to continue",
//                       style: TextStyle(fontSize: 16, color: Colors.white),
//                     ),
//
//                     const SizedBox(height: 25),
//
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(22),
//                       child: BackdropFilter(
//                         filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
//                         child: Container(
//                           padding: const EdgeInsets.all(22),
//                           decoration: BoxDecoration(
//                             color: Colors.white.withOpacity(0.12),
//                             borderRadius: BorderRadius.circular(22),
//                             border: Border.all(
//                               color: Colors.white.withOpacity(0.25),
//                             ),
//                           ),
//                           child: Column(
//                             children: [
//
//                               _customTextField(
//                                 controller: _mobileCtrl,
//                                 hint: "Mobile Number",
//                                 icon: Icons.phone,
//                               ),
//
//                               const SizedBox(height: 18),
//
//                               _customTextField(
//                                 controller: _passCtrl,
//                                 hint: "Password",
//                                 icon: Icons.lock,
//                                 isPassword: true,
//                               ),
//
//                               const SizedBox(height: 8),
//
//                               TextButton(
//                                 onPressed: () {
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (_) => const ChangePasswordPage(),
//                                     ),
//                                   );
//                                 },
//                                 child: const Text(
//                                   "Forgot Password?",
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 14,
//                                     decoration: TextDecoration.underline,
//                                   ),
//                                 ),
//                               ),
//
//                               const SizedBox(height: 10),
//
//                               ElevatedButton(
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: Colors.blue,
//                                   minimumSize:
//                                   const Size(double.infinity, 50),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius:
//                                     BorderRadius.circular(14),
//                                   ),
//                                 ),
//                                 onPressed: _loading
//                                     ? null
//                                     : () => _handleLogin(auth),
//                                 child: _loading
//                                     ? const SizedBox(
//                                   height: 24,
//                                   width: 24,
//                                   child:
//                                   CircularProgressIndicator(
//                                     strokeWidth: 2.5,
//                                     color: Colors.white,
//                                   ),
//                                 )
//                                     : const Text(
//                                   "Login",
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     color: Colors.white,
//                                     fontWeight:
//                                     FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//
//                               if (_msg.isNotEmpty)
//                                 Padding(
//                                   padding:
//                                   const EdgeInsets.only(top: 12),
//                                   child: Text(
//                                     _msg,
//                                     style: const TextStyle(
//                                       color: Colors.redAccent,
//                                       fontSize: 14,
//                                     ),
//                                     textAlign: TextAlign.center,
//                                   ),
//                                 ),
//
//                               const SizedBox(height: 16),
//
//                               TextButton(
//                                 onPressed: () {
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (_) =>
//                                       const SignupPage(),
//                                     ),
//                                   );
//                                 },
//                                 child: const Text(
//                                   "Create an Account",
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 16,
//                                     decoration:
//                                     TextDecoration.underline,
//                                   ),
//                                 ),
//                               )
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _customTextField({
//     required TextEditingController controller,
//     required String hint,
//     required IconData icon,
//     bool isPassword = false,
//   }) {
//     return TextField(
//       controller: controller,
//       obscureText: isPassword,
//       keyboardType:
//       isPassword ? TextInputType.text : TextInputType.phone,
//       style: const TextStyle(color: Colors.white),
//       decoration: InputDecoration(
//         labelText: hint,
//         labelStyle: const TextStyle(color: Colors.white70),
//         prefixIcon: Icon(icon, color: Colors.white),
//         filled: true,
//         fillColor: Colors.white.withOpacity(0.05),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(14),
//           borderSide:
//           BorderSide(color: Colors.white.withOpacity(0.3)),
//         ),
//         focusedBorder: const OutlineInputBorder(
//           borderRadius: BorderRadius.all(Radius.circular(14)),
//           borderSide:
//           BorderSide(color: Colors.deepPurpleAccent),
//         ),
//       ),
//     );
//   }
// }

import 'dart:convert';
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

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {

  final TextEditingController _mobileCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  bool _loading = false;
  String _msg = "";

  @override
  void initState() {
    super.initState();

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut);

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut));

    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _mobileCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  /// ==========================
  /// LOGIN FUNCTION
  /// ==========================
  Future<void> _handleLogin(AuthService auth) async {

    final phone = _mobileCtrl.text.trim();
    final password = _passCtrl.text.trim();

    if (phone.isEmpty || password.isEmpty) {
      setState(() => _msg = "Phone/Email and Password required");
      return;
    }

    setState(() {
      _loading = true;
      _msg = "";
    });

    try {

      final res = await auth.login(
        phone: phone,
        password: password,
      );

      Map<String, dynamic> parsed = res;

      if (res["status"] == null && res["raw"] != null) {
        final raw = res["raw"] as String;
        final jsonMatch =
        RegExp(r'\{(?:[^{}]|\{[^{}]*\})*\}').firstMatch(raw);

        if (jsonMatch != null) {
          parsed = Map<String, dynamic>.from(
              jsonDecode(jsonMatch.group(0)!));
        }
      }

      setState(() => _loading = false);

      if (parsed["status"] == "success") {

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );

      } else {

        setState(() => _msg = parsed["message"] ?? "Login failed");

      }

    } catch (e) {

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

      body: Container(

        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.png"),
            fit: BoxFit.cover,
          ),
        ),

        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),

            child: FadeTransition(
              opacity: _fadeAnim,

              child: SlideTransition(
                position: _slideAnim,

                child: Column(

                  children: [

                    Hero(
                      tag: "app_logo",
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.asset(
                          "assets/images/logo_app.jpeg",
                          width: 100,
                          height: 100,
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    const Text(
                      "Welcome Back!",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      "Please login to continue",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),

                    const SizedBox(height: 25),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(22),

                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),

                        child: Container(
                          padding: const EdgeInsets.all(22),

                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.25),
                            ),
                          ),

                          child: Column(

                            children: [

                              _customTextField(
                                controller: _mobileCtrl,
                                hint: "Phone or Email",
                                icon: Icons.phone,
                              ),

                              const SizedBox(height: 18),

                              _customTextField(
                                controller: _passCtrl,
                                hint: "Password",
                                icon: Icons.lock,
                                isPassword: true,
                              ),

                              const SizedBox(height: 8),

                              TextButton(
                                onPressed: () {

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                      const ChangePasswordPage(),
                                    ),
                                  );

                                },

                                child: const Text(
                                  "Forgot Password?",
                                  style: TextStyle(
                                    color: Colors.white,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 10),

                              ElevatedButton(

                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  minimumSize:
                                  const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(14),
                                  ),
                                ),

                                onPressed: _loading
                                    ? null
                                    : () => _handleLogin(auth),

                                child: _loading
                                    ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                                    : const Text(
                                  "Login",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight:
                                    FontWeight.bold,
                                  ),
                                ),
                              ),

                              if (_msg.isNotEmpty)

                                Padding(
                                  padding:
                                  const EdgeInsets.only(top: 12),

                                  child: Text(
                                    _msg,
                                    style: const TextStyle(
                                      color: Colors.redAccent,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),

                              const SizedBox(height: 16),

                              TextButton(

                                onPressed: () {

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                      const SignupPage(),
                                    ),
                                  );

                                },

                                child: const Text(
                                  "Create an Account",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    decoration:
                                    TextDecoration.underline,
                                  ),
                                ),
                              )

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

      ),

    );

  }

  /// ==========================
  /// TEXT FIELD UI
  /// ==========================
  Widget _customTextField({

    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,

  }) {

    return TextField(

      controller: controller,
      obscureText: isPassword,
      keyboardType:
      isPassword ? TextInputType.text : TextInputType.emailAddress,

      style: const TextStyle(color: Colors.white),

      decoration: InputDecoration(

        labelText: hint,
        labelStyle: const TextStyle(color: Colors.white70),

        prefixIcon: Icon(icon, color: Colors.white),

        filled: true,
        fillColor: Colors.white.withOpacity(0.05),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
          BorderSide(color: Colors.white.withOpacity(0.3)),
        ),

        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide:
          BorderSide(color: Colors.deepPurpleAccent),
        ),

      ),

    );

  }

}