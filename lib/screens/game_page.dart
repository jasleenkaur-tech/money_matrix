import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  String? selectedColor;
  double selectedAmount = 10;

  void _showNotification(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.blue.withOpacity(0.8),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);

    // 🔔 Listen for notifications from the provider
    if (game.lastNotification != null) {
      _showNotification(game.lastNotification!);
      game.clearNotification();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF060012),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              buildTimer(game),
              const SizedBox(height: 10),

              // 🏆 WINNER DISPLAY (Shows only in waiting phase)
              if (game.currentRound?.result != null && game.roundStatus == 'waiting')
                winnerDisplay(game.currentRound!.result!),

              const SizedBox(height: 10),

              // 💰 WALLET (Updated live from curret-wallet, bet-placed, bet-result)
              walletBalanceDisplay(game.userBalance, game.lockedBalance),

              const SizedBox(height: 10),

              // 🔥 USER RESULT BOX (Win / Loss message)
              if (game.lastBetResult != null)
                resultBox(game.lastBetResult!),

              const SizedBox(height: 20),
              const Text("Real-time Betting", style: TextStyle(color: Colors.white54)),
              const SizedBox(height: 10),

              colorCards(game),

              const SizedBox(height: 30),
              chipSelection(),

              const SizedBox(height: 40),
              placeBetButton(game),

              if (game.error != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(game.error!,
                      style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ⏱ TIMER UI
  Widget buildTimer(GameProvider game) {
    double seconds = game.remainingMs / 1000;
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: CircularProgressIndicator(
                value: (seconds % 60) / 60,
                strokeWidth: 6,
                backgroundColor: Colors.white12,
                valueColor: const AlwaysStoppedAnimation(Colors.orangeAccent),
              ),
            ),
            Text(
              "00:${seconds.toInt().toString().padLeft(2, '0')}",
              style: const TextStyle(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          game.roundStatus.toUpperCase(),
          style: const TextStyle(color: Colors.white54, letterSpacing: 1.2),
        )
      ],
    );
  }

  // 🏆 WINNER UI
  Widget winnerDisplay(String color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.yellow),
      ),
      child: Text(
        "WINNER: ${color.toUpperCase()}",
        style: const TextStyle(
            color: Colors.yellow,
            fontSize: 18,
            fontWeight: FontWeight.bold),
      ),
    );
  }

  // 💰 WALLET UI
  Widget walletBalanceDisplay(double balance, double locked) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              const Text("Available", style: TextStyle(color: Colors.white54, fontSize: 12)),
              Text("₹${balance.toStringAsFixed(2)}", 
                style: const TextStyle(color: Colors.cyanAccent, fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          Container(width: 1, height: 30, color: Colors.white10),
          Column(
            children: [
              const Text("Locked", style: TextStyle(color: Colors.white54, fontSize: 12)),
              Text("₹${locked.toStringAsFixed(2)}", 
                style: const TextStyle(color: Colors.orangeAccent, fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  // 🔥 RESULT BOX
  Widget resultBox(Map<String, dynamic> result) {
    bool isWin = result['status'] == 'won';
    double amount = (result['winAmount'] ?? 0).toDouble();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isWin ? Colors.blue.withOpacity(0.2) : Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: isWin ? Colors.blue : Colors.red),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(isWin ? Icons.stars : Icons.info_outline, color: isWin ? Colors.blue : Colors.red),
          const SizedBox(width: 10),
          Text(
            isWin ? "WIN: ₹$amount 🎉" : "BET LOST ❌",
            style: TextStyle(
                color: isWin ? Colors.blue : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 16),
          ),
        ],
      ),
    );
  }

  // 🎨 COLOR CARDS
  Widget colorCards(GameProvider game) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        colorCard("red", Colors.red, game),
        colorCard("blue", Colors.blue, game),
        colorCard("violet", Colors.purple, game),
      ],
    );
  }

  Widget colorCard(String name, Color color, GameProvider game) {
    bool selected = selectedColor == name;
    double pool = 0;
    if (name == 'red') pool = game.currentRound?.totalRed ?? 0;
    if (name == 'blue') pool = game.currentRound?.totalBlue ?? 0;
    if (name == 'violet') pool = game.currentRound?.totalViolet ?? 0;

    return GestureDetector(
      onTap: () {
        if (game.isBettingOpen) {
          setState(() => selectedColor = name);
        }
      },
      child: Container(
        width: 105,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(color: color, width: selected ? 3 : 1),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            if (selected) BoxShadow(color: color.withOpacity(0.4), blurRadius: 10)
          ],
        ),
        child: Column(
          children: [
            Text(name.toUpperCase(),
                style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text("₹${pool.toInt()}",
                style: const TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  // 💸 CHIPS
  Widget chipSelection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [10, 50, 100, 500].map((amt) => chip(amt.toDouble())).toList(),
    );
  }

  Widget chip(double amount) {
    bool selected = selectedAmount == amount;
    return GestureDetector(
      onTap: () => setState(() => selectedAmount = amount),
      child: Container(
        width: 55,
        height: 55,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? Colors.blue : Colors.white10,
          border: Border.all(color: selected ? Colors.cyanAccent : Colors.white24),
        ),
        child: Text("₹${amount.toInt()}",
            style: TextStyle(
                color: selected ? Colors.white : Colors.white70,
                fontWeight: FontWeight.bold)),
      ),
    );
  }

  // 🎯 PLACE BET
  Widget placeBetButton(GameProvider game) {
    bool active = game.isBettingOpen && selectedColor != null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            disabledBackgroundColor: Colors.white10,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          ),
          onPressed: active ? () {
            game.placeBet(selectedColor!, selectedAmount);
          } : null,
          child: const Text("PLACE BET",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
        ),
      ),
    );
  }
}
