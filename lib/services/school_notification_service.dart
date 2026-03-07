import 'dart:convert';
import 'package:http/http.dart' as http;

class SchoolNotificationService {

  /// ================= إشعارات الصفحة الرئيسية =================
  static Future<List<dynamic>> fetchNotifications(int schoolId) async {

    final url = Uri.parse(
        "https://abuobaida-edu.com/api/school/notifications/$schoolId");

    final response = await http.get(url);

    if (response.statusCode == 200) {

      final data = json.decode(response.body);

      return data["data"];

    } else {

      throw Exception("فشل جلب الإشعارات");

    }
  }


  /// ================= الإشعارات المرسلة =================
  static Future<List<dynamic>> fetchSentNotifications(int schoolId) async {

    final url = Uri.parse(
        "https://abuobaida-edu.com/api/school/sent-notifications/$schoolId");

    final response = await http.get(url);

    if (response.statusCode == 200) {

      final data = json.decode(response.body);

      return data;

    } else {

      throw Exception("فشل جلب الإشعارات المرسلة");

    }
  }

}