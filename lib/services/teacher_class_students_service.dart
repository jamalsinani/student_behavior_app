import 'dart:convert';
import 'package:http/http.dart' as http;

class TeacherClassStudentsService {

  static const String baseUrl = "https://abuobaida-edu.com/api";

  static Future<List> getClassStudents({
  required String section,
  required String grade,
  required int schoolId,
}) async {

  final uri = Uri.parse(
    "$baseUrl/teacher/class-students"
  ).replace(queryParameters: {
    "section": section,
    "grade": grade,
    "school_id": schoolId.toString(),
  });

  print("===================================");
  print("API REQUEST:");
  print("SECTION: $section");
  print("GRADE: $grade");
  print("SCHOOL ID: $schoolId");
  print("FULL URL: $uri");
  print("===================================");

  final response = await http.get(uri);

  print("STATUS CODE: ${response.statusCode}");
  print("RAW BODY: ${response.body}");

  if (response.statusCode == 200) {

    final data = json.decode(response.body);

    print("DECODED DATA: $data");

    if (data['status'] == true) {
      print("STUDENTS RETURNED: ${data['data']}");
      print("COUNT: ${data['data'].length}");
      return List.from(data['data']);
    }

    print("STATUS FALSE FROM SERVER");
    return [];

  } else {
    print("REQUEST FAILED");
    throw Exception("فشل في جلب الطلاب");
  }
}



}