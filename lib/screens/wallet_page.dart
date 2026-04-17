import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '/services/auth_service.dart';

class WalletPage extends StatefulWidget {
  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  bool _loading = false;

  // Supported currencies and country codes for Transak
  final List<Map<String, String>> _currencies = [
    {"code": "INR", "country": "IN", "name": "India 🇮🇳"},
    {"code": "USD", "country": "US", "name": "USA 🇺🇸"},
    {"code": "AUD", "country": "AU", "name": "Australia 🇦🇺"},
    {"code": "GBP", "country": "GB", "name": "UK 🇬🇧"},
    {"code": "EUR", "country": "DE", "name": "Europe 🇪🇺"},
    {"code": "CAD", "country": "CA", "name": "Canada 🇨🇦"},
  ];

  late Map<String, String> _selectedCurrency;

  @override
  void initState() {
    super.initState();
    _selectedCurrency = _currencies[0]; // Default to INR
    // ✅ Refresh balance on mount
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthService>(context, listen: false).getWalletInfo();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Color(0xFF6C3DE0),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleOnRamp() async {
    final amtText = _amountController.text.trim();
    if (amtText.isEmpty) return _showSnackBar("Enter amount", isError: true);
    
    final amt = double.tryParse(amtText);
    if (amt == null || amt <= 0) return _showSnackBar("Enter valid amount", isError: true);

    setState(() => _loading = true);
    final auth = Provider.of<AuthService>(context, listen: false);
    
    try {
      // ✅ Now passing dynamic currency and country code
      final res = await auth.getOnRampUrl(
        amount: amt,
        fiatCurrency: _selectedCurrency["code"]!,
        countryCode: _selectedCurrency["country"]!,
      );
      
      setState(() => _loading = false);

      if (res["success"] == true && res["data"] != null && res["data"]["url"] != null) {
        final url = Uri.parse(res["data"]["url"]);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        } else {
          _showSnackBar("Could not open deposit link", isError: true);
        }
      } else {
        _showSnackBar(res["message"] ?? "Failed to start deposit", isError: true);
      }
    } catch (e) {
      setState(() => _loading = false);
      _showSnackBar("Connection error", isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);

    return Scaffold(
      backgroundColor: Color(0xFF2D1B69),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                children: [
                  const Text('Crypto Wallet 👜', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 6),
                  const Text('Sync with TRX on-chain balance', style: TextStyle(fontSize: 14, color: Colors.white60)),
                  const SizedBox(height: 28),

                  // ── Balance Card ──
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.18)),
                    ),
                    child: Column(
                      children: [
                        const Text('Available Balance', style: TextStyle(color: Colors.white70, fontSize: 16)),
                        const SizedBox(height: 14),
                        Text('${auth.balance.toStringAsFixed(2)} TRX', 
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFFFFAA00))),
                        const SizedBox(height: 8),
                        SelectableText(
                          auth.walletAddress ?? "No address", 
                          style: const TextStyle(fontSize: 11, color: Colors.white38),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Currency Selection Dropdown ──
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<Map<String, String>>(
                        value: _selectedCurrency,
                        dropdownColor: Color(0xFF2D1B69),
                        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
                        isExpanded: true,
                        onChanged: (Map<String, String>? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedCurrency = newValue;
                            });
                          }
                        },
                        items: _currencies.map<DropdownMenuItem<Map<String, String>>>((Map<String, String> value) {
                          return DropdownMenuItem<Map<String, String>>(
                            value: value,
                            child: Text(
                              "${value['name']} (${value['code']})",
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Input Area ──
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Enter Amount",
                      hintStyle: const TextStyle(color: Colors.white38),
                      prefixText: "${_selectedCurrency['code']} ",
                      prefixStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.05),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Colors.white24),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFFFFAA00)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _loading ? null : _handleOnRamp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF22C55E), 
                            minimumSize: const Size(0, 55),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: _loading 
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text("Deposit", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _showSnackBar("Withdrawal coming soon"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFAA00), 
                            minimumSize: const Size(0, 55),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text("Withdraw", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
