// import 'package:flutter/material.dart';
//
// class WalletPage extends StatefulWidget {
//   @override
//   _WalletPageState createState() => _WalletPageState();
// }
//
// class _WalletPageState extends State<WalletPage> {
//   double btcBalance = 0.00012345; // BTC balance
//   final double btcToInrRate = 8100000; // 1 BTC ≈ ₹81,00,000
//
//   final TextEditingController _addController = TextEditingController();
//   final TextEditingController _withdrawController = TextEditingController();
//
//   @override
//   void dispose() {
//     _addController.dispose();
//     _withdrawController.dispose();
//     super.dispose();
//   }
//
//   double inrToBtc(double inr) => inr / btcToInrRate;
//   double btcToInr(double btc) => btc * btcToInrRate;
//
//   void _addMoney() {
//     final amountText = _addController.text;
//     if (amountText.isEmpty) return;
//
//     final inr = double.tryParse(amountText);
//     if (inr == null || inr <= 0) {
//       _showSnackBar("Enter valid INR amount");
//       return;
//     }
//
//     final btc = inrToBtc(inr);
//     setState(() {
//       btcBalance += btc;
//     });
//
//     _addController.clear();
//     _showSnackBar("₹${inr.toStringAsFixed(2)} added → ${btc.toStringAsFixed(8)} BTC");
//   }
//
//   void _withdrawMoney() {
//     final amountText = _withdrawController.text;
//     if (amountText.isEmpty) return;
//
//     final btc = double.tryParse(amountText);
//     if (btc == null || btc <= 0 || btc > btcBalance) {
//       _showSnackBar("Invalid or insufficient BTC");
//       return;
//     }
//
//     final inr = btcToInr(btc);
//     setState(() {
//       btcBalance -= btc;
//     });
//
//     _withdrawController.clear();
//     _showSnackBar("${btc.toStringAsFixed(8)} BTC withdrawn → ₹${inr.toStringAsFixed(2)}");
//   }
//
//   void _showSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message), backgroundColor: Colors.deepPurple),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final inrBalance = btcToInr(btcBalance);
//
//     return Scaffold(
//       body: Stack(
//         children: [
//           // Background image
//           Container(
//             decoration: BoxDecoration(
//               image: DecorationImage(
//                 image: AssetImage("assets/images/wallet.png"),
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),
//
//           // Purple overlay
//           Container(
//             color: Colors.deepPurple.withOpacity(0.6),
//           ),
//
//           // Main content
//           SafeArea(
//             child: Padding(
//               padding: const EdgeInsets.all(20),
//               child: SingleChildScrollView(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Header with wallet icon
//                     Row(
//                       children: [
//                         Icon(Icons.account_balance_wallet, color: Colors.white, size: 32),
//                         SizedBox(width: 10),
//                         Text(
//                           'Crypto Wallet',
//                           style: TextStyle(
//                             fontSize: 30,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 15),
//                     Text(
//                       'Play games & earn BTC!',
//                       style: TextStyle(fontSize: 14, color: Colors.white70),
//                     ),
//                     SizedBox(height: 40),
//
//                     // Balance Card (Glassmorphism style)
//                     Container(
//                       width: double.infinity,
//                       padding: EdgeInsets.all(20),
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.15),
//                         borderRadius: BorderRadius.circular(20),
//                         border: Border.all(color: Colors.white24),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black26,
//                             blurRadius: 10,
//                             offset: Offset(0, 4),
//                           ),
//                         ],
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Balance',
//                             style: TextStyle(
//                               fontSize: 20,
//                               color: Colors.white70,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                           SizedBox(height: 8),
//                           Row(
//                             children: [
//                               Icon(Icons.currency_bitcoin, color: Colors.orangeAccent, size: 32),
//                               SizedBox(width: 8),
//                               Text(
//                                 '${btcBalance.toStringAsFixed(8)} BTC',
//                                 style: TextStyle(
//                                   fontSize: 26,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.orangeAccent,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           Text(
//                             '≈ ₹${inrBalance.toStringAsFixed(2)}',
//                             style: TextStyle(
//                               fontSize: 18,
//                               color: Colors.white70,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//
//                     SizedBox(height: 40),
//
//                     // Action Buttons
//                     Row(
//                       children: [
//                         Expanded(
//                           child: _buildActionCard(
//                             icon: Icons.add_circle,
//                             label: 'Add Money',
//                             color: Colors.green,
//                             onTap: _showAddDialog,
//                           ),
//                         ),
//                         SizedBox(width: 18),
//                         Expanded(
//                           child: _buildActionCard(
//                             icon: Icons.arrow_upward,
//                             label: 'Withdraw',
//                             color: Colors.redAccent,
//                             onTap: _showWithdrawDialog,
//                           ),
//                         ),
//                       ],
//                     ),
//
//                     SizedBox(height: 40),
//
//                     // Play Game Button
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton.icon(
//                         onPressed: btcBalance > 0
//                             ? () {
//                           if (btcBalance >= 0.00001) {
//                             setState(() {
//                               btcBalance -= 0.00001;
//                             });
//                             _showSnackBar(
//                                 "Entry: 0.00001 BTC deducted. Game started!");
//                           } else {
//                             _showSnackBar("Insufficient BTC to play!");
//                           }
//                         }
//                             : null,
//                         icon: Icon(Icons.videogame_asset,color: Colors.white),
//                         label: Text("Play & Win BTC",
//                           style: TextStyle(
//                             color: Colors.white, // text white
//                             fontSize: 15,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.orangeAccent,
//                           padding: EdgeInsets.symmetric(vertical: 16),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(16),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Action Card Widget
//   Widget _buildActionCard({
//     required IconData icon,
//     required String label,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Colors.white.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(color: Colors.white24),
//         ),
//         child: Column(
//           children: [
//             Icon(icon, color: color, size: 32),
//             SizedBox(height: 8),
//             Text(
//               label,
//               style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // Add Money Dialog
//   void _showAddDialog() {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         backgroundColor: Colors.deepPurple.shade50,
//         title: Text("Add Money (INR)", style: TextStyle(color: Colors.deepPurple)),
//         content: TextField(
//           controller: _addController,
//           keyboardType: TextInputType.number,
//           decoration: InputDecoration(
//             hintText: "Enter INR amount",
//             prefixText: "₹ ",
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//           ),
//         ),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Cancel")),
//           ElevatedButton(
//             onPressed: () {
//               _addMoney();
//               Navigator.pop(ctx);
//             },
//             child: Text("Add"),
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Withdraw Dialog
//   void _showWithdrawDialog() {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         backgroundColor: Colors.deepPurple.shade50,
//         title: Text("Withdraw (BTC → INR)", style: TextStyle(color: Colors.deepPurple)),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text("Available: ${btcBalance.toStringAsFixed(8)} BTC"),
//             SizedBox(height: 10),
//             TextField(
//               controller: _withdrawController,
//               keyboardType: TextInputType.numberWithOptions(decimal: true),
//               decoration: InputDecoration(
//                 hintText: "Enter BTC to withdraw",
//                 prefixIcon: Icon(Icons.currency_bitcoin, color: Colors.orangeAccent),
//                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Cancel")),
//           ElevatedButton(
//             onPressed: () {
//               _withdrawMoney();
//               Navigator.pop(ctx);
//             },
//             child: Text("Withdraw"),
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';

class WalletPage extends StatefulWidget {
  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  double btcBalance = 0.00012345;
  final double btcToInrRate = 8100000;

  final TextEditingController _addController = TextEditingController();
  final TextEditingController _withdrawController = TextEditingController();

  @override
  void dispose() {
    _addController.dispose();
    _withdrawController.dispose();
    super.dispose();
  }

  double inrToBtc(double inr) => inr / btcToInrRate;
  double btcToInr(double btc) => btc * btcToInrRate;

  void _addMoney() {
    final amountText = _addController.text;
    if (amountText.isEmpty) return;
    final inr = double.tryParse(amountText);
    if (inr == null || inr <= 0) {
      _showSnackBar("Enter valid INR amount");
      return;
    }
    final btc = inrToBtc(inr);
    setState(() => btcBalance += btc);
    _addController.clear();
    _showSnackBar("₹${inr.toStringAsFixed(2)} added → ${btc.toStringAsFixed(8)} BTC");
  }

  void _withdrawMoney() {
    final amountText = _withdrawController.text;
    if (amountText.isEmpty) return;
    final btc = double.tryParse(amountText);
    if (btc == null || btc <= 0 || btc > btcBalance) {
      _showSnackBar("Invalid or insufficient BTC");
      return;
    }
    final inr = btcToInr(btc);
    setState(() => btcBalance -= btc);
    _withdrawController.clear();
    _showSnackBar("${btc.toStringAsFixed(8)} BTC withdrawn → ₹${inr.toStringAsFixed(2)}");
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF6C3DE0),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final inrBalance = btcToInr(btcBalance);

    return Scaffold(
      backgroundColor: Color(0xFF2D1B69),
      body: Stack(
        children: [
          // ── Decorative blobs ──
          Positioned(
            top: -40,
            left: -60,
            child: _blob(200, Color(0xFF5B2EBF).withOpacity(0.7)),
          ),
          Positioned(
            top: 80,
            right: -40,
            child: _blob(160, Color(0xFFFF9800).withOpacity(0.25)),
          ),
          Positioned(
            bottom: 200,
            left: -30,
            child: _blob(180, Color(0xFF7C3AED).withOpacity(0.5)),
          ),
          Positioned(
            bottom: 80,
            right: -50,
            child: _blob(140, Color(0xFF5B2EBF).withOpacity(0.4)),
          ),

          // ── Main content ──
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Title row: "Crypto Wallet 👜"
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Crypto Wallet',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text('👜', style: TextStyle(fontSize: 26)),
                    ],
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Play games & earn BTC!',
                    style: TextStyle(fontSize: 14, color: Colors.white60),
                  ),
                  SizedBox(height: 28),

                  // ── Balance Card (glassmorphism) ──
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 28, horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.18)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 20,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Balance',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Ƀ',
                              style: TextStyle(
                                fontSize: 32,
                                color: Color(0xFFFFAA00),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 6),
                            Text(
                              '${btcBalance.toStringAsFixed(8)} BTC',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFFAA00),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          '≈ ₹${inrBalance.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white60,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 28),

                  // ── Add Money / Withdraw Row ──
                  Row(
                    children: [
                      Expanded(
                        child: _actionCard(
                          icon: Icons.add_circle,
                          label: 'Add Money',
                          iconColor: Color(0xFF22C55E),
                          onTap: _showAddDialog,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: _actionCard(
                          icon: Icons.arrow_upward_rounded,
                          label: 'Withdraw',
                          iconColor: Color(0xFFFFAA00),
                          onTap: _showWithdrawDialog,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 28),

                  // ── Play & Win BTC button ──
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton.icon(
                      onPressed: btcBalance > 0
                          ? () {
                        if (btcBalance >= 0.00001) {
                          setState(() => btcBalance -= 0.00001);
                          _showSnackBar(
                              "Entry: 0.00001 BTC deducted. Game started!");
                        } else {
                          _showSnackBar("Insufficient BTC to play!");
                        }
                      }
                          : null,
                      icon: Icon(Icons.videogame_asset_rounded,
                          color: Colors.black87, size: 24),
                      label: Text(
                        'Play & Win BTC',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFFAA00),
                        disabledBackgroundColor:
                        Color(0xFFFFAA00).withOpacity(0.4),
                        elevation: 6,
                        shadowColor: Color(0xFFFFAA00).withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Decorative blob helper
  Widget _blob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }

  // Action card (Add Money / Withdraw)
  Widget _actionCard({
    required IconData icon,
    required String label,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 22, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.10),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 34),
            SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                color: iconColor,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Dialogs ──

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Color(0xFF2D1B69),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Add Money (INR)",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: _addController,
          keyboardType: TextInputType.number,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Enter INR amount",
            hintStyle: TextStyle(color: Colors.white38),
            prefixText: "₹ ",
            prefixStyle: TextStyle(color: Color(0xFFFFAA00)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white24),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFFFFAA00)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Cancel", style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              _addMoney();
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF22C55E),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text("Add", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showWithdrawDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Color(0xFF2D1B69),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Withdraw (BTC → INR)",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Available: ${btcBalance.toStringAsFixed(8)} BTC",
              style: TextStyle(color: Colors.white60, fontSize: 13),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _withdrawController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Enter BTC to withdraw",
                hintStyle: TextStyle(color: Colors.white38),
                prefixIcon:
                Icon(Icons.currency_bitcoin, color: Color(0xFFFFAA00)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white24),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFFFFAA00)),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Cancel", style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              _withdrawMoney();
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFEF4444),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text("Withdraw", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}