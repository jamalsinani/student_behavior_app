import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'core/app_theme.dart';
import 'screens/auth/register_screen.dart';
import 'screens/splash/splash_screen.dart';

void main() {
  runApp(const StudentBehaviorApp());
}

class StudentBehaviorApp extends StatelessWidget {
  const StudentBehaviorApp({super.key});

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

  home: const SplashScreen(),
);

  }
}