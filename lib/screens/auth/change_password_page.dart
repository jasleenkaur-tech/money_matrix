// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'otp_page.dart';
//
// class ChangePasswordPage extends StatefulWidget {
//   const ChangePasswordPage({super.key});
//
//   @override
//   _ChangePasswordPageState createState() => _ChangePasswordPageState();
// }
//
// class _ChangePasswordPageState extends State<ChangePasswordPage> {
//   final TextEditingController _phoneCtrl = TextEditingController();
//   final TextEditingController _passwordCtrl = TextEditingController();
//
//   void _sendOtp() {
//     final mobile = _phoneCtrl.text.trim();
//     if (mobile.isEmpty || mobile.length != 10) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Enter a valid 10-digit phone number")),
//       );
//       return;
//     }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           // Background image
//           SizedBox.expand(
//             child: Image.asset(
//               "assets/images/background.png",
//               fit: BoxFit.cover,
//             ),
//           ),
//
//           // Content
//           Center(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.symmetric(horizontal: 24),
//               child: Column(
//                 children: [
//                   // User Avatar
//                   CircleAvatar(
//                     radius: 50,
//                     backgroundImage:
//                     AssetImage("assets/images/user.png"),
//                   ),
//                   const SizedBox(height: 20),
//                   // Glassmorphic container for phone + password
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(22),
//                     child: BackdropFilter(
//                       filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
//                       child: Container(
//                         padding: const EdgeInsets.all(20),
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.12),
//                           borderRadius: BorderRadius.circular(22),
//                           border: Border.all(
//                             color: Colors.white.withOpacity(0.25),
//                           ),
//                         ),
//                         child: Column(
//                           children: [
//                             TextField(
//                               controller: _phoneCtrl,
//                               keyboardType: TextInputType.phone,
//                               style: const TextStyle(color: Colors.white),
//                               decoration: InputDecoration(
//                                 labelText: "Phone Number",
//                                 labelStyle:
//                                 const TextStyle(color: Colors.white70),
//                                 prefixIcon:
//                                 const Icon(Icons.phone, color: Colors.white),
//                                 filled: true,
//                                 fillColor: Colors.white.withOpacity(0.05),
//                                 enabledBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(14),
//                                   borderSide: BorderSide(
//                                       color: Colors.white.withOpacity(0.3)),
//                                 ),
//                                 focusedBorder: const OutlineInputBorder(
//                                   borderRadius:
//                                   BorderRadius.all(Radius.circular(14)),
//                                   borderSide: BorderSide(
//                                       color: Colors.deepPurpleAccent),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(height: 16),
//                             TextField(
//                               controller: _passwordCtrl,
//                               obscureText: true,
//                               style: const TextStyle(color: Colors.white),
//                               decoration: InputDecoration(
//                                 labelText: "New Password",
//                                 labelStyle:
//                                 const TextStyle(color: Colors.white70),
//                                 prefixIcon:
//                                 const Icon(Icons.lock, color: Colors.white),
//                                 filled: true,
//                                 fillColor: Colors.white.withOpacity(0.05),
//                                 enabledBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(14),
//                                   borderSide: BorderSide(
//                                       color: Colors.white.withOpacity(0.3)),
//                                 ),
//                                 focusedBorder: const OutlineInputBorder(
//                                   borderRadius:
//                                   BorderRadius.all(Radius.circular(14)),
//                                   borderSide: BorderSide(
//                                       color: Colors.deepPurpleAccent),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(height: 24),
//                             ElevatedButton(
//                               onPressed: _sendOtp,
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.blue,
//                                 padding:
//                                 const EdgeInsets.symmetric(vertical: 16),
//                                 minimumSize: const Size(double.infinity, 50),
//                               ),
//                               child: const Text(
//                                 "Verify OTP",
//                                 style: TextStyle(fontSize: 16, color: Colors.white),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/services/auth_service.dart';
import 'otp_page.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {

  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();

  bool loading = false;

  Future<void> _sendOtp() async {

    final mobile = _phoneCtrl.text.trim();

    if (mobile.isEmpty || mobile.length != 10) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Enter a valid 10-digit phone number"),
        ),
      );

      return;
    }

    final auth = Provider.of<AuthService>(context, listen: false);

    setState(() {
      loading = true;
    });

    try {

      final res = await auth.forgotPassword(
        mobile: "+91$mobile",
      );

      setState(() {
        loading = false;
      });

      if (res["status"] == "success") {

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OtpPage(
              phone: mobile,
            ),
          ),
        );

      } else {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res["message"] ?? "Failed to send OTP"),
          ),
        );

      }

    } catch (e) {

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
        ),
      );

    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Stack(
        children: [

          // Background
          SizedBox.expand(
            child: Image.asset(
              "assets/images/background.png",
              fit: BoxFit.cover,
            ),
          ),

          // Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),

              child: Column(
                children: [

                  // Avatar
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage:
                    AssetImage("assets/images/user.png"),
                  ),

                  const SizedBox(height: 20),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(22),

                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 15,
                        sigmaY: 15,
                      ),

                      child: Container(
                        padding: const EdgeInsets.all(20),

                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.25),
                          ),
                        ),

                        child: Column(
                          children: [

                            // PHONE FIELD
                            TextField(
                              controller: _phoneCtrl,
                              keyboardType: TextInputType.phone,
                              style: const TextStyle(color: Colors.white),

                              decoration: InputDecoration(
                                labelText: "Phone Number",
                                labelStyle:
                                const TextStyle(color: Colors.white70),
                                prefixIcon: const Icon(
                                  Icons.phone,
                                  color: Colors.white,
                                ),
                                filled: true,
                                fillColor:
                                Colors.white.withOpacity(0.05),

                                enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                  BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                    color:
                                    Colors.white.withOpacity(0.3),
                                  ),
                                ),

                                focusedBorder:
                                const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(14),
                                  ),
                                  borderSide: BorderSide(
                                    color: Colors.deepPurpleAccent,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // NEW PASSWORD
                            TextField(
                              controller: _passwordCtrl,
                              obscureText: true,
                              style: const TextStyle(color: Colors.white),

                              decoration: InputDecoration(
                                labelText: "New Password",
                                labelStyle:
                                const TextStyle(color: Colors.white70),
                                prefixIcon: const Icon(
                                  Icons.lock,
                                  color: Colors.white,
                                ),
                                filled: true,
                                fillColor:
                                Colors.white.withOpacity(0.05),

                                enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                  BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                    color:
                                    Colors.white.withOpacity(0.3),
                                  ),
                                ),

                                focusedBorder:
                                const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(14),
                                  ),
                                  borderSide: BorderSide(
                                    color: Colors.deepPurpleAccent,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            ElevatedButton(
                              onPressed:
                              loading ? null : _sendOtp,

                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                padding:
                                const EdgeInsets.symmetric(
                                    vertical: 16),
                                minimumSize:
                                const Size(double.infinity, 50),
                              ),

                              child: loading
                                  ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                                  : const Text(
                                "Verify OTP",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
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
        ],
      ),
    );
  }
}