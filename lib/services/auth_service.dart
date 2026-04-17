import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService extends ChangeNotifier {
  final String baseUrl = "https://delphia-synostotic-fletcher.ngrok-free.dev";
  final _storage = const FlutterSecureStorage();

  String? name;
  String? userId;
  String? phone;
  String? email;
  String? token;
  String? walletAddress;
  double balance = 0.0;
  Map<String, dynamic> betInfo = {};
  String? _cookie;

  bool get loggedIn => userId != null;

  AuthService() {
    _loadToken();
  }

  // ✅ Helper to provide consistent headers across all requests
  Map<String, String> get _headers => {
    "Content-Type": "application/json",
    "Accept": "application/json",
    "ngrok-skip-browser-warning": "true", // 🔥 CRITICAL: Bypasses ngrok warning page
    if (token != null) "Authorization": "Bearer $token",
    if (_cookie != null) "cookie": _cookie!,
  };

  Future<void> _loadToken() async {
    token = await _storage.read(key: "token");
    userId = await _storage.read(key: "userId");
    name = await _storage.read(key: "name");
    phone = await _storage.read(key: "phone");
    email = await _storage.read(key: "email");
    walletAddress = await _storage.read(key: "walletAddress");
    _cookie = await _storage.read(key: "cookie");

    if (token != null) {
      refreshAllData();
    }
    notifyListeners();
  }

  void updateBalance(double newBalance) {
    if (balance != newBalance) {
      balance = newBalance;
      notifyListeners();
    }
  }

  Future<void> refreshAllData() async {
    try {
      // Fetch both but notify only once at the end to prevent flickering
      await Future.wait([
        _getWalletInfoInternal(),
        _getBetInfoInternal(),
      ]);
      notifyListeners();
    } catch (e) {
      debugPrint("Refresh error: $e");
    }
  }

  Map<String, dynamic> _parseResponse(String body) {
    try {
      return jsonDecode(body);
    } catch (e) {
      final jsonMatch = RegExp(r'\{(?:[^{}]|\{[^{}]*\})*\}').firstMatch(body);
      if (jsonMatch != null) {
        try {
          return jsonDecode(jsonMatch.group(0)!);
        } catch (_) {}
      }
      return {"status": "error", "message": "Invalid server response", "raw": body};
    }
  }

  // Internal method for batch refreshing
  Future<void> _getWalletInfoInternal() async {
    if (token == null) return;
    try {
      final res = await http.get(Uri.parse("$baseUrl/api/v1/wallet/info"), headers: _headers);
      final data = _parseResponse(res.body);
      if (data["success"] == true) {
        walletAddress = data["data"]["wallet"]["address"];
        balance = (data["data"]["wallet"]["balance"] ?? 0.0).toDouble();
      }
    } catch (e) { debugPrint("Wallet Internal Error: $e"); }
  }

  // Internal method for batch refreshing
  Future<void> _getBetInfoInternal() async {
    if (token == null) return;
    try {
      final res = await http.get(Uri.parse("$baseUrl/api/v1/wallet/bet-info"), headers: _headers);
      final data = _parseResponse(res.body);
      if (data["success"] == true) {
        betInfo = data["data"]["betInfo"] ?? {};
      }
    } catch (e) { debugPrint("Bet Internal Error: $e"); }
  }

  Future<Map<String, dynamic>> getWalletInfo() async {
    await _getWalletInfoInternal();
    notifyListeners();
    return {"success": true};
  }

  Future<Map<String, dynamic>> getBetInfo() async {
    debugPrint("📡 Fetching real-time bet stats...");
    await _getBetInfoInternal();
    notifyListeners();
    return {"success": true, "data": {"betInfo": betInfo}};
  }

  Future<Map<String, dynamic>> getOnRampUrl({
    required double amount,
    required String countryCode,
    required String fiatCurrency,
  }) async {
    try {
      final url = Uri.parse("$baseUrl/api/v1/ramp/on-ramp");
      final body = jsonEncode({
        "fiatAmount": amount,
        "countryCode": countryCode,
        "fiatCurrency": fiatCurrency,
        "cryptoCurrencyCode": "TRX"
      });

      final res = await http.post(url, headers: _headers, body: body);
      if (res.statusCode == 401) { logout(); return {"success": false, "message": "Session expired"}; }
      return _parseResponse(res.body);
    } catch (e) {
      return {"status": "error", "message": "Connection error"};
    }
  }

  Future<Map<String, dynamic>> createWallet(String authToken) async {
    try {
      final url = Uri.parse("$baseUrl/api/v1/wallet");
      final res = await http.post(url, headers: _headers);
      final data = _parseResponse(res.body);

      if (data["success"] == true) {
        walletAddress = data["data"]["wallet"]["address"];
        await _storage.write(key: "walletAddress", value: walletAddress);
        refreshAllData();
      }
      return data;
    } catch (e) {
      return {"status": "error", "message": "Wallet creation failed"};
    }
  }

  Future<Map<String, dynamic>> signup({required String name, required String phone, required String email, required String password}) async {
    try {
      final url = Uri.parse("$baseUrl/api/v1/users/register");
      final res = await http.post(url, headers: _headers,
        body: jsonEncode({"name": name, "phone": phone, "email": email, "password": password}),
      );
      return _parseResponse(res.body);
    } catch (e) { return {"status": "error", "message": "Connection failed"}; }
  }

  Future<Map<String, dynamic>> verifyOtp({required String phone, required String otp}) async {
    try {
      final url = Uri.parse("$baseUrl/api/v1/users/verify-otp");
      final res = await http.post(url, headers: _headers,
        body: jsonEncode({"phone": phone, "otp": otp}),
      );
      final String? rawCookie = res.headers['set-cookie'];
      if (rawCookie != null) { _cookie = rawCookie; await _storage.write(key: "cookie", value: _cookie); }
      final data = _parseResponse(res.body);
      if (data["success"] == true) {
        final userData = data["data"]["user"];
        token = data["data"]["accessToken"];
        userId = userData["_id"];
        name = userData["name"];
        this.phone = userData["phone"];
        email = userData["email"];
        await _storage.write(key: "token", value: token);
        await _storage.write(key: "userId", value: userId);
        await _storage.write(key: "name", value: name);
        await _storage.write(key: "phone", value: this.phone);
        await _storage.write(key: "email", value: email);
        refreshAllData();
      }
      return data;
    } catch (e) { return {"status": "error", "message": "Connection failed"}; }
  }

  Future<Map<String, dynamic>> login({required String identifier, required String password}) async {
    try {
      final url = Uri.parse("$baseUrl/api/v1/users/login");
      Map<String, String> body = {"password": password};
      identifier.contains("@") ? body["email"] = identifier : body["phone"] = identifier;
      final res = await http.post(url, headers: _headers, body: jsonEncode(body));
      final String? rawCookie = res.headers['set-cookie'];
      if (rawCookie != null) { _cookie = rawCookie; await _storage.write(key: "cookie", value: _cookie); }
      final data = _parseResponse(res.body);
      if (data["success"] == true) {
        final userData = data["data"]["user"];
        token = data["data"]["accessToken"];
        userId = userData["_id"];
        name = userData["name"];
        phone = userData["phone"];
        email = userData["email"];
        await _storage.write(key: "token", value: token);
        await _storage.write(key: "userId", value: userId);
        await _storage.write(key: "name", value: name);
        await _storage.write(key: "phone", value: phone);
        await _storage.write(key: "email", value: email);
        refreshAllData();
      }
      return data;
    } catch (e) { return {"status": "error", "message": "Connection failed"}; }
  }

  Future<Map<String, dynamic>> forgotPassword({required String phone, required String newPassword}) async {
    try {
      final url = Uri.parse("$baseUrl/api/v1/users/forgot-password");
      final res = await http.post(url, headers: _headers,
        body: jsonEncode({"phone": phone, "newpassword": newPassword}),
      );
      return _parseResponse(res.body);
    } catch (e) { return {"status": "error", "message": "Connection failed"}; }
  }

  Future<Map<String, dynamic>> resetPassword({required String phone, required String otp}) async {
    try {
      final url = Uri.parse("$baseUrl/api/v1/users/reset-password");
      final res = await http.post(url, headers: _headers,
        body: jsonEncode({"phone": phone, "otp": otp}),
      );
      return _parseResponse(res.body);
    } catch (e) { return {"status": "error", "message": "Connection failed"}; }
  }

  Future<void> logout() async {
    name = null; userId = null; phone = null; email = null; token = null; walletAddress = null; balance = 0.0; _cookie = null; betInfo = {};
    await _storage.deleteAll();
    notifyListeners();
  }
}
