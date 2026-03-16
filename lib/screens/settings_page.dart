// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '/services/auth_service.dart';
// import 'auth/login_page.dart';
//
// class SettingsPage extends StatelessWidget {
//   const SettingsPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final auth = Provider.of<AuthService>(context);
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//
//     return Stack(
//       children: [
//
//         // ===== BACKGROUND IMAGE =====
//         Container(
//           decoration: const BoxDecoration(
//             image: DecorationImage(
//               image: AssetImage("assets/images/settingback.png"),
//               fit: BoxFit.cover,
//             ),
//           ),
//         ),
//
//         // ===== DARK OVERLAY =====
//         Container(
//           color: Colors.black.withOpacity(0.4),
//         ),
//
//         // ===== SETTINGS LIST BELOW APP BAR =====
//         ListView(
//           padding: const EdgeInsets.fromLTRB(20, 120, 20, 20),
//           children: [
//
//             Card(
//               child: ListTile(
//                 leading: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
//                 title: const Text("Dark Mode"),
//                 trailing: Switch(
//                   value: isDark,
//                   onChanged: (v) {},
//                 ),
//               ),
//             ),
//
//             Card(
//               child: const ListTile(
//                 leading: Icon(Icons.notifications),
//                 title: Text("Notifications"),
//                 trailing: Switch(
//                   value: true,
//                   onChanged: null,
//                 ),
//               ),
//             ),
//
//             Card(
//               child: const ListTile(
//                 leading: Icon(Icons.language),
//                 title: Text("Language"),
//                 trailing: Text("English"),
//               ),
//             ),
//
//             Card(
//               child: ListTile(
//                 leading: const Icon(Icons.privacy_tip),
//                 title: const Text("Privacy Policy"),
//                 onTap: () {},
//               ),
//             ),
//
//             Card(
//               child: ListTile(
//                 leading: const Icon(Icons.info),
//                 title: const Text("About App"),
//                 onTap: () {},
//               ),
//             ),
//
//             const SizedBox(height: 20),
//
//             // ===== LOGOUT BUTTON =====
//             ElevatedButton.icon(
//               onPressed: () async {
//                 await auth.logout();
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(builder: (_) => LoginPage()),
//                 );
//               },
//               icon: const Icon(Icons.logout),
//               label: const Text("Logout"),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.blue,
//                 padding: const EdgeInsets.symmetric(vertical: 14),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/services/auth_service.dart';
import 'auth/login_page.dart';
import 'privacy_policy_page.dart';
import 'about_app_page.dart';

// ===== PROVIDERS =====
class ThemeProvider with ChangeNotifier {
  bool _isDark = false;
  bool get isDark => _isDark;

  void toggleTheme(bool value) {
    _isDark = value;
    notifyListeners();
  }
}

class NotificationProvider with ChangeNotifier {
  bool _enabled = true;
  bool get enabled => _enabled;

  void toggleNotification(bool value) {
    _enabled = value;
    notifyListeners();
  }
}

// ===== SETTINGS PAGE =====
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final notifProvider = Provider.of<NotificationProvider>(context);

    String currentLanguage = "English"; // Default language

    return Scaffold(
      body: Stack(
        children: [
          // ===== BACKGROUND IMAGE =====
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/settingback.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // ===== DARK OVERLAY =====
          Container(
            color: Colors.black.withOpacity(0.4),
          ),

          // ===== SETTINGS LIST =====
          ListView(
            padding: const EdgeInsets.fromLTRB(20, 120, 20, 20),
            children: [
              // ===== DARK MODE =====
              Card(
                child: ListTile(
                  leading: Icon(
                      themeProvider.isDark ? Icons.dark_mode : Icons.light_mode),
                  title: const Text("Dark Mode"),
                  trailing: Switch(
                    value: themeProvider.isDark,
                    onChanged: (v) => themeProvider.toggleTheme(v),
                  ),
                ),
              ),

              // ===== NOTIFICATIONS =====
              Card(
                child: ListTile(
                  leading: const Icon(Icons.notifications),
                  title: const Text("Notifications"),
                  trailing: Switch(
                    value: notifProvider.enabled,
                    onChanged: (v) => notifProvider.toggleNotification(v),
                  ),
                ),
              ),

              // ===== LANGUAGE =====
              Card(
                child: ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text("Language"),
                  trailing: DropdownButton<String>(
                    value: currentLanguage,
                    items: ['English', 'Hindi', 'Punjabi']
                        .map((lang) => DropdownMenuItem(
                      value: lang,
                      child: Text(lang),
                    ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        currentLanguage = val;
                        // TODO: Implement app localization if needed
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Language changed to $val")),
                        );
                      }
                    },
                  ),
                ),
              ),

              // ===== PRIVACY POLICY =====
              Card(
                child: ListTile(
                  leading: const Icon(Icons.privacy_tip),
                  title: const Text("Privacy Policy"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const PrivacyPolicyPage()),
                    );
                  },
                ),
              ),

              // ===== ABOUT APP =====
              Card(
                child: ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text("About App"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AboutAppPage()),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // ===== LOGOUT BUTTON =====
              // ElevatedButton.icon(
              //   onPressed: () async {
              //     await auth.logout();
              //     Navigator.pushReplacement(
              //       context,
              //       MaterialPageRoute(builder: (_) => LoginPage()),
              //     );
              //   },
              //   icon: const Icon(Icons.logout, color: Colors.white),
              //   label: const Text("Logout",
              //     style: TextStyle(
              //       color: Colors.white, // text white
              //       fontSize: 15,
              //       fontWeight: FontWeight.bold,
              //     ),
              //   ),
              //   style: ElevatedButton.styleFrom(
              //     backgroundColor: Colors.blue,
              //     padding: const EdgeInsets.symmetric(vertical: 14),
              //   ),
              // ),

              ElevatedButton.icon(
                onPressed: () {
                  auth.logout();

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                },
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text(
                  "Logout",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}