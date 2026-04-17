import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'edit_profile_page.dart';
import 'auth/login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    // ✅ Fetch latest stats from backend as soon as the profile page is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthService>(context, listen: false).refreshAllData();
    });
  }

  @override
  Widget build(BuildContext context) {
    // 🔄 Automatically rebuilds whenever AuthService calls notifyListeners()
    final auth = Provider.of<AuthService>(context);
    final stats = auth.betInfo;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1a0533), Color(0xFF2d0b6b), Color(0xFF0a0a1a)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          SafeArea(
            child: RefreshIndicator(
              onRefresh: () => auth.refreshAllData(),
              color: Colors.purpleAccent,
              backgroundColor: const Color(0xFF1c1040),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  child: Column(
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "My Profile",
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ===== PROFILE HERO CARD =====
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1c1040),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.deepPurple.withAlpha(128)),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(colors: [Color(0xFFf59e0b), Color(0xFF7c3aed)]),
                              ),
                              child: const CircleAvatar(
                                radius: 52,
                                backgroundImage: AssetImage("assets/images/logo_app.jpeg"),
                                backgroundColor: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              auth.name ?? "User",
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            const SizedBox(height: 6),
                            GestureDetector(
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: auth.userId ?? ""));
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("User ID copied!")));
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.deepPurple.withAlpha(64),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.deepPurple.withAlpha(128)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.tag, color: Colors.purpleAccent, size: 14),
                                    const SizedBox(width: 6),
                                    Text(
                                      auth.userId ?? "Not Available",
                                      style: const TextStyle(fontSize: 12, color: Colors.purpleAccent),
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(Icons.copy, color: Colors.purpleAccent, size: 12),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Divider(color: Colors.white.withAlpha(20), height: 1),
                            const SizedBox(height: 20),
                            _infoTile(icon: Icons.phone_android_rounded, label: "Phone", value: auth.phone ?? "Not set", iconColor: const Color(0xFF22d3ee)),
                            const SizedBox(height: 12),
                            _infoTile(icon: Icons.email_rounded, label: "Email", value: auth.email ?? "Not set", iconColor: const Color(0xFFf59e0b)),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfilePage())),
                                icon: const Icon(Icons.edit_rounded, color: Colors.white, size: 18),
                                label: const Text("Edit Profile", style: TextStyle(fontSize: 16, color: Colors.white)),
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6d28d9), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ===== BETTING STATISTICS GRID (4 Cards) =====
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Game Statistics", style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 10),
                      
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.5,
                        children: [
                          _statCard(
                            icon: Icons.sports_esports,
                            label: "Total Bets",
                            value: "${stats['totalBets'] ?? 0}",
                            color: Colors.blueAccent,
                          ),
                          _statCard(
                            icon: Icons.emoji_events,
                            label: "Wins",
                            value: "${stats['totalWins'] ?? 0}",
                            color: Colors.greenAccent,
                          ),
                          _statCard(
                            icon: Icons.trending_down,
                            label: "Losses",
                            value: "${stats['totalLosses'] ?? 0}",
                            color: Colors.redAccent,
                          ),
                          _statCard(
                            icon: Icons.account_balance_wallet,
                            label: "Balance",
                            value: "₹${auth.balance.toStringAsFixed(1)}",
                            color: const Color(0xFF22d3ee),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // ===== FINANCIAL SUMMARY =====
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1c1040),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.deepPurple.withAlpha(100)),
                        ),
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          children: [
                            _summaryRow("Amount Bet", "₹${stats['totalAmountBet'] ?? 0}", Colors.white70),
                            const SizedBox(height: 12),
                            _summaryRow("Amount Won", "₹${stats['totalAmountWon'] ?? 0}", Colors.greenAccent),
                            const SizedBox(height: 12),
                            _summaryRow("Amount Lost", "₹${stats['totalAmountLost'] ?? 0}", Colors.redAccent),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ===== REFERRAL CARD =====
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1c1040),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.deepPurple.withAlpha(100)),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                        child: Row(
                          children: [
                            Container(
                              width: 44, height: 44,
                              decoration: BoxDecoration(color: Colors.deepPurple.withAlpha(64), borderRadius: BorderRadius.circular(12)),
                              child: const Icon(Icons.card_giftcard_rounded, color: Colors.purpleAccent, size: 22),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Referral Code", style: TextStyle(color: Colors.white70, fontSize: 12)),
                                  const SizedBox(height: 3),
                                  Text(
                                    (auth.userId ?? "N/A").length > 8 ? (auth.userId!).substring(0, 8).toUpperCase() : (auth.userId ?? "N/A").toUpperCase(),
                                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                if (auth.userId != null) {
                                  final code = auth.userId!.length > 8 ? auth.userId!.substring(0, 8) : auth.userId!;
                                  Clipboard.setData(ClipboardData(text: code.toUpperCase()));
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Referral code copied!")));
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(color: Colors.deepPurple.withAlpha(100), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.deepPurple.withAlpha(150))),
                                child: const Text("Copy", style: TextStyle(color: Colors.purpleAccent, fontSize: 13, fontWeight: FontWeight.w500)),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ===== LOGOUT =====
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                backgroundColor: const Color(0xFF1c1040),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                title: const Text("Logout", style: TextStyle(color: Colors.white)),
                                content: const Text("Are you sure?", style: TextStyle(color: Colors.white70)),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel", style: TextStyle(color: Colors.purpleAccent))),
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.pop(ctx);
                                      await auth.logout();
                                      if (context.mounted) {
                                        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginPage()), (route) => false);
                                      }
                                    },
                                    child: const Text("Logout", style: TextStyle(color: Colors.redAccent)),
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 18),
                          label: const Text("Logout", style: TextStyle(color: Colors.redAccent, fontSize: 15, fontWeight: FontWeight.w500)),
                          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), side: BorderSide(color: Colors.redAccent.withAlpha(128)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile({required IconData icon, required String label, required String value, required Color iconColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: Colors.white.withAlpha(13), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white.withAlpha(18))),
      child: Row(
        children: [
          Container(width: 38, height: 38, decoration: BoxDecoration(color: iconColor.withAlpha(38), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: iconColor, size: 20)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)), const SizedBox(height: 2), Text(value, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)])),
        ],
      ),
    );
  }

  Widget _statCard({required IconData icon, required String label, required String value, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF1c1040), borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.deepPurple.withAlpha(100))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        Text(value, style: TextStyle(color: valueColor, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
