import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'firebase_options.dart';

import 'core/app_theme.dart';
import 'screens/school_home_screen.dart';
import 'package:flutter/foundation.dart';

Future<void> initNotifications() async {

  if (kIsWeb) {
    print("Notifications disabled on Web");
    return;
  }

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {

    try {

      String? apnsToken = await messaging.getAPNSToken();
      print("APNS TOKEN: $apnsToken");

      String? fcmToken = await messaging.getToken();
      print("FCM TOKEN: $fcmToken");

    } catch (e) {
      print("FCM ERROR: $e");
    }

  }

}

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await initNotifications();

  runApp(const StudentBehaviorApp());
}

class StudentBehaviorApp extends StatefulWidget {
  const StudentBehaviorApp({super.key});

  @override
  State<StudentBehaviorApp> createState() => _StudentBehaviorAppState();
}

class _StudentBehaviorAppState extends State<StudentBehaviorApp> {

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