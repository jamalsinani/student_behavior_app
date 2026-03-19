import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'firebase_options.dart';
import 'core/app_theme.dart';
import 'screens/school_home_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> initNotifications() async {
  try {
    if (kIsWeb) return;

    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print("Authorization: ${settings.authorizationStatus}");

    String? apnsToken;
    String? fcmToken;

    // ===== خاص بـ iOS =====
    if (defaultTargetPlatform == TargetPlatform.iOS) {

      // 🔥 نحاول أكثر عشان iOS يتأخر
      for (int i = 0; i < 20; i++) {
        apnsToken = await messaging.getAPNSToken();

        if (apnsToken != null) break;

        await Future.delayed(const Duration(seconds: 1));
      }

      print("APNS TOKEN: $apnsToken");

      // ❌ إذا ما وصل APNs → نوقف هنا
      if (apnsToken == null) {
        print("❌ APNS NOT RECEIVED");
        return;
      }

      // 🔥 ننتظر شوي ثم نطلب FCM
      await Future.delayed(const Duration(seconds: 2));

      fcmToken = await messaging.getToken();

    } else {
      // ===== Android =====
      fcmToken = await messaging.getToken();
    }

    print("FCM TOKEN: $fcmToken");

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Notification received: ${message.notification?.title}");
    });

  } catch (e) {
    print("Notification error: $e");
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const StudentBehaviorApp());
}

class StudentBehaviorApp extends StatefulWidget {
  const StudentBehaviorApp({super.key});

  @override
  State<StudentBehaviorApp> createState() => _StudentBehaviorAppState();
}

class _StudentBehaviorAppState extends State<StudentBehaviorApp> {

  @override
  void initState() {
    super.initState();

    // تشغيل الإشعارات بعد تشغيل التطبيق
    initNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EduBehave Platform',
      theme: AppTheme.lightTheme,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      home: const SchoolHomeScreen(),
    );
  }
}
