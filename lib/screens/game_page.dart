// // import 'dart:async';
// // import 'dart:convert';
// // import 'package:flutter/material.dart';
// // import 'package:http/http.dart' as http;
// //
// // class GamePage extends StatefulWidget {
// //   const GamePage({super.key});
// //
// //   @override
// //   State<GamePage> createState() => _GamePageState();
// // }
// //
// // class _GamePageState extends State<GamePage>
// //     with SingleTickerProviderStateMixin {
// //
// //   // 🔴 IMPORTANT: nullable controller (NO late)
// //   AnimationController? pulseController;
// //
// //   static const String API_BASE =
// //       'https://moneymatrixapp.com/Api/';
// //
// //   String? selectedColor;
// //   int selectedAmount = 50;
// //
// //   Map<String, int> livePlayers = {"red": 0, "green": 0, "violet": 0};
// //   Map<String, int> liveAmounts = {"red": 0, "green": 0, "violet": 0};
// //   List<Map<String, dynamic>> liveUsers = [];
// //
// //   int totalPlayers = 0;
// //   int totalAmount = 0;
// //
// //   int countdown = 60;
// //   String gameStatus = "betting";
// //   String? resultColor;
// //
// //   bool hasBet = false;
// //   bool loading = true;
// //
// //   String playerId = "";
//   Timer? pollTimer;
//
//   final List<Map<String, dynamic>> colorOptions = [
//     {"name": "red", "color": Colors.red, "emoji": "🔴"},
//     {"name": "green", "color": Colors.green, "emoji": "🟢"},
//     {"name": "violet", "color": Colors.deepPurple, "emoji": "🟣"},
//   ];
//
//   // ================= INIT =================
//   @override
//   void initState() {
//     super.initState();
//
//     playerId = "player_${DateTime.now().millisecondsSinceEpoch}";
//
//     pulseController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 900),
//     )..repeat(reverse: true);
//
//     _fetchGameState();
//     pollTimer =
//         Timer.periodic(const Duration(seconds: 1), (_) => _fetchGameState());
//   }
//
//   // ================= DISPOSE =================
//   @override
//   void dispose() {
//     pulseController?.dispose();
//     pollTimer?.cancel();
//     super.dispose();
//   }
//
//   // ================= HELPERS =================
//   int _toInt(dynamic v) {
//     if (v == null) return 0;
//     if (v is int) return v;
//     if (v is double) return v.round();
//     if (v is String) return int.tryParse(v) ?? 0;
//     return 0;
//   }
//
//   // ================= API =================
//   Future<void> _fetchGameState() async {
//     try {
//       final res = await http.get(
//         Uri.parse('$API_BASE/game_status.php?player_id=$playerId'),
//       );
//
//       if (res.statusCode != 200) return;
//
//       final data = jsonDecode(res.body);
//       if (!mounted) return;
//
//       setState(() {
//         gameStatus = data['status'] ?? 'betting';
//         resultColor = data['winner_color'];
//
//         final bets = data['bets_count'] ?? {};
//         final totals = data['amount_totals'] ?? {};
//
//         livePlayers["red"] = _toInt(bets["red"]);
//         livePlayers["green"] = _toInt(bets["green"]);
//         livePlayers["violet"] = _toInt(bets["violet"]);
//
//         liveAmounts["red"] = _toInt(totals["red"]);
//         liveAmounts["green"] = _toInt(totals["green"]);
//         liveAmounts["violet"] = _toInt(totals["violet"]);
//
//         totalPlayers =
//             livePlayers.values.fold(0, (a, b) => a + b);
//         totalAmount =
//             liveAmounts.values.fold(0, (a, b) => a + b);
//
//         final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
//         countdown = gameStatus == 'betting'
//             ? _toInt(data['end_time']) - now
//             : 0;
//         if (countdown < 0) countdown = 0;
//
//         liveUsers = List<Map<String, dynamic>>.from(
//           (data['players'] ?? []) as List,
//         );
//
//         final userBet = data['user_bet'];
//         if (userBet != null) {
//           selectedColor = userBet['color'];
//           selectedAmount = _toInt(userBet['amount']);
//           hasBet = true;
//         }
//
//         loading = false;
//       });
//     } catch (_) {}
//   }
//
//   Future<void> _placeBet() async {
//     if (selectedColor == null ||
//         hasBet ||
//         loading ||
//         gameStatus != 'betting') return;
//
//     setState(() => loading = true);
//
//     try {
//       final res = await http.post(
//         Uri.parse('$API_BASE/place_bet.php'),
//         body: {
//           'color': selectedColor!,
//           'amount': selectedAmount.toString(),
//           'player_id': playerId,
//           'player_name': 'FlutterPlayer',
//         },
//       );
//
//       final body = jsonDecode(res.body);
//       if (!mounted) return;
//
//       if (body['success'] == true || body['status'] == 'ok') {
//         setState(() => hasBet = true);
//
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Bet placed on $selectedColor")),
//         );
//       }
//     } catch (_) {}
//
//     setState(() => loading = false);
//   }
//
//   // ================= UI =================
//   @override
//   Widget build(BuildContext context) {
//     // ✅ SAFE animation (NO crash)
//     final pulseAnim = pulseController != null
//         ? Tween(begin: 0.9, end: 1.1).animate(pulseController!)
//         : const AlwaysStoppedAnimation(1.0);
//
//     final canBet =
//         gameStatus == 'betting' && !hasBet && selectedColor != null && !loading;
//
//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Color(0xFF0a0022), Color(0xFF050008)],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child: SafeArea(
//           child: Column(
//             children: [
//               const SizedBox(height: 8),
//
//               // HEADER
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: _buildHeader(pulseAnim),
//               ),
//
//               if (resultColor != null)
//                 Padding(
//                   padding:
//                   const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//                   child: _buildResultBox(pulseAnim),
//                 ),
//
//               // CONTENT
//               Expanded(
//                 child: SingleChildScrollView(
//                   padding:
//                   const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//                   child: Column(
//                     children: [
//                       _buildLiveStatsRow(),
//                       const SizedBox(height: 12),
//                       _buildColorButtons(),
//                       const SizedBox(height: 12),
//                       _buildAmountChips(),
//                       const SizedBox(height: 12),
//                       _buildUserList(),
//                       if (gameStatus == 'paused') _buildPausedBanner(),
//                     ],
//                   ),
//                 ),
//               ),
//
//               // BUTTON
//               Padding(
//                 padding:
//                 const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
//                 child: SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: canBet ? _placeBet : null,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.pinkAccent,
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       shape: const StadiumBorder(),
//                     ),
//                     child: loading
//                         ? const CircularProgressIndicator(color: Colors.white)
//                         : Text(
//                       hasBet ? "BET PLACED ✓" : "PLACE BET NOW",
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // ================= WIDGETS =================
//   Widget _buildHeader(Animation<double> pulseAnim) {
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(18),
//         gradient: const LinearGradient(
//           colors: [Color(0xFF5b1fff), Color(0xFFff00c3)],
//         ),
//       ),
//       child: Row(
//         children: [
//           ScaleTransition(
//             scale: pulseAnim,
//             child: CircleAvatar(
//               radius: 32,
//               backgroundColor: Colors.yellow,
//               child: Text(
//                 countdown.toString(),
//                 style: const TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black,
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(width: 14),
//           Expanded(
//             child: Text(
//               "$gameStatus | ₹$totalAmount",
//               style: const TextStyle(color: Colors.white),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildResultBox(Animation<double> pulseAnim) {
//     final color = resultColor == "red"
//         ? Colors.red
//         : resultColor == "green"
//         ? Colors.green
//         : Colors.deepPurple;
//
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(18),
//         color: color,
//       ),
//       child: ScaleTransition(
//         scale: pulseAnim,
//         child: Center(
//           child: Text(
//             "WINNER: ${resultColor!.toUpperCase()}",
//             style: const TextStyle(
//               fontSize: 22,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildLiveStatsRow() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//       children: colorOptions.map((c) {
//         final name = c['name'];
//         return Column(
//           children: [
//             Text(c['emoji'], style: const TextStyle(fontSize: 28)),
//             Text("${livePlayers[name]} players",
//                 style: const TextStyle(color: Colors.white70)),
//             Text("₹${liveAmounts[name]}",
//                 style: const TextStyle(color: Colors.yellowAccent)),
//           ],
//         );
//       }).toList(),
//     );
//   }
//
//   Widget _buildColorButtons() {
//     return Column(
//       children: colorOptions.map((c) {
//         final bool selected = selectedColor == c['name'];
//         return GestureDetector(
//           onTap: () =>
//           gameStatus == 'betting' ? setState(() => selectedColor = c['name']) : null,
//           child: AnimatedContainer(
//             duration: const Duration(milliseconds: 200),
//             margin: const EdgeInsets.symmetric(vertical: 6),
//             height: 80,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(18),
//               color: c['color'],
//               border: Border.all(
//                 color: selected ? Colors.yellowAccent : Colors.transparent,
//                 width: 3,
//               ),
//             ),
//             child: Center(
//               child: Text(c['emoji'], style: const TextStyle(fontSize: 40)),
//             ),
//           ),
//         );
//       }).toList(),
//     );
//   }
//
//   Widget _buildAmountChips() {
//     final amounts = [10, 50, 100, 500, 1000];
//     return Wrap(
//       spacing: 10,
//       children: amounts.map((amt) {
//         return ChoiceChip(
//           label: Text("₹$amt"),
//           selected: selectedAmount == amt,
//           onSelected: (_) => setState(() => selectedAmount = amt),
//         );
//       }).toList(),
//     );
//   }
//
//   Widget _buildUserList() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: liveUsers.map((u) {
//         return Text(
//           "${u['player_name']} → ${u['color']} ₹${u['amount']}",
//           style: const TextStyle(color: Colors.white70, fontSize: 12),
//         );
//       }).toList(),
//     );
//   }
//
//   Widget _buildPausedBanner() {
//     return const Padding(
//       padding: EdgeInsets.all(8),
//       child: Text(
//         "GAME PAUSED",
//         style: TextStyle(color: Colors.redAccent),
//       ),
//     );
//   }
// }
// import 'dart:async';
// import 'package:flutter/material.dart';
//
// class GamePage extends StatefulWidget {
//   const GamePage({super.key});
//
//   @override
//   State<GamePage> createState() => _GamePageState();
// }
//
// class _GamePageState extends State<GamePage>
//     with SingleTickerProviderStateMixin {
//
//   // TIMER
//   int seconds = 30;
//   Timer? timer;
//
//   // WALLET
//   double walletBalance = 5000;
//
//   // BET
//   String? selectedColor;
//   int selectedAmount = 10;
//
//   // TIMER ANIMATION
//   late AnimationController controller;
//
//   List<Color> resultHistory = [
//     Colors.red,
//     Colors.green,
//     Colors.purple,
//     Colors.red,
//     Colors.red,
//     Colors.green,
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//
//     controller = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 15),
//     );
//
//     startTimer();
//   }
//
//   void startTimer() {
//
//     controller.forward(from: 0);
//
//     timer = Timer.periodic(const Duration(seconds: 1), (t) {
//
//       if (seconds > 0) {
//         setState(() {
//           seconds--;
//         });
//       } else {
//
//         // round finished
//         seconds = 15;
//         controller.forward(from: 0);
//
//         // add random result
//         resultHistory.insert(0,
//             [Colors.red, Colors.green, Colors.purple]
//             [DateTime.now().millisecond % 3]);
//
//         if (resultHistory.length > 8) {
//           resultHistory.removeLast();
//         }
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     timer?.cancel();
//     controller.dispose();
//     super.dispose();
//   }
//
//   // PLACE BET FUNCTION
//   void placeBet() {
//
//     if (selectedColor == null) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(const SnackBar(content: Text("Select a color")));
//       return;
//     }
//
//     if (walletBalance < selectedAmount) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(const SnackBar(content: Text("Insufficient balance")));
//       return;
//     }
//
//     setState(() {
//       walletBalance -= selectedAmount;
//     });
//
//     ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Bet placed on $selectedColor")));
//   }
//
//   // COLOR CARD
//   Widget colorCard(String name, Color color, int players, int pool) {
//
//     bool selected = selectedColor == name;
//
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           selectedColor = name;
//         });
//       },
//       child: Container(
//         width: 110,
//         padding: const EdgeInsets.all(15),
//         decoration: BoxDecoration(
//           color: Colors.black,
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(color: color, width: selected ? 3 : 1),
//           boxShadow: [
//             BoxShadow(
//               color: color.withOpacity(0.7),
//               blurRadius: 15,
//             )
//           ],
//         ),
//         child: Column(
//           children: [
//             Text(name.toUpperCase(),
//                 style: TextStyle(
//                     color: color,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 18)),
//
//             const SizedBox(height: 8),
//
//             Text("Players:", style: TextStyle(color: Colors.white54)),
//             Text("$players",
//                 style: const TextStyle(color: Colors.white)),
//
//             const SizedBox(height: 6),
//
//             Text("Pool:", style: TextStyle(color: Colors.white54)),
//             Text("₹$pool",
//                 style: const TextStyle(
//                     color: Colors.white, fontWeight: FontWeight.bold)),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // BET CHIPS
//   Widget chip(int amount) {
//
//     bool selected = selectedAmount == amount;
//
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           selectedAmount = amount;
//         });
//       },
//       child: Container(
//         width: 70,
//         height: 70,
//         alignment: Alignment.center,
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           gradient: selected
//               ? const LinearGradient(
//               colors: [Colors.cyan, Colors.purple])
//               : null,
//           border: Border.all(color: Colors.white24),
//         ),
//         child: Text(
//           "₹$amount",
//           style: const TextStyle(color: Colors.white),
//         ),
//       ),
//     );
//   }
//
//   // TIMER UI
//   Widget buildTimer() {
//
//     return Stack(
//       alignment: Alignment.center,
//       children: [
//
//         SizedBox(
//           width: 150,
//           height: 150,
//           child: AnimatedBuilder(
//             animation: controller,
//             builder: (context, child) {
//               return CircularProgressIndicator(
//                 value: 1 - controller.value,
//                 strokeWidth: 8,
//                 backgroundColor: Colors.white12,
//                 valueColor: const AlwaysStoppedAnimation(
//                     Colors.orangeAccent),
//               );
//             },
//           ),
//         ),
//
//         Column(
//           children: [
//             Text(
//               "00:${seconds.toString().padLeft(2, "0")}",
//               style: const TextStyle(
//                   fontSize: 34,
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold),
//             ),
//             const Text("Next Round in",
//                 style: TextStyle(color: Colors.white54))
//           ],
//         )
//       ],
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//
//     return Scaffold(
//       backgroundColor: const Color(0xFF060012),
//
//       body: SafeArea(
//         child: Column(
//           children: [
//
//             const SizedBox(height: 20),
//
//             // TIMER
//             buildTimer(),
//
//             const SizedBox(height: 15),
//
//             // WALLET
//             Text("Wallet Balance",
//                 style: TextStyle(color: Colors.white54)),
//
//             Text("₹$walletBalance",
//                 style: const TextStyle(
//                     color: Colors.cyanAccent,
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold)),
//
//             const SizedBox(height: 20),
//
//             // RESULT HISTORY
//             Container(
//               height: 40,
//               margin: const EdgeInsets.symmetric(horizontal: 30),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(20),
//                 border: Border.all(color: Colors.cyanAccent),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: resultHistory.map((c) {
//                   return CircleAvatar(radius: 6, backgroundColor: c);
//                 }).toList(),
//               ),
//             ),
//
//             const SizedBox(height: 25),
//
//             // COLOR BET
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 colorCard("Red", Colors.red, 145, 14500),
//                 colorCard("Green", Colors.green, 89, 8900),
//                 colorCard("Purple", Colors.purple, 210, 21000),
//               ],
//             ),
//
//             const SizedBox(height: 30),
//
//             // BET AMOUNTS
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 chip(10),
//                 chip(50),
//                 chip(100),
//                 chip(500),
//               ],
//             ),
//
//             const Spacer(),
//
//             // PLACE BET BUTTON
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               child: Container(
//                 height: 55,
//                 decoration: BoxDecoration(
//                   gradient: const LinearGradient(
//                       colors: [Colors.cyan, Colors.purple]),
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//                 child: MaterialButton(
//                   onPressed: placeBet,
//                   child: const Text(
//                     "PLACE BET",
//                     style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold),
//                   ),
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 20)
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:async';
import 'package:flutter/material.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage>
    with SingleTickerProviderStateMixin {

  int seconds = 59;
  Timer? timer;

  double walletBalance = 5000;

  String? selectedColor;
  int selectedAmount = 10;

  bool roundEnded = false;
  String? winnerColor;

  late AnimationController controller;

  List<Color> resultHistory = [
    Colors.red,
    Colors.green,
    Colors.purple,
    Colors.red,
    Colors.green,
  ];

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 59),
    );

    startTimer();
  }

  void startTimer() {

    controller.forward(from: 0);

    timer = Timer.periodic(const Duration(seconds: 1), (t) {

      if (seconds > 0) {

        setState(() {
          seconds--;
        });

      } else {

        List<String> colors = ["Red", "Green", "Purple"];
        winnerColor = colors[DateTime.now().millisecond % 3];

        roundEnded = true;

        Color winColor = winnerColor == "Red"
            ? Colors.red
            : winnerColor == "Green"
            ? Colors.green
            : Colors.purple;

        resultHistory.insert(0, winColor);

        if (resultHistory.length > 8) {
          resultHistory.removeLast();
        }

        setState(() {});

        Future.delayed(const Duration(seconds: 3), () {

          setState(() {
            seconds = 59;
            roundEnded = false;
            winnerColor = null;
            selectedColor = null;
          });

          controller.forward(from: 0);

        });
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    controller.dispose();
    super.dispose();
  }

  void placeBet() {

    if(roundEnded){
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Round finished")));
      return;
    }

    if(selectedColor == null){
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Select a color")));
      return;
    }

    if(walletBalance < selectedAmount){
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Insufficient balance")));
      return;
    }

    setState(() {
      walletBalance -= selectedAmount;
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Bet placed on $selectedColor")));
  }

  Widget buildTimer() {

    return Stack(
      alignment: Alignment.center,
      children: [

        SizedBox(
          width: 150,
          height: 150,
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              return CircularProgressIndicator(
                value: 1 - controller.value,
                strokeWidth: 8,
                backgroundColor: Colors.white12,
                valueColor:
                const AlwaysStoppedAnimation(Colors.orangeAccent),
              );
            },
          ),
        ),

        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "00:${seconds.toString().padLeft(2, "0")}",
              style: const TextStyle(
                  fontSize: 32,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
            const Text(
              "Next Round",
              style: TextStyle(color: Colors.white54),
            )
          ],
        )
      ],
    );
  }

  Widget colorCard(String name, Color color, int players, int pool) {

    bool selected = selectedColor == name;

    return GestureDetector(
      onTap: (){
        if(!roundEnded){
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
          border: Border.all(
              color: color,
              width: selected ? 3 : 1
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.7),
              blurRadius: 15,
            )
          ],
        ),
        child: Column(
          children: [

            Text(
              name,
              style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            const Text("Players",
                style: TextStyle(color: Colors.white54)),

            Text("$players",
                style: const TextStyle(color: Colors.white)),

            const SizedBox(height: 6),

            const Text("Pool",
                style: TextStyle(color: Colors.white54)),

            Text("₹$pool",
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget chip(int amount) {

    bool selected = selectedAmount == amount;

    return GestureDetector(
      onTap: (){
        if(!roundEnded){
          setState(() {
            selectedAmount = amount;
          });
        }
      },
      child: Container(
        width: 65,
        height: 65,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: selected
              ? const LinearGradient(
              colors: [Colors.cyan, Colors.purple])
              : null,
          border: Border.all(color: Colors.white24),
        ),
        child: Text(
          "₹$amount",
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFF060012),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [

              const SizedBox(height: 20),

              buildTimer(),

              const SizedBox(height: 10),

              if(roundEnded && winnerColor != null)
                Container(
                  margin: const EdgeInsets.only(top: 5),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 15, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.yellow),
                  ),
                  child: Text(
                    "WINNER : $winnerColor",
                    style: const TextStyle(
                        color: Colors.yellow,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ),

              const SizedBox(height: 10),

              const Text("Wallet Balance",
                  style: TextStyle(color: Colors.white54)),

              Text(
                "₹$walletBalance",
                style: const TextStyle(
                    color: Colors.cyanAccent,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              Container(
                height: 40,
                margin: const EdgeInsets.symmetric(horizontal: 30),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.cyanAccent),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: resultHistory.map((c) {
                    return CircleAvatar(
                      radius: 6,
                      backgroundColor: c,
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 25),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  colorCard("Red", Colors.red, 145, 14500),
                  colorCard("Green", Colors.green, 89, 8900),
                  colorCard("Purple", Colors.purple, 210, 21000),
                ],
              ),

              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  chip(10),
                  chip(50),
                  chip(100),
                  chip(500),
                ],
              ),

              const SizedBox(height: 40),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 55,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.cyan, Colors.purple],
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: MaterialButton(
                    onPressed: placeBet,
                    child: const Text(
                      "PLACE BET",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

            ],
          ),
        ),
      ),
    );
  }
}