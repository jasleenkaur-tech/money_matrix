// import 'dart:convert';
// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '/services/auth_service.dart';
// import 'otp_page.dart';
// import 'login_page.dart';
//
// // ===================================================
// //              SIGNUP PAGE
// // ===================================================
// class SignupPage extends StatefulWidget {
//   const SignupPage({super.key});
//
//   @override
//   State<SignupPage> createState() => _SignupPageState();
// }
//
// class _SignupPageState extends State<SignupPage>
//     with SingleTickerProviderStateMixin {
//   final _formKey = GlobalKey<FormState>();
//
//   final _name = TextEditingController();
//   final _email = TextEditingController();
//   final _mobile = TextEditingController();
//   final _dob = TextEditingController();
//   final _pass = TextEditingController();
//
//   bool _loading = false;
//   String _msg = "";
//
//   late AnimationController _fadeCtrl;
//   late Animation<double> _fadeAnim;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _fadeCtrl = AnimationController(
//       duration: const Duration(milliseconds: 700),
//       vsync: this,
//     );
//
//     _fadeAnim =
//         CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeInOutCubic);
//
//     _fadeCtrl.forward();
//   }
//
//   @override
//   void dispose() {
//     _fadeCtrl.dispose();
//     _name.dispose();
//     _email.dispose();
//     _mobile.dispose();
//     _dob.dispose();
//     _pass.dispose();
//     super.dispose();
//   }
//
//   // ===================================================
//   //                 DATE PICKER
//   // ===================================================
//   Future<void> _selectDate() async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime(2000),
//       firstDate: DateTime(1950),
//       lastDate: DateTime.now(),
//     );
//
//     if (picked != null) {
//       _dob.text =
//       "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
//     }
//   }
//
//   // ===================================================
//   //                 SIGNUP API
//   // ===================================================
//   Future<void> _handleSignup(AuthService auth) async {
//     if (!_formKey.currentState!.validate()) return;
//
//     setState(() => _loading = true);
//
//     try {
//       final mobile = "+91${_mobile.text.trim()}";
//
//       final res = await auth.signup(
//         name: _name.text.trim(),
//         email: _email.text.trim(),
//         mobile: mobile,
//         dob: _dob.text.trim(),
//         password: _pass.text,
//       );
//
//       Map<String, dynamic> parsed = res;
//
//       if (res["status"] == "error" && res["raw"] != null) {
//         final raw = res["raw"];
//         final start = raw.indexOf("{");
//         if (start > 0) {
//           try {
//             parsed = jsonDecode(raw.substring(start));
//           } catch (_) {}
//         }
//       }
//
//       setState(() => _loading = false);
//
//       if (parsed["status"] == "success") {
//         if (!mounted) return;
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (_) => OtpPage(mobile: mobile),
//           ),
//         );
//       } else {
//         setState(() => _msg = parsed["message"] ?? "Signup failed");
//       }
//     } catch (e) {
//       setState(() {
//         _loading = false;
//         _msg = "Error: $e";
//       });
//     }
//   }
//
//   // ===================================================
//   //                 MAIN UI
//   // ===================================================
//   @override
//   Widget build(BuildContext context) {
//     final auth = Provider.of<AuthService>(context, listen: false);
//
//     return Scaffold(
//       body: Container(
//         width: double.infinity,
//         height: double.infinity,
//         // decoration: const BoxDecoration(
//         //   gradient: LinearGradient(
//         //     begin: Alignment.topLeft,
//         //     end: Alignment.bottomRight,
//         //     colors: [
//         //       Color(0xFF4A148C), // Dark Purple
//         //       Color(0xFF6A1B9A), // Medium Purple
//         //       Color(0xFF7B1FA2), // Soft Purple
//         //     ],
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
//             child: Column(
//               children: [
//                 // Logo
//                 Hero(
//                   tag: "app_logo",
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(18),
//                     child: Image.asset(
//                       'assets/images/logo_app.jpeg',
//                       width: 100,
//                       height: 100,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 30),
//
//                 // Glass Card with Fade Animation
//                 FadeTransition(
//                   opacity: _fadeAnim,
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(22),
//                     child: BackdropFilter(
//                       filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
//                       child: Container(
//                         padding: const EdgeInsets.all(22),
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.12),
//                           borderRadius: BorderRadius.circular(22),
//                           border: Border.all(
//                             color: Colors.white.withOpacity(0.25),
//                           ),
//                         ),
//                         child: _signupForm(auth),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   // ===================================================
//   //                 SIGNUP FORM
//   // ===================================================
//   Widget _signupForm(AuthService auth) {
//     return Form(
//       key: _formKey,
//       child: Column(
//         children: [
//           AppInputField(controller: _name, hint: "Full Name", icon: Icons.person),
//           const SizedBox(height: 12),
//           AppMobileField(controller: _mobile),
//           const SizedBox(height: 12),
//           AppInputField(controller: _email, hint: "Email", icon: Icons.email, keyboard: TextInputType.emailAddress),
//           const SizedBox(height: 12),
//           AppInputField(controller: _dob, hint: "Date of Birth", icon: Icons.date_range, readOnly: true, onTap: _selectDate),
//           const SizedBox(height: 12),
//           AppInputField(controller: _pass, hint: "Password", icon: Icons.lock, isPassword: true),
//           const SizedBox(height: 20),
//           // Signup Button
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.blue,
//               minimumSize: const Size(double.infinity, 48),
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//             ),
//             onPressed: _loading ? null : () => _handleSignup(auth),
//             child: _loading
//                 ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
//                 : const Text("Signup", style: TextStyle(color: Colors.white, fontSize: 16)),
//           ),
//           if (_msg.isNotEmpty)
//             Padding(
//               padding: const EdgeInsets.only(top: 10),
//               child: Text(
//                 _msg,
//                 style: const TextStyle(color: Colors.redAccent),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//           const SizedBox(height: 16),
//           TextButton(
//             onPressed: () {
//               Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
//             },
//             child: const Text(
//               "Already have an account? Login",
//               style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // ===================================================
// //              REUSABLE INPUT FIELD
// // ===================================================
// class AppInputField extends StatelessWidget {
//   final TextEditingController controller;
//   final String hint;
//   final IconData icon;
//   final bool isPassword;
//   final bool readOnly;
//   final VoidCallback? onTap;
//   final TextInputType keyboard;
//
//   const AppInputField({
//     super.key,
//     required this.controller,
//     required this.hint,
//     required this.icon,
//     this.keyboard = TextInputType.text,
//     this.isPassword = false,
//     this.readOnly = false,
//     this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return TextFormField(
//       controller: controller,
//       readOnly: readOnly,
//       onTap: onTap,
//       obscureText: isPassword,
//       keyboardType: keyboard,
//       validator: (v) => v!.isEmpty ? "Enter $hint" : null,
//       style: const TextStyle(color: Colors.white),
//       decoration: _decor(hint, icon),
//     );
//   }
//
//   InputDecoration _decor(String hint, IconData icon) {
//     return InputDecoration(
//       labelText: hint,
//       labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
//       prefixIcon: Icon(icon, color: Colors.white),
//       filled: true,
//       fillColor: Colors.white.withOpacity(0.05),
//       border: _border(),
//       enabledBorder: _border(),
//       focusedBorder: const OutlineInputBorder(
//         borderSide: BorderSide(color: Colors.deepPurpleAccent),
//         borderRadius: BorderRadius.all(Radius.circular(14)),
//       ),
//     );
//   }
//
//   OutlineInputBorder _border() {
//     return OutlineInputBorder(
//       borderRadius: BorderRadius.circular(14),
//       borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
//     );
//   }
// }
//
// // ===================================================
// //              MOBILE FIELD
// // ===================================================
// class AppMobileField extends StatelessWidget {
//   final TextEditingController controller;
//
//   const AppMobileField({super.key, required this.controller});
//
//   @override
//   Widget build(BuildContext context) {
//     return TextFormField(
//       controller: controller,
//       keyboardType: TextInputType.phone,
//       validator: (v) {
//         if (v == null || v.isEmpty) return "Enter Mobile Number";
//         if (v.length != 10) return "Enter valid 10 digit number";
//         return null;
//       },
//       style: const TextStyle(color: Colors.white),
//       decoration: AppInputField(
//         controller: controller,
//         hint: "Mobile Number",
//         icon: Icons.phone,
//       )._decor("Mobile Number", Icons.phone).copyWith(
//         prefixText: "+91 ",
//         prefixStyle: const TextStyle(color: Colors.white),
//       ),
//     );
//   }
// }
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

class _SignupPageState extends State<SignupPage>
    with SingleTickerProviderStateMixin {

  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final dobController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;
  String message = "";

  late AnimationController fadeController;
  late Animation<double> fadeAnimation;

  @override
  void initState() {
    super.initState();

    fadeController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 700));

    fadeAnimation =
        CurvedAnimation(parent: fadeController, curve: Curves.easeInOut);

    fadeController.forward();
  }

  @override
  void dispose() {
    fadeController.dispose();
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    dobController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // DATE PICKER
  Future<void> pickDate() async {

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      dobController.text =
      "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }

  // SIGNUP FUNCTION
  Future<void> handleSignup(AuthService auth) async {

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      loading = true;
      message = "";
    });

    try {

      final res = await auth.signup(
        name: nameController.text,
        phone: phoneController.text,
        email: emailController.text,
        password: passwordController.text,
        dob: dobController.text,
      );

      setState(() => loading = false);

      if (res["status"] == "success") {

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => OtpPage(
              phone: phoneController.text,
            ),
          ),
        );

      } else {

        setState(() {
          message = res["message"] ?? "Signup failed";
        });

      }

    } catch (e) {

      setState(() {
        loading = false;
        message = "Error: $e";
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
              opacity: fadeAnimation,

              child: Form(
                key: _formKey,

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
                      "Create Account",
                      style: TextStyle(
                        fontSize: 30,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 25),

                    glassCard(auth),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget glassCard(AuthService auth) {

    return ClipRRect(
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

              buildField(nameController, "Full Name", Icons.person),

              const SizedBox(height: 15),

              buildField(phoneController, "Mobile Number", Icons.phone,
                  keyboard: TextInputType.phone),

              const SizedBox(height: 15),

              buildField(emailController, "Email", Icons.email,
                  keyboard: TextInputType.emailAddress),

              const SizedBox(height: 15),

              buildField(
                dobController,
                "Date of Birth",
                Icons.date_range,
                readOnly: true,
                onTap: pickDate,
              ),

              const SizedBox(height: 15),

              buildField(passwordController, "Password", Icons.lock,
                  isPassword: true),

              const SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),

                onPressed: loading ? null : () => handleSignup(auth),

                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  "Signup",
                  style: TextStyle(color: Colors.white),
                ),
              ),

              if (message.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    message,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

              const SizedBox(height: 10),

              TextButton(
                onPressed: () {

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginPage(),
                    ),
                  );

                },
                child: const Text(
                  "Already have account? Login",
                  style: TextStyle(color: Colors.white),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildField(
      TextEditingController controller,
      String hint,
      IconData icon, {

        bool isPassword = false,
        bool readOnly = false,
        VoidCallback? onTap,
        TextInputType keyboard = TextInputType.text,
      }) {

    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      readOnly: readOnly,
      onTap: onTap,
      keyboardType: keyboard,

      validator: (v) {
        if (v == null || v.isEmpty) {
          return "Enter $hint";
        }
        return null;
      },

      style: const TextStyle(color: Colors.white),

      decoration: InputDecoration(
        labelText: hint,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white),

        filled: true,
        fillColor: Colors.white.withOpacity(0.05),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),

        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide(color: Colors.deepPurpleAccent),
        ),
      ),
    );
  }
}