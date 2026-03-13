import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';

class AuthService {
  static const String baseUrl = "https://abuobaida-edu.com/api";

  static Future<Map<String, dynamic>> checkPhone(String phone) async {
    final response = await http.post(
      Uri.parse("$baseUrl/check-phone"),
      body: {
        'phone': phone,
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Server Error: ${response.statusCode}");
    }
  }

  static Future<Map<String, dynamic>> registerUser({
  required String name,
  required String phone,
  required String email,
  required String password,
  required String type,
}) async {

  final response = await http.post(
    Uri.parse("$baseUrl/register"),
    body: {
      'name': name,
      'phone': phone,
      'email': email,
      'password': password,
      'type': type,
    },
  );

  final data = jsonDecode(response.body);

  return data;
}

static Future<Map<String, dynamic>> loginUser({
  required String phone,
  required String password,
}) async {

  final response = await http.post(
    Uri.parse("$baseUrl/login"),
    headers: {
      "Accept": "application/json",
    },
    body: {
      'phone': phone,
      'password': password,
    },
  );

  print("RESPONSE BODY: ${response.body}");

  if (response.statusCode == 200) {

    final Map<String, dynamic> json = jsonDecode(response.body);

    if (json['status'] == true) {

      // 👇 نرجع JSON كامل وليس data فقط
      return json;

    } else {
      throw Exception(json['message'] ?? "فشل تسجيل الدخول");
    }

  } else {
    throw Exception("خطأ في الاتصال بالخادم");
  }
}

static Future<Map<String, dynamic>> addRole({
  required String phone,
  required String password,
  required String role,
}) async {

  final response = await http.post(
    Uri.parse("$baseUrl/add-role"),
    headers: {
      "Accept": "application/json",
    },
    body: {
      'phone': phone,
      'password': password,
      'role': role,
    },
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception("Add role failed");
  }
}


static Future<Map<String, dynamic>> forgotPassword({
  required String phone,
}) async {

  final response = await http.post(
    Uri.parse("$baseUrl/forgot-password"),
    headers: {
      "Accept": "application/json",
    },
    body: {
      'phone': phone,
      'school_id': '1'
    },
  );

  if (response.statusCode == 200) {

    final data = jsonDecode(response.body);

    if (data["status"] == true) {
      return data;
    } else {
      throw Exception(data["message"]);
    }

  } else {
    throw Exception("Server Error");
  }
}

static Future<void> sendFcmToken(int userId) async {

  try {

    String? token = await FirebaseMessaging.instance.getToken();

    print("USER ID: $userId");
    print("FCM TOKEN: $token");

    if (token == null) {
      print("FCM token not ready yet");
      return;
    }

    final response = await http.post(
      Uri.parse("$baseUrl/save-fcm-token"),
      body: {
        "user_id": userId.toString(),
        "fcm_token": token,
      },
    );

    print("SERVER RESPONSE: ${response.body}");

  } catch (e) {
    print("FCM token error: $e");
  }

}


}