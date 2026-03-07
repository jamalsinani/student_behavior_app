import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class SchoolMessageService {

  static const String baseUrl = "https://abuobaida-edu.com/api";

  /// ================= جلب الصفوف =================
  static Future<List> fetchClasses(int schoolId) async {

    final res = await http.get(
      Uri.parse("$baseUrl/school/classes/$schoolId"),
    );

    return json.decode(res.body);
  }

  /// ================= جلب الشعب =================
  static Future<List> fetchSections(int schoolId, String classId) async {

    final res = await http.get(
      Uri.parse("$baseUrl/school/sections/$schoolId/$classId"),
    );

    return json.decode(res.body);
  }

  /// ================= جلب الطلاب =================
  static Future<List> fetchStudents(
      int schoolId,
      String classId,
      String section,
      ) async {

    final res = await http.get(
      Uri.parse("$baseUrl/school/students/$schoolId/$classId/$section"),
    );

    return json.decode(res.body);
  }

  /// ================= إرسال رسالة =================
  static Future<Map<String, dynamic>> sendMessage({
  required int schoolId,
  int? studentId,
  required String message,
  required String type,
  File? image,
}) async {

  var request = http.MultipartRequest(
    "POST",
    Uri.parse("$baseUrl/school/send-message"),
  );

  request.fields["school_id"] = schoolId.toString();
  request.fields["title"] = "رسالة من المدرسة";
  request.fields["message"] = message;
  request.fields["send_to"] = type;

  if (studentId != null) {
    request.fields["student_id"] = studentId.toString();
  }

  /// رفع الصورة
  if (image != null) {

    request.files.add(
      await http.MultipartFile.fromPath(
        "image",
        image.path,
      ),
    );

  }

  var response = await request.send();

  var res = await http.Response.fromStream(response);

  return json.decode(res.body);
}

/// ================= جلب المواد للمعلمين =================
static Future<List> fetchSubjects(int schoolId) async {

  final res = await http.get(
    Uri.parse("$baseUrl/school/subjects/$schoolId"),
  );

  return json.decode(res.body);
}

/// ================= جلب المعلمين حسب المادة =================
static Future<List> fetchTeachersBySubject(
    int schoolId,
    String subject,
) async {

  final res = await http.get(
    Uri.parse("$baseUrl/school/teachers-by-subject/$schoolId/$subject"),
  );

  return json.decode(res.body);
}

/// ================= إرسال رسالة للمعلمين =================
static Future<Map<String, dynamic>> sendTeacherMessage({
  required int schoolId,
  String? teacherName,
  String? teacherPhone,
  required String message,
  required String type,
}) async {

  final res = await http.post(
    Uri.parse("$baseUrl/school/send-teacher-message"),
    body: {
      "school_id": schoolId.toString(),
      "teacher_name": teacherName ?? "",
      "teacher_phone": teacherPhone ?? "",
      "title": "رسالة من الإدارة",
      "message": message,
      "send_to": type
    },
  );

  return json.decode(res.body);
}


}