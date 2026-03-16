// screens/rewards_page.dart
import 'package:flutter/material.dart';

class RewardsPage extends StatefulWidget {
  const RewardsPage({super.key});

  @override
  State<RewardsPage> createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> with TickerProviderStateMixin {
  late AnimationController _controller;
  int totalCoins = 1250;
  String referralCode = "RAHUL777";

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A0033), Color(0xFF6A1B9A), Colors.black],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [

                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Colors.pink.shade700, Colors.purple.shade800]),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 20, offset: const Offset(0, 10))],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Your Coins", style: TextStyle(fontSize: 18, color: Colors.white70)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Image.asset("assets/images/coin.png", width: 40, height: 40), // Add coin image
                              const SizedBox(width: 10),
                              Text("$totalCoins", style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.yellow)),
                            ],
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, shape: const StadiumBorder()),
                        child: const Text("Withdraw", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Daily Login Reward
                _buildRewardCard(
                  title: "Daily Login Bonus",
                  subtitle: "Claim free coins every day!",
                  icon: Icons.card_giftcard,
                  color: Colors.orange,
                  onTap: () => _showClaimDialog("Daily Login", 50),
                ),

                const SizedBox(height: 16),

                // Refer & Earn
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.purple, width: 2),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.people_alt_rounded, size: 60, color: Colors.pink),
                      const SizedBox(height: 16),
                      const Text("Refer & Earn ₹100", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 8),
                      Text(
                        "Invite friends and earn ₹100 per referral!",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(color: Colors.pink, borderRadius: BorderRadius.circular(30)),
                            child: Text(referralCode, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.share),
                            label: const Text("Share"),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Scratch Card
                _buildRewardCard(
                  title: "Scratch & Win",
                  subtitle: "Win up to ₹500 daily!",
                  icon: Icons.casino,
                  color: Colors.cyan,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScratchCardPage())),
                ),

                const SizedBox(height: 16),

                // Spin Wheel
                _buildRewardCard(
                  title: "Spin The Wheel",
                  subtitle: "Free spin every 2 hours!",
                  icon: Icons.sync,
                  color: Colors.amber,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SpinWheelPage())),
                ),

                const SizedBox(height: 16),

                // Watch Ads
                _buildRewardCard(
                  title: "Watch Ad & Earn",
                  subtitle: "+20 coins per video",
                  icon: Icons.play_circle_fill,
                  color: Colors.red,
                  onTap: () => _showClaimDialog("Watch Ad", 20),
                ),

                const SizedBox(height: 30),

                // History Button
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.history),
                  label: const Text("Reward History", style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade800, padding: const EdgeInsets.symmetric(vertical: 16), minimumSize: const Size(double.infinity, 50)),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRewardCard({required String title, required String subtitle, required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color.withOpacity(0.8), color.withOpacity(0.6)]),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: Row(
          children: [
            RotationTransition(
              turns: _controller,
              child: Icon(icon, size: 50, color: Colors.white),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white),
          ],
        ),
      ),
    );
  }

  void _showClaimDialog(String rewardName, int coins) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.purple.shade900,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Congratulations!", style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset("assets/images/coin_rain.gif", width: 100, height: 100), // Add gif
            const SizedBox(height: 16),
            Text("You won $coins coins!", style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
            Text("From: $rewardName", style: TextStyle(color: Colors.white70)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => totalCoins += coins);
              Navigator.pop(ctx);
            },
            child: const Text("Claim Now", style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// Dummy Pages (Baad mein bana denge)
class ScratchCardPage extends StatelessWidget {
  const ScratchCardPage({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text("Scratch Card Coming Soon!", style: TextStyle(fontSize: 24))));
}

class SpinWheelPage extends StatelessWidget {
  const SpinWheelPage({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text("Spin Wheel Coming Soon!", style: TextStyle(fontSize: 24))));
}