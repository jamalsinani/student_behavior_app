import 'dart:convert';
import 'package:http/http.dart' as http;

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

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception("Register failed");
  }
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


}