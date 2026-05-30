// =======================================================
// 📍 LocationService
// مسؤول عن:
// - طلب صلاحية الموقع
// - جلب موقع المعلم الحالي
// - جلب موقع المدرسة من السيرفر
// - حساب المسافة بين المعلم والمدرسة
// =======================================================

import 'dart:convert';
import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;


class LocationService {


  // رابط السيرفر
  static const String baseUrl =
      "https://abuobaida-edu.com/api";


  // =====================================================
  // التحقق هل المعلم داخل نطاق المدرسة
  // =====================================================
  static Future<Map<String, dynamic>> checkTeacherLocation({
    required int schoolId,
  }) async {

    try {

      print("======== SCHOOL ID ========");
      print(schoolId);

      // 1) التأكد من تشغيل GPS
      bool serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        return {
          "status": false,
          "message": "يرجى تشغيل خدمة الموقع GPS"
        };
      }


      // 2) فحص الصلاحيات
      LocationPermission permission =
          await Geolocator.checkPermission();


      if (permission == LocationPermission.denied) {

        permission =
            await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          return {
            "status": false,
            "message": "لم يتم السماح باستخدام الموقع"
          };
        }
      }


      if (permission ==
          LocationPermission.deniedForever) {

        return {
          "status": false,
          "message":
              "صلاحية الموقع مرفوضة نهائياً، قم بتفعيلها من الإعدادات"
        };
      }



      // 3) موقع المعلم الحالي
      Position position =
    await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 10),
    );


      // 4) جلب موقع المدرسة
      final response = await http.get(
        Uri.parse(
          "$baseUrl/school-location/$schoolId",
        ),
      );


      final data =
          jsonDecode(response.body);



      if (data["status"] != true) {

        return {
          "status": false,
          "message":
              "لم يتم العثور على موقع المدرسة"
        };

      }



      double schoolLat =
          double.parse(data["latitude"].toString());

      double schoolLng =
          double.parse(data["longitude"].toString());

      double radius =
          double.parse(data["allowed_radius"].toString());



      // 5) حساب المسافة بالمتر
      double distance =
          Geolocator.distanceBetween(

        position.latitude,
        position.longitude,

        schoolLat,
        schoolLng,

      );

      // =====================================
// اختبار بيانات الموقع
// =====================================
print("========== LOCATION CHECK ==========");

print("PHONE LAT = ${position.latitude}");
print("PHONE LNG = ${position.longitude}");

print("SCHOOL LAT = $schoolLat");
print("SCHOOL LNG = $schoolLng");

print("ALLOWED RADIUS = $radius");

print("DISTANCE = $distance متر");

print("====================================");



      // 6) التحقق
      if (distance <= radius) {

        return {

          "status": true,
          "message":
              "داخل نطاق المدرسة",

          "distance": distance,

          // موقع المعلم الحقيقي
          "latitude": position.latitude,

          "longitude": position.longitude,

        };

      } else {

        return {

          "status": false,

          "message":
              "لا يمكنك تقديم الاستئذان خارج نطاق المدرسة",

          "distance": distance,

         "latitude": position.latitude,

         "longitude": position.longitude,

        };

      }


    } catch (e) {

        print("LOCATION ERROR ===== $e");

      return {

        "status": false,

        "message":
            "حدث خطأ أثناء تحديد الموقع",

      };

    }

  }

}