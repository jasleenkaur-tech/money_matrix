import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService extends ChangeNotifier {
  final String baseUrl = "https://delphia-synostotic-fletcher.ngrok-free.dev";
  final _storage = const FlutterSecureStorage();

  String? name;
  String? userId;
  String? phone;
  String? token;
  String? walletAddress;
  String? _cookie; // To store cookies if needed

  bool get loggedIn => userId != null;

  AuthService() {
    _loadToken();
  }

  Future<void> _loadToken() async {
    token = await _storage.read(key: "token");
    userId = await _storage.read(key: "userId");
    name = await _storage.read(key: "name");
    phone = await _storage.read(key: "phone");
    walletAddress = await _storage.read(key: "walletAddress");
    _cookie = await _storage.read(key: "cookie");
    notifyListeners();
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

  // ─────────────────────────────────────────────
  // 🔹 CREATE WALLET (POST /wallet)
  // ─────────────────────────────────────────────
  Future<Map<String, dynamic>> createWallet(String authToken) async {
    try {
      final url = Uri.parse("$baseUrl/api/v1/wallet");
      
      // ✅ Using both Authorization Header and Cookies
      final Map<String, String> headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer $authToken",
      };

      if (_cookie != null) {
        headers["cookie"] = _cookie!;
      }

      final res = await http.post(
        url,
        headers: headers,
      );

      final data = _parseResponse(res.body);
      print("Wallet Response: ${res.body}");

      if (data["success"] == true) {
        walletAddress = data["data"]["wallet"]["address"];
        await _storage.write(key: "walletAddress", value: walletAddress);
        notifyListeners();
      }
      return data;
    } catch (e) {
      return {"status": "error", "message": "Wallet creation failed"};
    }
  }

  Future<Map<String, dynamic>> signup({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    try {
      final url = Uri.parse("$baseUrl/api/v1/users/register");
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "phone": phone,
          "email": email,
          "password": password,
        }),
      );
      return _parseResponse(res.body);
    } catch (e) {
      return {"status": "error", "message": "Connection failed"};
    }
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      final url = Uri.parse("$baseUrl/api/v1/users/verify-otp");
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "phone": phone,
          "otp": otp,
        }),
      );

      // ✅ Capture cookies from response headers
      final String? rawCookie = res.headers['set-cookie'];
      if (rawCookie != null) {
        _cookie = rawCookie;
        await _storage.write(key: "cookie", value: _cookie);
      }

      final data = _parseResponse(res.body);
      if (data["success"] == true) {
        final userData = data["data"]["user"];
        token = data["data"]["accessToken"];
        userId = userData["_id"];
        name = userData["name"];
        this.phone = userData["phone"];

        await _storage.write(key: "token", value: token);
        await _storage.write(key: "userId", value: userId);
        await _storage.write(key: "name", value: name);
        await _storage.write(key: "phone", value: this.phone);

        notifyListeners();
      }
      return data;
    } catch (e) {
      return {"status": "error", "message": "Connection failed"};
    }
  }

  Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
  }) async {
    try {
      final url = Uri.parse("$baseUrl/api/v1/users/login");
      Map<String, String> requestBody = {"password": password};
      if (identifier.contains("@")) {
        requestBody["email"] = identifier;
      } else {
        requestBody["phone"] = identifier;
      }
      
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      // ✅ Also capture cookies on login
      final String? rawCookie = res.headers['set-cookie'];
      if (rawCookie != null) {
        _cookie = rawCookie;
        await _storage.write(key: "cookie", value: _cookie);
      }

      final data = _parseResponse(res.body);
      if (data["success"] == true) {
        final userData = data["data"]["user"];
        token = data["data"]["accessToken"];
        userId = userData["_id"];
        name = userData["name"];
        phone = userData["phone"];

        await _storage.write(key: "token", value: token);
        await _storage.write(key: "userId", value: userId);
        await _storage.write(key: "name", value: name);
        await _storage.write(key: "phone", value: phone);

        notifyListeners();
      }
      return data;
    } catch (e) {
      return {"status": "error", "message": "Connection failed"};
    }
  }

  Future<Map<String, dynamic>> forgotPassword({
    required String phone,
    required String newPassword,
  }) async {
    try {
      final url = Uri.parse("$baseUrl/api/v1/users/forgot-password");
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "phone": phone,
          "newpassword": newPassword,
        }),
      );
      return _parseResponse(res.body);
    } catch (e) {
      return {"status": "error", "message": "Connection failed"};
    }
  }

  Future<Map<String, dynamic>> resetPassword({
    required String phone,
    required String otp,
  }) async {
    try {
      final url = Uri.parse("$baseUrl/api/v1/users/reset-password");
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "phone": phone,
          "otp": otp,
        }),
      );
      return _parseResponse(res.body);
    } catch (e) {
      return {"status": "error", "message": "Connection failed"};
    }
  }

  Future<void> logout() async {
    name = null;
    userId = null;
    phone = null;
    token = null;
    walletAddress = null;
    _cookie = null;
    await _storage.deleteAll();
    notifyListeners();
  }
}
