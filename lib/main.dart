import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'firebase_options.dart';
import 'core/app_theme.dart';
import 'screens/school_home_screen.dart';

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

    // ===== خاص بـ iOS =====
    if (defaultTargetPlatform == TargetPlatform.iOS) {

      String? apnsToken;

      for (int i = 0; i < 10; i++) {
        apnsToken = await messaging.getAPNSToken();

        if (apnsToken != null) break;

        await Future.delayed(const Duration(seconds: 1));
      }

      print("APNS TOKEN: $apnsToken");
    }

    // ===== يعمل للأندرويد و iOS =====
    String? fcmToken = await messaging.getToken();
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