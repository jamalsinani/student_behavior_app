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

static Future getStudentInfo(String studentId) async {

  final res = await http.get(
    Uri.parse("$baseUrl/parent/student-info?student_id=$studentId"),
  );

  print("STUDENT INFO STATUS: ${res.statusCode}");
  print("STUDENT INFO BODY: ${res.body}");

  return jsonDecode(res.body);
}

static Future updateStudentData({
  required String id,
  required String userId,
  required String parentName,
  required String phone,
  required String phoneAlt,
  required String relation,
  required String job,
  required String area,
  required String transport,
  required String driverPhone,
  required String talent,
  required String diseases,

}) async {

  final res = await http.post(
    Uri.parse("$baseUrl/parent/update-student-data"),
    body: {

      "id": id,
      "user_id": userId,
      "parent_name": parentName,
      "guardian_phone": phone,
      "guardian_phone_alt": phoneAlt,
      "guardian_relation": relation,
      "guardian_job": job,
      "residence_area": area,
      "transport_type": transport,
      "driver_phone": driverPhone,
      "talent": talent,
      "diseases": diseases,

    },
  );

  return jsonDecode(res.body);
}

/// =============================
/// جلب شهادات الطالب
/// =============================
static Future<Map<String, dynamic>> getStudentCertificates(String studentId) async {

  final response = await http.post(
    Uri.parse("$baseUrl/parent/student-certificates"),
    body: {
      "student_id": studentId,
    },
  );

  print("CERTIFICATES STATUS: ${response.statusCode}");
  print("CERTIFICATES BODY: ${response.body}");

  if (response.statusCode == 200) {

    final data = json.decode(response.body);
    return data;

  } else {

    throw Exception("فشل في جلب الشهادات");

  }
}

/// =============================
/// إرسال مقترح أو ملاحظة
/// =============================
static Future sendSuggestion({

  required String studentId,
  required String title,
  required String message,
  required String type,

}) async {

  final res = await http.post(
    Uri.parse("$baseUrl/parent/send-suggestion"),
    body: {

      "student_id": studentId,
      "title": title,
      "message": message,
      "type": type,

    },
  );

  return jsonDecode(res.body);
}

/// =============================
/// جلب سجل التقارير (الأرشيف)
/// =============================
static Future<List> getStudentReportsHistory({
  required String studentId,
}) async {

  final uri = Uri.parse(
    "$baseUrl/parent/student-reports-history",
  ).replace(queryParameters: {
    "student_id": studentId,
  });

  print("REPORT HISTORY URL: $uri");

  final response = await http.get(uri);

  print("REPORT HISTORY STATUS: ${response.statusCode}");
  print("REPORT HISTORY BODY: ${response.body}");

  if (response.statusCode == 200) {

    final data = json.decode(response.body);

    if (data['success'] == true) {
      return List.from(data['data']);
    }

    return [];

  } else {
    throw Exception("فشل في جلب السجلات");
  }
}

}