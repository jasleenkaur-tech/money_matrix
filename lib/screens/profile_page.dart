import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/services/auth_service.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);

    return Scaffold(
      body: Stack(
        children: [

          // ===== PURPLE OVERLAY =====
          Container(
            color: Colors.deepPurple.withOpacity(0.7),
          ),

          // ===== PAGE CONTENT =====
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  children: [
                    const SizedBox(height: 10),

                    // ===== PROFILE CARD =====
                    Card(
                      color: Colors.white,
                      elevation: 12,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(25),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [

                            // ===== PROFILE IMAGE =====
                            const CircleAvatar(
                              radius: 55,
                              backgroundImage:
                              AssetImage("assets/images/logo_app.jpeg"),
                            ),

                            const SizedBox(height: 18),

                            // ===== NAME =====
                            Text(
                              auth.name ?? "User",
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),

                            const SizedBox(height: 6),

                            // ===== USER ID =====
                            Text(
                              "ID: ${auth.userId ?? "Not Available"}",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey[700],
                              ),
                            ),

                            const SizedBox(height: 25),

                            // ===== INFO ROWS =====
                            _infoRow(Icons.phone, auth.userId ?? "Mobile not set"),
                            _infoRow(Icons.cake, "DOB not available"),
                            _infoRow(Icons.star, "Level 1 Player"),
                            _infoRow(Icons.military_tech, "0 Wins"),

                            const SizedBox(height: 25),

                            // ===== EDIT PROFILE BUTTON =====
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const EditProfilePage(),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.edit,color: Colors.white,),
                                label: const Text(
                                  "Edit Profile",
                                  style: TextStyle(fontSize: 18,color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===== INFO ROW WIDGET =====
  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepPurple, size: 28),
          const SizedBox(width: 18),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}