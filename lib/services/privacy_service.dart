import 'dart:convert';
import 'package:http/http.dart' as http;

class PrivacyService {

  static const String baseUrl = "https://abuobaida-edu.com/api";

  static Future<String> fetchPrivacyPolicy() async {

    final response = await http.get(
      Uri.parse("$baseUrl/privacy-policy"),
      headers: {
        "Accept": "application/json",
      },
    );

    if (response.statusCode == 200) {

      final data = jsonDecode(response.body);

      return data["data"] ?? "";

    } else {
      throw Exception("فشل في جلب سياسة الاستخدام");
    }

  }
}