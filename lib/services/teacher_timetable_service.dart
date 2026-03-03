import 'dart:convert';
import 'package:http/http.dart' as http;

class TeacherTimetableService {
  static const String baseUrl = "https://abuobaida-edu.com/api";

  static Future<List> getTimetable({
  required String teacherPhone,
  required int schoolId,
  required int dayNumber,
}) async {

  final uri = Uri.parse(
    "$baseUrl/teacher/get-timetable"
  ).replace(queryParameters: {
    "teacher_phone": teacherPhone,
    "school_id": schoolId.toString(),
    "day_number": dayNumber.toString(),
  });

  final response = await http.get(uri);

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception("فشل في جلب الجدول");
  }
}

static Future<List> getTeachers({
  required int schoolId,
}) async {

  final uri = Uri.parse("$baseUrl/teacher/list")
      .replace(queryParameters: {
    "school_id": schoolId.toString(),
  });

  final response = await http.get(uri);

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception("فشل في جلب المعلمين");
  }
}

static Future<Map<String, dynamic>?> getTeacherPeriodInfo({
  required String teacherPhone,
  required int schoolId,
  required int dayNumber,
  required int periodNumber,
}) async {

  final uri = Uri.parse("$baseUrl/teacher/period-info")
      .replace(queryParameters: {
    "teacher_phone": teacherPhone,
    "school_id": schoolId.toString(),
    "day_number": dayNumber.toString(),
    "period_number": periodNumber.toString(),
  });

  final response = await http.get(uri);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    if (data['status'] == true) {
      return data;
    }
  }

  return null;
}

static Future<Map<String, dynamic>> sendSwapRequest({
  required int schoolId,
  required String requesterPhone,
  required String requesterName,
  required String substitutePhone,
  required String substituteName,
  required int originalDay,
  required int originalPeriod,
  required int targetDay,
  required int targetPeriod,
  required String subjectName,
  required String section,
  required String grade,
}) async {

  final url = Uri.parse("$baseUrl/teacher/send-swap");

  final response = await http.post(
    url,
    headers: {
      "Content-Type": "application/json",
    },
    body: jsonEncode({
      "school_id": schoolId,
      "requester_phone": requesterPhone,
      "requester_name": requesterName,
      "substitute_phone": substitutePhone,
      "substitute_name": substituteName,
      "original_day": originalDay,
      "original_period": originalPeriod,
      "target_day": targetDay,
      "target_period": targetPeriod,
      "subject_name": subjectName,
      "section": section,
      "grade": grade,
    }),
  );

  final data = json.decode(response.body);
  return data;
}

}