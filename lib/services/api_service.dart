// import 'dart:convert';
// import 'package:http/http.dart' as http;
//
// /// Change base URL according to platform
// /// - Android Emulator: http://10.0.2.2/money_matrix
// /// - iOS Simulator: http://localhost/money_matrix
// /// - Real device: http://192.168.1.24/money_matrix
// // const String API_BASE = "https://moneymatrixapp.com/Api";
// const String API_BASE = "http://10.0.2.2:5000/api";
// // const String login = "http://10.0.2.2:5000/api/user/login";
//
// class ApiService {
//   static Future<Map<String, dynamic>> post(
//       String path,
//       Map body, {
//         Map<String, String>? headers,
//       }) async {
//     final url = Uri.parse('$API_BASE/$path');
//     final defaultHeaders = {'Content-Type': 'application/json; charset=UTF-8'};
//     if (headers != null) defaultHeaders.addAll(headers);
//
//     try {
//       final res = await http
//           .post(url, headers: defaultHeaders, body: jsonEncode(body))
//           .timeout(const Duration(seconds: 15));
//
//       // Log the request and response for debugging
//       // print('API Request: POST $url');
//       // print('Request Body: ${jsonEncode(body)}');
//       // print('Response Status: ${res.statusCode}');
//       // print('Response Headers: ${res.headers}');
//       // print('Response Body: ${res.body}');
//
//       // Check if response is JSON
//       final contentType = res.headers['content-type'] ?? '';
//       if (!contentType.contains('application/json')) {
//         return {
//           'status': 'error',
//           'message': 'Invalid response type: $contentType',
//           'raw': res.body,
//         };
//       }
//
//       if (res.statusCode == 200 || res.statusCode == 400) {
//         // Handle malformed response with Twilio message prefix
//         String responseBody = res.body;
//         // Find the start of the JSON (first '{')
//         final jsonStart = responseBody.indexOf('{');
//         if (jsonStart > 0) {
//           // Extract the JSON part
//           responseBody = responseBody.substring(jsonStart);
//           print('Extracted JSON: $responseBody');
//         }
//
//         try {
//           return jsonDecode(responseBody) as Map<String, dynamic>;
//         } catch (e) {
//           return {
//             'status': 'error',
//             'message': 'Invalid JSON response: $e',
//             'raw': res.body,
//           };
//         }
//       } else {
//         return {
//           'status': 'error',
//           'message': 'HTTP ${res.statusCode}',
//           'raw': res.body,
//         };
//       }
//     } catch (e) {
//       print('Network error: $e');
//       return {
//         'status': 'error',
//         'message': 'Network error: $e',
//         'raw': '',
//       };
//     }
//   }
// }
// import 'dart:convert';
// import 'package:http/http.dart' as http;
//
// /// Base URL of backend
// /// Android Emulator uses 10.0.2.2 to access localhost
// // const String API_BASE = "http://10.0.2.2:5000/api";
// // const String API_BASE = "http://192.168.1.X:5000/api"; // replace X with your actual IP
// // const String API_BASE = "delphia-synostotic-fletcher.ngrok-free.dev";
//
// const String API_BASE = "https://moneymatrix-r3ae.onrender.com/api";
// class ApiService {
//
//   static Future<Map<String, dynamic>> post(
//       String path,
//       Map body,
//       {Map<String, String>? headers}) async {
//
//     final url = Uri.parse('$API_BASE/$path');
//
//     final defaultHeaders = {
//       'Content-Type': 'application/json; charset=UTF-8'
//     };
//
//     if (headers != null) {
//       defaultHeaders.addAll(headers);
//     }
//
//     try {
//
//       final res = await http
//           .post(
//         url,
//         headers: defaultHeaders,
//         body: jsonEncode(body),
//       )
//           .timeout(const Duration(seconds: 15));
//
//       if (res.body.isEmpty) {
//         return {
//           "status": "error",
//           "message": "Empty response from server"
//         };
//       }
//
//       return jsonDecode(res.body);
//
//     } catch (e) {
//
//       return {
//         "status": "error",
//         "message": "Network error: $e"
//       };
//
//     }
//
//   }
//
// }
import 'dart:convert';
import 'package:http/http.dart' as http;

// Use your PC's actual local IP for real device testing
const String API_BASE = "https://moneymatrix-r3ae.onrender.com";

class ApiService {
  static Future<Map<String, dynamic>> post(
      String path,
      Map body, {
        Map<String, String>? headers,
      }) async {
    final url = Uri.parse('$API_BASE/$path');

    final defaultHeaders = {
      'Content-Type': 'application/json; charset=UTF-8'
    };

    if (headers != null) defaultHeaders.addAll(headers);

    try {
      final res = await http
          .post(url, headers: defaultHeaders, body: jsonEncode(body))
          .timeout(const Duration(seconds: 15));

      print('Status: ${res.statusCode}');
      print('Body: ${res.body}');

      // Check empty response
      if (res.body.isEmpty) {
        return {"status": "error", "message": "Empty response from server"};
      }

      // Check content type
      final contentType = res.headers['content-type'] ?? '';
      if (!contentType.contains('application/json')) {
        return {
          "status": "error",
          "message": "Invalid response type: $contentType",
          "raw": res.body
        };
      }

      // Check status code
      if (res.statusCode == 200 || res.statusCode == 201 || res.statusCode == 400) {
        return jsonDecode(res.body);
      } else {
        return {
          "status": "error",
          "message": "HTTP error: ${res.statusCode}",
          "raw": res.body
        };
      }
    } catch (e) {
      print('Error: $e');
      return {"status": "error", "message": "Network error: $e"};
    }
  }
}
