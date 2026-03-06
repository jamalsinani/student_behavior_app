import 'dart:convert';
import 'package:http/http.dart' as http;

class ParentService {

  static const String baseUrl = "https://abuobaida-edu.com/api";

  static Future<List> getChildren({
    required String phone,
    required String schoolId,
  }) async {

    final uri = Uri.parse(
      "$baseUrl/parent/students",
    ).replace(queryParameters: {
      "guardian_phone": phone,
      "school_id": schoolId,
    });

    final response = await http.get(uri);

    print("PARENT API STATUS: ${response.statusCode}");
    print("PARENT API BODY: ${response.body}");

    if (response.statusCode == 200) {

      final data = json.decode(response.body);

      if (data['status'] == true) {
        return List.from(data['students']);
      }

      return [];

    } else {
      throw Exception("فشل في جلب الأبناء");
    }
  }

  static Future<List> getStudentSchedule({
  required String schoolId,
  required String studentClass,
  required String section,
  required int day,
}) async {

  final uri = Uri.parse(
    "$baseUrl/parent/student-schedule",
  ).replace(queryParameters: {
    "school_id": schoolId,
    "class": studentClass,
    "section": section,
    "day": day.toString(),
  });
  print(uri.toString());
  final response = await http.get(uri);

  print("SCHEDULE STATUS: ${response.statusCode}");
  print("SCHEDULE BODY: ${response.body}");

  if (response.statusCode == 200) {

    final data = json.decode(response.body);

    if (data['success'] == true) {
      return List.from(data['data']);
    }

    return [];

  } else {
    throw Exception("فشل في جلب جدول الطالب");
  }
}

static Future<List> getStudentReports({
  required String studentId,
}) async {

  final uri = Uri.parse(
    "$baseUrl/parent/student-reports-today",
  ).replace(queryParameters: {
    "student_id": studentId,
  });

  print("REPORTS URL: $uri");

  final response = await http.get(uri);

  print("REPORTS STATUS: ${response.statusCode}");
  print("REPORTS BODY: ${response.body}");

  if (response.statusCode == 200) {

    final data = json.decode(response.body);

    if (data['success'] == true) {
      return List.from(data['data']);
    }

    return [];

  } else {
    throw Exception("فشل في جلب التقارير");
  }
}


}