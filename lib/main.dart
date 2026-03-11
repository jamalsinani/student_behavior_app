import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'firebase_options.dart';

import 'core/app_theme.dart';
import 'screens/school_home_screen.dart';
import 'screens/parent/student_reports_screen.dart';

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

    requestNotificationPermission();

    /// إذا ضغط المستخدم على الإشعار والتطبيق كان مغلق
    FirebaseMessaging.instance.getInitialMessage().then((message) {

      if (message != null) {
        handleNotification(message);
      }

    });

    /// إذا ضغط المستخدم على الإشعار والتطبيق في الخلفية
    FirebaseMessaging.onMessageOpenedApp.listen((message) {

      handleNotification(message);

    });

    /// إذا وصل إشعار والتطبيق مفتوح
    FirebaseMessaging.onMessage.listen((message) {

      if (message.notification != null) {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              message.notification!.body ?? "وصلك إشعار جديد",
            ),
          ),
        );

      }

    });

  }

  void handleNotification(RemoteMessage message) {

  Future.delayed(const Duration(milliseconds: 800), () {

    String? type = message.data['type'];

    if (type == "report") {

      Map<String, dynamic> student = {
        "id": message.data['student_id'],
        "name": message.data['student_name']
      };

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => StudentReportsScreen(
            student: student,
          ),
        ),
      );

    }

  });

}
  void requestNotificationPermission() async {

    FirebaseMessaging messaging = FirebaseMessaging.instance;

    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    String? token = await messaging.getToken();

    print("FCM TOKEN:");
    print(token);
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