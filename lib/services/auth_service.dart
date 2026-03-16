// services/auth_service.dart

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'api_service.dart';
//
// class AuthService with ChangeNotifier {
//   String? _token;
//   String? userId;
//   String? name;
//   String? role;
//
//   final _storage = const FlutterSecureStorage();
//
//   bool _isLoading = true;
//   bool get isLoading => _isLoading;
//
//   bool get loggedIn => _token != null;
//   String? get token => _token;
//
//   AuthService() {
//     loadFromStorage(); // Ab public method call ho raha hai
//   }
//
//   // ← YE CHANGE KIYA: _loadFromStorage → loadFromStorage (underscore hata diya)
//   Future<void> loadFromStorage() async {
//     _isLoading = true;
//     notifyListeners();
//
//     try {
//       _token = await _storage.read(key: 'session_token');
//       userId = await _storage.read(key: 'user_id');
//       name = await _storage.read(key: 'name');
//       role = await _storage.read(key: 'role');
//
//       final prefs = await SharedPreferences.getInstance();
//       final lastLoginTimestamp = prefs.getInt('last_login_time');
//
//       if (_token != null && lastLoginTimestamp != null) {
//         final lastLoginDate = DateTime.fromMillisecondsSinceEpoch(lastLoginTimestamp);
//         final now = DateTime.now();
//
//         if (now.difference(lastLoginDate).inHours >= 24) {
//           await logout();
//           _token = null;
//           userId = null;
//           name = null;
//           role = null;
//         }
//       }
//     } catch (e) {
//       print("Error loading from storage: $e");
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
//
//   // ────────────────────── BAKI SAB SAME RAHEGA ──────────────────────
//
//   Future<Map<String, dynamic>> signup({
//     required String name,
//     required String email,
//     required String mobile,
//     required String dob,
//     required String password,
//   }) async {
//     try {
//       final res = await ApiService.post("signup.php", {
//         "name": name,
//         "email": email,
//         "mobile": mobile,
//         "dob": dob,
//         "password": password,
//       });
//       print('Signup Response: $res');
//       return res;
//     } catch (e) {
//       print('Signup Error: $e');
//       return {'status': 'error', 'message': e.toString()};
//     }
//   }
//
//   Future<Map<String, dynamic>> login({
//     required String mobile,
//     required String password,
//   }) async {
//     try {
//       final res = await ApiService.post("login.php", {
//         "mobile": mobile,
//         "password": password,
//       });
//
//       Map<String, dynamic> parsedRes = res;
//
//       if (res['status'] == null && res['raw'] != null) {
//         final rawResponse = res['raw'] as String;
//         final jsonMatch = RegExp(r'\{(?:[^{}]|\{[^{}]*\})*\}').firstMatch(rawResponse);
//         if (jsonMatch != null) {
//           final jsonString = jsonMatch.group(0)!;
//           print('Extracted JSON in login: $jsonString');
//           try {
//             parsedRes = jsonDecode(jsonString) as Map<String, dynamic>;
//           } catch (e) {
//             parsedRes = {
//               'status': 'error',
//               'message': 'Invalid JSON format',
//               'raw': rawResponse,
//             };
//           }
//         }
//       }
//
//       if (parsedRes['status'] == 'success') {
//         _token = parsedRes['session_token'];
//         userId = parsedRes['user_id'];
//         name = parsedRes['name'] ?? '';
//         role = parsedRes['role'] ?? 'user';
//
//         await _storage.write(key: 'session_token', value: _token);
//         await _storage.write(key: 'user_id', value: userId ?? '');
//         await _storage.write(key: 'name', value: name ?? '');
//         await _storage.write(key: 'role', value: role ?? 'user');
//
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setInt('last_login_time', DateTime.now().millisecondsSinceEpoch);
//
//         notifyListeners();
//       }
//
//       return parsedRes;
//     } catch (e) {
//       print('Login Error: $e');
//       return {'status': 'error', 'message': e.toString()};
//     }
//   }
//
//   Future<Map<String, dynamic>> verifyOtp({
//     required String mobile,
//     required String otp,
//   }) async {
//     try {
//       final res = await ApiService.post("verify_login.php", {
//         "mobile": mobile,
//         "otp": otp,
//       });
//
//       if (res["status"] == "success") {
//         _token = res["session_token"];
//         userId = res["user_id"];
//         name = res["name"] ?? "";
//         role = res["role"] ?? "user";
//
//         await _storage.write(key: "session_token", value: _token);
//         await _storage.write(key: "user_id", value: userId ?? "");
//         await _storage.write(key: "name", value: name ?? "");
//         await _storage.write(key: "role", value: role ?? "user");
//
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setInt("last_login_time", DateTime.now().millisecondsSinceEpoch);
//         notifyListeners();
//       }
//       return res;
//     } catch (e) {
//       return {'status': 'error', 'message': e.toString()};
//     }
//   }
//
//   Future<void> logout() async {
//     _token = null;
//     userId = null;
//     name = null;
//     role = null;
//
//     await _storage.deleteAll();
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.clear();
//
//     notifyListeners();
//   }
//   void updateProfile({String? name, String? mobile, String? dob}) {
//     if (name != null) this.name = name;
//     if (mobile != null) userId = mobile;
//     // Save DOB if you want: this.dob = dob;
//
//     notifyListeners();
//   }
//
// }

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
//
// class AuthService extends ChangeNotifier {
//
//   // =============================
//   // BASE API URL
//   // =============================
//   final String baseUrl = "https://your-api-url.com";
//
//   // =============================
//   // USER DATA
//   // =============================
//   String? name;
//   String? userId;
//   String? phone;
//   String? token;
//
//   // =============================
//   // SIGNUP API
//   // =============================
//   Future<Map<String, dynamic>> signup({
//     required String name,
//     required String phone,
//     required String email,
//     required String password,
//     required String dob,
//   }) async {
//
//     final url = Uri.parse("$baseUrl/api/user/signup");
//
//     final res = await http.post(
//       url,
//       headers: {"Content-Type": "application/json"},
//       body: jsonEncode({
//         "name": name,
//         "mobile": phone,
//         "email": email,
//         "password": password,
//         "dob": dob
//       }),
//     );
//
//     return jsonDecode(res.body);
//   }
//
//   // =============================
//   // VERIFY OTP
//   // =============================
//   Future<Map<String, dynamic>> verifyOtp({
//     required String phone,
//     required String otp,
//   }) async {
//
//     final url = Uri.parse("$baseUrl/api/user/verify-otp");
//
//     final res = await http.post(
//       url,
//       headers: {"Content-Type": "application/json"},
//       body: jsonEncode({
//         "mobile": phone,
//         "otp": otp
//       }),
//     );
//
//     final data = jsonDecode(res.body);
//
//     if (data["status"] == "success") {
//
//       name = data["user"]["name"];
//       userId = data["user"]["id"].toString();
//       this.phone = data["user"]["mobile"];
//
//       notifyListeners();
//     }
//
//     return data;
//   }
//
//   // =============================
//   // LOGIN API
//   // =============================
//   Future<Map<String, dynamic>> login({
//     required String phone,
//     required String password,
//   }) async {
//
//     final url = Uri.parse("$baseUrl/api/user/login");
//
//     final res = await http.post(
//       url,
//       headers: {"Content-Type": "application/json"},
//       body: jsonEncode({
//         "mobile": phone,
//         "password": password
//       }),
//     );
//
//     final data = jsonDecode(res.body);
//
//     if (data["status"] == "success") {
//
//       name = data["user"]["name"];
//       userId = data["user"]["id"].toString();
//       this.phone = data["user"]["mobile"];
//
//       notifyListeners();
//     }
//
//     return data;
//   }
//
//   // =============================
//   // FORGOT PASSWORD
//   // =============================
//   Future<Map<String, dynamic>> forgotPassword({
//     required String mobile,
//   }) async {
//
//     final url = Uri.parse("$baseUrl/api/user/forgot-password");
//
//     final res = await http.post(
//       url,
//       headers: {"Content-Type": "application/json"},
//       body: jsonEncode({
//         "mobile": mobile
//       }),
//     );
//
//     return jsonDecode(res.body);
//   }
//
//   // =============================
//   // LOGOUT
//   // =============================
//   Future<void> logout() async {
//
//     name = null;
//     userId = null;
//     phone = null;
//     token = null;
//
//     notifyListeners();
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AuthService extends ChangeNotifier {

  final String baseUrl =  "https://moneymatrix-r3ae.onrender.com";

  String? name;
  String? userId;
  String? phone;
  String? token;

  bool get loggedIn => userId != null;

  Future<void> loadFromStorage() async {}

  // SIGNUP
  Future<Map<String, dynamic>> signup({

    required String name,
    required String phone,
    required String email,
    required String password,
    required String dob,

  }) async {

    final url = Uri.parse("$baseUrl/api/user/signup");

    final res = await http.post(

      url,

      headers: {"Content-Type": "application/json"},

      body: jsonEncode({

        "name": name,
        "mobile": phone,
        "email": email,
        "password": password,
        "dob": dob

      }),

    );

    return jsonDecode(res.body);

  }

  // LOGIN
  Future<Map<String, dynamic>> login({

    required String phone,
    required String password,

  }) async {

    final url = Uri.parse("$baseUrl/api/user/login");

    final res = await http.post(

      url,

      headers: {"Content-Type": "application/json"},

      body: jsonEncode({

        "mobile": phone,
        "password": password

      }),

    );

    final data = jsonDecode(res.body);

    if (data["status"] == "success") {

      name = data["user"]["name"];
      userId = data["user"]["id"].toString();
      phone = data["user"]["mobile"];

      notifyListeners();

    }

    return data;

  }

  // VERIFY OTP
  Future<Map<String, dynamic>> verifyOtp({

    required String phone,
    required String otp,

  }) async {

    final url = Uri.parse("$baseUrl/api/user/verify-otp");

    final res = await http.post(

      url,

      headers: {"Content-Type": "application/json"},

      body: jsonEncode({

        "mobile": phone,
        "otp": otp

      }),

    );

    final data = jsonDecode(res.body);

    if (data["status"] == "success") {

      name = data["user"]["name"];
      userId = data["user"]["id"].toString();
      phone = data["user"]["mobile"];

      notifyListeners();

    }

    return data;

  }

  // FORGOT PASSWORD
  Future<Map<String, dynamic>> forgotPassword({

    required String mobile,

  }) async {

    final url = Uri.parse("$baseUrl/api/user/forgot-password");

    final res = await http.post(

      url,

      headers: {"Content-Type": "application/json"},

      body: jsonEncode({

        "mobile": mobile

      }),

    );

    return jsonDecode(res.body);

  }

  // LOGOUT
  void logout() {

    name = null;
    userId = null;
    phone = null;
    token = null;

    notifyListeners();

  }

}