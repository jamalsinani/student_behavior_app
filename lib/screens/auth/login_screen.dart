import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:another_flushbar/flushbar.dart';
import '../../core/app_colors.dart';
import '../../services/auth_service.dart';
import '../teacher/teacher_home_screen.dart';
import '../parent/parent_home_screen.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  bool rememberMe = false;

  @override
  void initState() {
    super.initState();
    loadSavedData();
  }

  Future<void> loadSavedData() async {

  final prefs = await SharedPreferences.getInstance();

  final savedPhone = prefs.getString('saved_phone');
  final savedPassword = prefs.getString('saved_password');
  final savedRemember = prefs.getBool('remember_me') ?? false;

  if (savedRemember && savedPhone != null && savedPassword != null) {

    setState(() {
      rememberMe = true; // ✅ مهم جداً
      phoneController.text = savedPhone;
      passwordController.text = savedPassword;
    });

    /// تسجيل الدخول تلقائي
    Future.delayed(const Duration(milliseconds: 300), () {
      login();
    });
  }
}


  void login() async {

    if (phoneController.text.isEmpty || passwordController.text.isEmpty) {
      Flushbar(
      message: "يرجى إدخال جميع البيانات",
      duration: const Duration(seconds: 3),
      flushbarPosition: FlushbarPosition.TOP,
      backgroundColor: Colors.red,
      margin: const EdgeInsets.all(12),
      borderRadius: BorderRadius.circular(12),
      icon: const Icon(Icons.error_outline, color: Colors.white),
      ).show(context);
      return;
    }

    setState(() => isLoading = true);

    try {

      final response = await AuthService.loginUser(
        phone: phoneController.text.trim(),
        password: passwordController.text.trim(),
      );

      final userData = response['data'];
      final List roles = userData['roles'] ?? [];

      /// ✅ حفظ التذكر
      final prefs = await SharedPreferences.getInstance();

/// حفظ حالة تسجيل الدخول
await prefs.setBool('is_logged_in', true);

/// حفظ التذكر
if (rememberMe) {
  await prefs.setString('saved_phone', phoneController.text.trim());
  await prefs.setString('saved_password', passwordController.text.trim());
  await prefs.setBool('remember_me', true);
} else {
  await prefs.remove('saved_phone');
  await prefs.remove('saved_password');
  await prefs.remove('remember_me');
}

      setState(() => isLoading = false);

      if (roles.length == 1) {

        if (roles.first == 'teacher') {

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => TeacherHomeScreen(
                userData: {
                  ...userData,
                  ...?userData['teacher'],
                },
              ),
            ),
            (route) => false,
          );

        } else {

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => ParentHomeScreen(
                userData: userData,
              ),
            ),
            (route) => false,
          );
        }
      }

      else if (roles.length > 1) {

        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(25),
            ),
          ),
          builder: (context) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  const Text(
                    "اختر طريقة الدخول",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  ...roles.map<Widget>((role) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);

                            if (role == 'teacher') {

                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => TeacherHomeScreen(
                                    userData: {
                                      ...userData,
                                      ...?userData['teacher'],
                                    },
                                  ),
                                ),
                                (route) => false,
                              );

                            } else {

                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ParentHomeScreen(
                                    userData: userData,
                                  ),
                                ),
                                (route) => false,
                              );
                            }
                          },
                          child: Text(
                            role == 'teacher'
                                ? "الدخول كمعلم"
                                : "الدخول كولي أمر",
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            );
          },
        );
      }

    } catch (e) {

      setState(() => isLoading = false);

      Flushbar(
      message: e.toString(),
      duration: const Duration(seconds: 3),
      flushbarPosition: FlushbarPosition.TOP,
      backgroundColor: Colors.red,
      margin: const EdgeInsets.all(12),
      borderRadius: BorderRadius.circular(12),
      icon: const Icon(Icons.error_outline, color: Colors.white),
    ).show(context);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.secondary,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [

              const SizedBox(height: 40),

              Container(
                height: 110,
                width: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(40),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [

                        const SizedBox(height: 20),

                        const Text(
                          'تسجيل الدخول',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),

                        const SizedBox(height: 30),

                        TextField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: 'رقم الهاتف',
                            prefixIcon: const Icon(Icons.phone),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'كلمة المرور',
                            prefixIcon: const Icon(Icons.lock),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        /// 🔹 تذكرني
                        Row(
                          children: [
                            Checkbox(
                              value: rememberMe,
                              onChanged: (value) {
                                setState(() {
                                  rememberMe = value ?? false;
                                });
                              },
                            ),
                            const Text("تذكرني"),
                          ],
                        ),

                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : login,
                            child: isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                                    'دخول',
                                    style: TextStyle(fontSize: 18),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            /// تسجيل جديد (يسار)
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RegisterScreen(),
                  ),
                );
              },
              child: const Text(
                'تسجيل جديد',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            /// نسيت كلمة المرور (يمين)
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ForgotPasswordScreen(),
                  ),
                );
              },
              child: const Text(
                "نسيت كلمة المرور؟",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

          ],
        ),

        ],
        ),
        ),
        ),
        ),
        ],
        ),
        ),
        ),
        );
          }
}