import 'dart:convert';
import 'package:http/http.dart' as http;

class ProfileUpdateService {

  static const String baseUrl =
      "https://abuobaida-edu.com/api";

  static Future<Map<String, dynamic>>
      updateField({
    required String teacherPhone,
    required String schoolId,
    required String field,
    required String value,
  }) async {

    final response = await http.post(
      Uri.parse(
        "$baseUrl/teacher/update-profile-field",
      ),
      body: {
        "teacher_phone": teacherPhone,
        "school_id": schoolId,
        "field": field,
        "value": value,
      },
    );

    return jsonDecode(response.body);
  }
}