import 'package:flutter/material.dart';
import 'analytics_page.dart';
import 'transactions_page.dart';
import 'rewards_page.dart';

class DashboardPage extends StatelessWidget {
  final bool isDark;
  final Function(int) onTabChange;

  const DashboardPage({
    super.key,
    required this.isDark,
    required this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    final bgStart = isDark ? Colors.purple.shade800 : Colors.deepPurple;
    final bgEnd = isDark ? Colors.black : Colors.purple.shade900;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [bgStart, bgEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false, // ✅ IMPORTANT
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: 50)),

            _header(),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            _balanceCard(),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 18,
                  crossAxisSpacing: 18,
                  childAspectRatio: 1.25,
                ),
                delegate: SliverChildListDelegate(
                  [
                    _card(Icons.account_balance_wallet, "Wallet", () => onTabChange(1)),
                    _card(Icons.bar_chart, "Analytics", () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => AnalyticsPage()));
                    }),
                    _card(Icons.sports_esports, "Play Game", () => onTabChange(2)),
                    _card(Icons.card_giftcard, "Rewards", () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const RewardsPage()));
                    }),
                    _card(Icons.swap_horiz, "Transactions", () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => TransactionsPage()));
                    }),
                    _card(Icons.person, "Profile", () => onTabChange(3)),
                  ],
                ),
              ),
            ),

            // ✅ SAFE SPACE (NO OVERFLOW)
            SliverToBoxAdapter(
              child: SizedBox(
                height: MediaQuery.of(context).padding.bottom + 100,
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _header() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text("Welcome Back 👋",
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white)),
        SizedBox(height: 6),
        Text("Play games & earn rewards",
            style: TextStyle(color: Colors.white70)),
      ],
    ),
  );

  Widget _balanceCard() => Container(
    margin: const EdgeInsets.symmetric(horizontal: 20),
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: [Colors.pink, Colors.purple]),
      borderRadius: BorderRadius.circular(28),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        Text("₹ 0",
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white)),
        Icon(Icons.account_balance_wallet, size: 56, color: Colors.white),
      ],
    ),
  );

  Widget _card(IconData icon, String title, VoidCallback onTap) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutBack,
      builder: (_, v, child) => Transform.scale(scale: v, child: child),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Colors.white.withOpacity(0.12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 44, color: Colors.white),
              const SizedBox(height: 12),
              Text(title,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}
