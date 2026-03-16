// import 'dart:convert';
// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '/services/auth_service.dart';
// import '../home_page.dart';
//
// class OtpPage extends StatefulWidget {
//   final String mobile;
//   const OtpPage({super.key, required this.mobile});
//
//   @override
//   State<OtpPage> createState() => _OtpPageState();
// }
//
// class _OtpPageState extends State<OtpPage> with SingleTickerProviderStateMixin {
//   late AnimationController _fadeCtrl;
//   late Animation<double> _fadeAnim;
//
//   final TextEditingController _otpCtrl = TextEditingController();
//   bool _loading = false;
//   String? _msg;
//
//   @override
//   void initState() {
//     super.initState();
//
//     // Animation initialization
//     _fadeCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 700),
//     );
//     _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeInOut);
//     _fadeCtrl.forward();
//   }
//
//   @override
//   void dispose() {
//     _fadeCtrl.dispose();
//     _otpCtrl.dispose();
//     super.dispose();
//   }
//
//   Future<void> _verifyOtp(AuthService auth) async {
//     setState(() => _loading = true);
//     try {
//       final res = await auth.verifyOtp(
//         mobile: widget.mobile,
//         otp: _otpCtrl.text.trim(),
//       );
//
//       Map<String, dynamic> parsedRes = res;
//       if (res['status'] == 'error' && res['raw'] != null) {
//         String rawResponse = res['raw'];
//         final jsonMatch = RegExp(r'\{(?:[^{}]|\{[^{}]*\})*\}').firstMatch(rawResponse);
//         if (jsonMatch != null) {
//           parsedRes = Map<String, dynamic>.from(jsonDecode(jsonMatch.group(0)!));
//         }
//       }
//
//       setState(() => _loading = false);
//
//       if (parsedRes['status'] == 'success') {
//         if (!mounted) return;
//         Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePage()));
//       } else {
//         setState(() => _msg = parsedRes['message'] ?? 'OTP verification failed');
//       }
//     } catch (e) {
//       setState(() {
//         _loading = false;
//         _msg = 'Error: $e';
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
//         //     begin: Alignment.topLeft,
//         //     end: Alignment.bottomRight,
//         //     colors: [
//         //       Color(0xFF4A148C),
//         //       Color(0xFF6A1B9A),
//         //       Color(0xFF7B1FA2),
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
//                 FadeTransition(
//                   opacity: _fadeAnim,
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(22),
//                     child: BackdropFilter(
//                       filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
//                       child: Container(
//                         padding: const EdgeInsets.all(22),
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.12),
//                           borderRadius: BorderRadius.circular(22),
//                           border: Border.all(color: Colors.white.withOpacity(0.25)),
//                         ),
//                         child: Column(
//                           children: [
//                             const Text(
//                               "OTP Verification",
//                               style: TextStyle(
//                                 fontSize: 22,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.white,
//                               ),
//                             ),
//                             const SizedBox(height: 10),
//                             Text(
//                               "Enter the 6-digit OTP sent to\n${widget.mobile}",
//                               textAlign: TextAlign.center,
//                               style: TextStyle(color: Colors.white.withOpacity(0.8)),
//                             ),
//                             const SizedBox(height: 20),
//                             _otpField(),
//                             const SizedBox(height: 20),
//                             if (_msg != null)
//                               Text(
//                                 _msg!,
//                                 style: const TextStyle(color: Colors.redAccent, fontSize: 14),
//                                 textAlign: TextAlign.center,
//                               ),
//                             const SizedBox(height: 20),
//                             ElevatedButton(
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.blue,
//                                 minimumSize: const Size(double.infinity, 50),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(14),
//                                 ),
//                               ),
//                               onPressed: _loading ? null : () => _verifyOtp(auth),
//                               child: _loading
//                                   ? const SizedBox(
//                                 height: 24,
//                                 width: 24,
//                                 child: CircularProgressIndicator(
//                                   strokeWidth: 2,
//                                   color: Colors.white,
//                                 ),
//                               )
//                                   : const Text(
//                                 "Verify OTP",
//                                 style: TextStyle(color: Colors.white, fontSize: 16),
//                               ),
//                             ),
//                           ],
//                         ),
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
//   Widget _otpField() {
//     return TextField(
//       controller: _otpCtrl,
//       keyboardType: TextInputType.number,
//       maxLength: 6,
//       textAlign: TextAlign.center,
//       style: const TextStyle(
//         fontSize: 22,
//         letterSpacing: 4,
//         fontWeight: FontWeight.bold,
//         color: Colors.white,
//       ),
//       decoration: InputDecoration(
//         counterText: "",
//         hintText: "------",
//         hintStyle: const TextStyle(fontSize: 24, letterSpacing: 4, color: Colors.white54),
//         filled: true,
//         fillColor: Colors.white.withOpacity(0.05),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(14),
//           borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
//         ),
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
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/services/auth_service.dart';
import '../home_page.dart';

class OtpPage extends StatefulWidget {

  final String phone;

  const OtpPage({super.key, required this.phone});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage>
    with SingleTickerProviderStateMixin {

  late AnimationController fadeController;
  late Animation<double> fadeAnimation;

  final TextEditingController otpController = TextEditingController();

  bool loading = false;
  String message = "";

  @override
  void initState() {

    super.initState();

    fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    fadeAnimation =
        CurvedAnimation(parent: fadeController, curve: Curves.easeInOut);

    fadeController.forward();
  }

  @override
  void dispose() {
    fadeController.dispose();
    otpController.dispose();
    super.dispose();
  }

  Future<void> verifyOtp(AuthService auth) async {

    if (otpController.text.isEmpty) {

      setState(() {
        message = "Please enter OTP";
      });

      return;
    }

    setState(() {
      loading = true;
      message = "";
    });

    try {

      final res = await auth.verifyOtp(
        phone: widget.phone,
        otp: otpController.text,
      );

      setState(() => loading = false);

      if (res["status"] == "success") {

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const HomePage(),
          ),
        );

      } else {

        setState(() {
          message = res["message"] ?? "OTP verification failed";
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

                const SizedBox(height: 30),

                FadeTransition(
                  opacity: fadeAnimation,

                  child: ClipRRect(
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

                            const Text(
                              "OTP Verification",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),

                            const SizedBox(height: 10),

                            Text(
                              "Enter the OTP sent to\n${widget.phone}",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),

                            const SizedBox(height: 20),

                            TextField(
                              controller: otpController,
                              keyboardType: TextInputType.number,
                              maxLength: 6,
                              textAlign: TextAlign.center,

                              style: const TextStyle(
                                fontSize: 22,
                                letterSpacing: 4,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),

                              decoration: InputDecoration(
                                counterText: "",
                                hintText: "------",

                                hintStyle: const TextStyle(
                                  fontSize: 24,
                                  letterSpacing: 4,
                                  color: Colors.white54,
                                ),

                                filled: true,
                                fillColor: Colors.white.withOpacity(0.05),

                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            if (message.isNotEmpty)
                              Text(
                                message,
                                style: const TextStyle(color: Colors.red),
                              ),

                            const SizedBox(height: 20),

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

                              onPressed: loading
                                  ? null
                                  : () => verifyOtp(auth),

                              child: loading
                                  ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                                  : const Text(
                                "Verify OTP",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}