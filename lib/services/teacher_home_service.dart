import 'dart:convert';
import 'package:http/http.dart' as http;

class TeacherHomeService {

  static const String baseUrl =
      "https://abuobaida-edu.com/api";

  static Future<Map<String, dynamic>> getTodayData({
    required String teacherPhone,
    required int schoolId,
  }) async {

    final uri = Uri.parse(
      "$baseUrl/teacher/today-data",
    ).replace(queryParameters: {
      "teacher_phone": teacherPhone,
      "school_id": schoolId.toString(),
    });

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return json.decode(response.body); // ✅ يرجع Map كامل
    } else {
      throw Exception("فشل في جلب البيانات");
    }
  }

  static Future<Map<String, dynamic>> getTeacherProfile({
  required String teacherPhone,
  required int schoolId,
}) async {

  final uri = Uri.parse(
    "$baseUrl/teacher/profile",
  ).replace(queryParameters: {
    "teacher_phone": teacherPhone,
    "school_id": schoolId.toString(),
  });

  final response = await http.get(uri);

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception("فشل في جلب بيانات الملف الشخصي");
  }
}

static Future<Map<String, dynamic>> updateSwapStatus({
  required int id,
  required String status,
  required int schoolId,
}) async {

  final uri = Uri.parse(
    "$baseUrl/teacher/update-swap-status",
  );

  final response = await http.post(
    uri,
    headers: {
      "Accept": "application/json",
    },
    body: {
      "id": id.toString(),
      "status": status,
      "school_id": schoolId.toString(),
    },
  );

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception("فشل في تحديث حالة الطلب");
  }
}


}