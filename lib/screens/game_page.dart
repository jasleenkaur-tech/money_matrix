import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with SingleTickerProviderStateMixin {
  String? selectedColor;
  double selectedAmount = 10;

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF060012),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              buildTimer(game),
              const SizedBox(height: 10),
              if (game.roundStatus == 'waiting' && game.currentRound?.result != null)
                winnerDisplay(game.currentRound!.result!),
              const SizedBox(height: 10),
              walletBalanceDisplay(game.userBalance),
              const SizedBox(height: 20),
              const Text("History", style: TextStyle(color: Colors.white54)),
              const SizedBox(height: 10),
              colorCards(game),
              const SizedBox(height: 30),
              chipSelection(),
              const SizedBox(height: 40),
              placeBetButton(game),
              if (game.error != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(game.error!, style: const TextStyle(color: Colors.blue)),
                ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTimer(GameProvider game) {
    double seconds = game.remainingMs / 1000;
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 150,
          height: 150,
          child: CircularProgressIndicator(
            value: (seconds % 60) / 60,
            strokeWidth: 8,
            backgroundColor: Colors.white12,
            valueColor: const AlwaysStoppedAnimation(Colors.orangeAccent),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "00:${seconds.toInt().toString().padLeft(2, "0")}",
              style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
            ),
            Text(
              game.roundStatus.toUpperCase(),
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            )
          ],
        )
      ],
    );
  }

  Widget winnerDisplay(String color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.yellow),
      ),
      child: Text("WINNER : ${color.toUpperCase()}", style: const TextStyle(color: Colors.yellow, fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget walletBalanceDisplay(double balance) {
    return Column(
      children: [
        const Text("Wallet Balance", style: TextStyle(color: Colors.white54)),
        Text("₹$balance", style: const TextStyle(color: Colors.cyanAccent, fontSize: 24, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget colorCards(GameProvider game) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        colorCard("red", Colors.red, game),
        colorCard("green", Colors.green, game),
        colorCard("violet", Colors.purple, game),
      ],
    );
  }

  Widget colorCard(String name, Color color, GameProvider game) {
    bool selected = selectedColor == name;
    return GestureDetector(
      onTap: () {
        if (game.isBettingOpen) {
          setState(() {
            selectedColor = name;
          });
        }
      },
      child: Container(
        width: 105,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color, width: selected ? 3 : 1),
          boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 15)],
        ),
        child: Column(
          children: [
            Text(name.toUpperCase(), style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text("Pool", style: TextStyle(color: Colors.white54, fontSize: 10)),
            Text("₹${_getPool(name, game)}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  double _getPool(String color, GameProvider game) {
    if (color == 'red') return game.currentRound?.totalRed ?? 0;
    if (color == 'green') return game.currentRound?.totalBlue ?? 0; // Backend says blue/green?
    return game.currentRound?.totalViolet ?? 0;
  }

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
        width: 65, height: 65,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: selected ? const LinearGradient(colors: [Colors.cyan, Colors.purple]) : null,
          border: Border.all(color: Colors.white24),
        ),
        child: Text("₹${amount.toInt()}", style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget placeBetButton(GameProvider game) {
    bool active = game.isBettingOpen && selectedColor != null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 55,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: active ? const LinearGradient(colors: [Colors.cyan, Colors.purple]) : null,
          color: active ? null : Colors.grey.withOpacity(0.2),
          borderRadius: BorderRadius.circular(30),
        ),
        child: MaterialButton(
          onPressed: active ? () => game.placeBet(selectedColor!, selectedAmount) : null,
          child: const Text("PLACE BET", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
