// =======================================================
// 📝 TeacherPermissionService
// مسؤول عن:
// - إرسال طلب استئذان المعلم إلى Laravel
// =======================================================

import 'dart:convert';
import 'package:http/http.dart' as http;


class TeacherPermissionService {


  static const String baseUrl =
      "https://abuobaida-edu.com/api";


  // =============================================
  // إرسال طلب استئذان
  // =============================================
  static Future<Map<String, dynamic>> sendPermission({

    required int schoolId,
    required int teacherId,

    required String date,
    required String fromTime,
    required String toTime,

    required String reason,

    required double latitude,
    required double longitude,

  }) async {


    try {

      final response = await http.post(

        Uri.parse(
          "$baseUrl/teacher/request-permission",
        ),

        headers: {
          "Content-Type": "application/json",
        },


        body: jsonEncode({

          "school_id": schoolId,

          "teacher_id": teacherId,

          "permission_date": date,

          "from_time": fromTime,

          "to_time": toTime,

          "reason": reason,

          "teacher_latitude": latitude,

          "teacher_longitude": longitude,

        }),

      );


      return jsonDecode(response.body);


    } catch (e) {

      return {

        "status": false,

        "message":
            "تعذر الاتصال بالسيرفر",

      };

    }

  }

}