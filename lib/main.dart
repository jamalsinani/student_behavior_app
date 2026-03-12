import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'firebase_options.dart';
import 'core/app_theme.dart';
import 'screens/school_home_screen.dart';

Future<void> initNotifications() async {
  if (kIsWeb) return;

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  print("Authorization: ${settings.authorizationStatus}");

  if (defaultTargetPlatform == TargetPlatform.iOS) {
    String? apnsToken = await messaging.getAPNSToken();
    print("APNS TOKEN: $apnsToken");
  }

  String? fcmToken = await messaging.getToken();
  print("FCM TOKEN: $fcmToken");

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("Notification received: ${message.notification?.title}");
  });
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