import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

import 'core/app_theme.dart';
import 'screens/school_home_screen.dart';

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