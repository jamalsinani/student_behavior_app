import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/auth_service.dart';
import '../teacher/teacher_home_screen.dart';
import '../parent/parent_home_screen.dart';
import '../auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  Future<void> checkLogin() async {

    final prefs = await SharedPreferences.getInstance();

    final remember = prefs.getBool('remember_me') ?? false;
    final savedPhone = prefs.getString('saved_phone');
    final savedPassword = prefs.getString('saved_password');

    if (remember && savedPhone != null && savedPassword != null) {

      try {

        final response = await AuthService.loginUser(
          phone: savedPhone,
          password: savedPassword,
        );

        final userData = response['data'];
        final List roles = userData['roles'] ?? [];

        if (!mounted) return;

        if (roles.length == 1) {

          if (roles.first == 'teacher') {

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => TeacherHomeScreen(
                  userData: {
                    ...userData,
                    ...?userData['teacher'],
                  },
                ),
              ),
            );

          } else {

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => ParentHomeScreen(
                  userData: userData,
                ),
              ),
            );
          }

        } else {

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const LoginScreen(),
            ),
          );
        }

      } catch (e) {

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const LoginScreen(),
          ),
        );
      }

    } else {

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}