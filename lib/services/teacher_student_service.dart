import 'dart:convert';
import 'package:http/http.dart' as http;

class TeacherStudentService {

  static const String baseUrl =
      "https://abuobaida-edu.com/api";

  /// ================= ADD STAR =================
  static Future<bool> addStar({
    required int studentId,
    required String teacherPhone,
    required int schoolId,
    required String subjectName,
  }) async {

    final uri =
        Uri.parse("$baseUrl/teacher/add-star");

    final response = await http.post(
      uri,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode({
        "student_id": studentId,
        "teacher_phone": teacherPhone,
        "school_id": schoolId,
        "subject_name": subjectName,
      }),
    );
     
     print("STATUS CODE: ${response.statusCode}");
     print("BODY: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['status'] == true;
    }

    return false;
  }

  static Future<int> getStarsCount({
  required int studentId,
  required int schoolId,
  required String subjectName,
}) async {
  final uri = Uri.parse(
      "$baseUrl/teacher/student-stars-count")
      .replace(queryParameters: {
    "student_id": studentId.toString(),
    "school_id": schoolId.toString(),
    "subject_name": subjectName,
  });

  final response = await http.get(uri);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data['count'] ?? 0;
  } else {
    return 0;
  }
}

static Future<bool> addGrade({
  required int studentId,
  required int schoolId,
  required String subjectName,
  required double gradeValue,
  required String gradeNote,
  required String teacherPhone,
}) async {
  try {

    final response = await http.post(
      Uri.parse("https://abuobaida-edu.com/api/teacher/add-grade"),
      headers: {"Content-Type": "application/json",
      "Accept": "application/json",
      },
      body: jsonEncode({
        "student_id": studentId,
        "school_id": schoolId,
        "subject_name": subjectName,
        "grade_value": gradeValue,
        "grade_note": gradeNote,
        "teacher_phone": teacherPhone,
      }),
    );

    print("STATUS CODE: ${response.statusCode}");
    print("BODY: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["status"] == true;
    }

    return false;

  } catch (e) {
    print("ERROR: $e");
    return false;
  }
}

/// ================= ADD NOTE =================
static Future<bool> addNote({
  required int studentId,
  required int schoolId,
  required String subjectName,
  required String noteText,
  required String teacherPhone,
}) async {
  try {

    final response = await http.post(
      Uri.parse("$baseUrl/teacher/add-note"),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode({
        "student_id": studentId,
        "school_id": schoolId,
        "subject_name": subjectName,
        "note_text": noteText,
        "teacher_phone": teacherPhone,
      }),
    );

    print("NOTE STATUS CODE: ${response.statusCode}");
    print("NOTE BODY: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["status"] == true;
    }

    return false;

  } catch (e) {
    print("NOTE ERROR: $e");
    return false;
  }
}

/// ================= GET STUDENT RECORDS =================
static Future<List<dynamic>> getStudentRecords({
  required String teacherPhone,
  required int schoolId,
}) async {
  try {

    final uri = Uri.parse(
      "$baseUrl/teacher/student-records"
    ).replace(queryParameters: {
      "teacher_phone": teacherPhone,
      "school_id": schoolId.toString(),
    });

    final response = await http.get(uri);

    print("RECORDS STATUS: ${response.statusCode}");
    print("RECORDS BODY: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    return [];

  } catch (e) {
    print("RECORDS ERROR: $e");
    return [];
  }
}

static Future<bool> deleteStudentRecord({
  required int id,
  required String type,
}) async {

  final response = await http.post(
    Uri.parse("$baseUrl/teacher/delete-student-record"),
    headers: {
      "Content-Type": "application/json",
      "Accept": "application/json",
    },
    body: jsonEncode({
      "id": id,
      "type": type,
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data["status"] == true;
  }

  return false;
}

// =====================================================
// تحميل أرشيف المعلم (التغطيات + الملاحظات القديمة)
// =====================================================
static Future<List<dynamic>> getTeacherArchive({
  required String teacherPhone,
  required int schoolId,
}) async {

  final uri = Uri.parse(
    "$baseUrl/teacher/archive",
  ).replace(queryParameters: {
    "teacher_phone": teacherPhone,
    "school_id": schoolId.toString(),
  });

  final response = await http.get(uri);

  print("ARCHIVE STATUS: ${response.statusCode}");
  print("ARCHIVE BODY: ${response.body}");

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  }

  return [];
}

// ===============================
// 🔴 تسجيل غياب طالب
// ===============================
static Future<Map<String, dynamic>> addAbsence({
  required int studentId,
  required String studentName,
  required int schoolId,
  required String subjectName,
  required String teacherPhone,
  required int periodNumber,
  required String absenceDate,
}) async {

  try {

    final response = await http.post(
      Uri.parse("$baseUrl/teacher/add-absence"),
      headers: {
        "Accept": "application/json",
      },
      body: {
        "student_id": studentId.toString(),
        "student_name": studentName,
        "school_id": schoolId.toString(),
        "subject_name": subjectName,
        "teacher_phone": teacherPhone,
        "period_number": periodNumber.toString(),
        "absence_date": absenceDate,
      },
    );

    print("🔵 STATUS CODE: ${response.statusCode}");
    print("🔵 RESPONSE BODY: ${response.body}");

    final data = json.decode(response.body);

    return data;

  } catch (e) {

    print("🔴 ERROR: $e");

    return {
      "status": false,
      "message": "خطأ في الاتصال بالسيرفر"
    };
  }
}

// ===============================
// 🔴 حذف غياب طالب
// ===============================
static Future<bool> removeAbsence({
  required int studentId,
  required int schoolId,
  required String subjectName,
  required String teacherPhone,
  required int periodNumber,
  required String absenceDate,
}) async {
  try {

    final response = await http.post(
      Uri.parse("$baseUrl/teacher/remove-absence"),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode({
        "student_id": studentId,
        "school_id": schoolId,
        "subject_name": subjectName,
        "teacher_phone": teacherPhone,
        "period_number": periodNumber,
        "absence_date": absenceDate,
      }),
    );

    print("REMOVE STATUS CODE: ${response.statusCode}");
    print("REMOVE BODY: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["status"] == true;
    }

    return false;

  } catch (e) {
    print("REMOVE ERROR: $e");
    return false;
  }
}

static Future<List<int>> getTodayAbsences({
  required int schoolId,
  required String subjectName,
  required String teacherPhone,
  required int periodNumber,
  required String absenceDate,
}) async {
  try {

    final uri = Uri.parse("$baseUrl/teacher/today-absences")
        .replace(queryParameters: {
      "school_id": schoolId.toString(),
      "subject_name": subjectName,
      "teacher_phone": teacherPhone,
      "period_number": periodNumber.toString(),
      "absence_date": absenceDate,
    });

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => int.parse(e.toString())).toList();
    }

    return [];

  } catch (e) {
    return [];
  }
}

static Future<Map<String, dynamic>> sendClassMessage({
  required int schoolId,
  required String section,
  required String grade,
  required String subjectName,
  required String teacherPhone,
  required String message,
}) async {

  final url = Uri.parse("$baseUrl/teacher/send-class-message");

  final response = await http.post(
    url,
    body: {
      "school_id": schoolId.toString(),
      "section": section,
      "grade": grade,
      "subject_name": subjectName,
      "teacher_phone": teacherPhone,
      "message": message,
    },
  );

  print("SEND CLASS MESSAGE STATUS: ${response.statusCode}");
  print("SEND CLASS MESSAGE BODY: ${response.body}");

  return jsonDecode(response.body);
}
}