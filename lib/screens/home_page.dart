import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/services/auth_service.dart';
import 'auth/login_page.dart';

import 'profile_page.dart';
import 'settings_page.dart';
import 'wallet_page.dart';
import 'game_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isDarkMode = true;

  late final AnimationController _fabController;

  final _titles = const [
    "Money Matrix",
    "Wallet",
    "Play Game",
    "Profile",
    "Settings",
  ];

  @override
  void initState() {
    super.initState();
    _loadTheme();

    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? true;
    });
  }

  Future<void> _toggleTheme(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', v);
    setState(() => _isDarkMode = v);
  }

  // ================= DASHBOARD =================
  Widget _buildDashboard() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 50, 16, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Welcome Back 👋",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Play games & earn rewards",
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 40),

            // Balance Card
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  colors: [Colors.pink, Colors.purple.shade700],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Total Balance",
                          style: TextStyle(color: Colors.white70)),
                      SizedBox(height: 6),
                      Text("₹ 0",
                          style: TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Icon(Icons.account_balance_wallet,
                      size: 56, color: Colors.white),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Quick Actions
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              childAspectRatio: 1.25,
              children: [
                _quickCard(
                    Icons.sports_esports, "Play Game", Colors.pink,
                        () => setState(() => _selectedIndex = 2)),
                _quickCard(
                    Icons.account_balance_wallet, "Wallet", Colors.amber,
                        () => setState(() => _selectedIndex = 1)),
                _quickCard(Icons.person, "Profile", Colors.indigo,
                        () => setState(() => _selectedIndex = 3)),
                _quickCard(Icons.settings, "Settings", Colors.green,
                        () => setState(() => _selectedIndex = 4)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickCard(
      IconData icon, String title, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color: Colors.white.withOpacity(0.08),
              border: Border.all(color: Colors.white24),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: color.withOpacity(0.25),
                  child: Icon(icon, color: color, size: 30),
                ),
                const SizedBox(height: 12),
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();

    final pages = [
      _buildDashboard(),
      WalletPage(),
      const GamePage(),
      const ProfilePage(),
      const SettingsPage(),
    ];

    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(_titles[_selectedIndex]),
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/homeback.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            color: Colors.black.withOpacity(0.45), // overlay
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              child: pages[_selectedIndex],
            ),
          ),
        ),
        floatingActionButton: _selectedIndex == 0
            ? ScaleTransition(
          scale: Tween(begin: 0.9, end: 1.15).animate(_fabController),
          child: FloatingActionButton(
            onPressed: () => setState(() => _selectedIndex = 2),
            backgroundColor: Colors.redAccent, // button color
            foregroundColor: Colors.white,
            child: const Icon(Icons.play_arrow, size: 36),
          ),
        )
            : null,
        floatingActionButtonLocation:
        FloatingActionButtonLocation.centerFloat,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (i) => setState(() => _selectedIndex = i),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(
                icon: Icon(Icons.wallet), label: "Wallet"),
            BottomNavigationBarItem(
                icon: Icon(Icons.play_circle), label: "Play"),
            BottomNavigationBarItem(
                icon: Icon(Icons.person), label: "Profile"),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings), label: "Settings"),
          ],
        ),
      ),
    );
  }
}
