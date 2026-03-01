import 'dart:convert';
import 'package:http/http.dart' as http;

class TeacherClassesService {

  static const String baseUrl = "https://abuobaida-edu.com/api";

  static Future<List> getTeacherClasses({
    required String teacherPhone,
    required int schoolId,
  }) async {

    final uri = Uri.parse(
      "$baseUrl/teacher/classes"
    ).replace(queryParameters: {
      "teacher_phone": teacherPhone,
      "school_id": schoolId.toString(),
    });

    final response = await http.get(uri);

    if (response.statusCode == 200) {

      final data = json.decode(response.body);

      if (data['status'] == true) {
        return List.from(data['data']);
      }

      return [];

    } else {
      throw Exception("فشل في جلب الفصول");
    }
  }
}