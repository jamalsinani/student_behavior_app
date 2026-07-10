import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:another_flushbar/flushbar.dart';
import '../../core/app_colors.dart';
import '../../services/auth_service.dart';
import '../teacher/teacher_home_screen.dart';
import '../parent/parent_home_screen.dart';
import '../school_admin_screen.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class LoginScreen extends StatefulWidget {

  final String schoolName;
  final String schoolLogo;

  const LoginScreen({
    super.key,
    this.schoolName = '',
    this.schoolLogo = '',
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  bool rememberMe = false;

  String selectedCountryCode = '968';

  final List<Map<String, String>> countries = [
    {'name': 'عُمان', 'code': '968'},
    {'name': 'السعودية', 'code': '966'},
    {'name': 'الإمارات', 'code': '971'},
    {'name': 'قطر', 'code': '974'},
    {'name': 'البحرين', 'code': '973'},
    {'name': 'الكويت', 'code': '965'},
    {'name': 'مصر', 'code': '20'},
    {'name': 'الأردن', 'code': '962'},
    {'name': 'العراق', 'code': '964'},
    {'name': 'سوريا', 'code': '963'},
  ];

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

        if (phoneController.text.isEmpty ||
        passwordController.text.isEmpty) {
          if (phoneController.text.trim().length < 8) {
            Flushbar(
              message: "يرجى إدخال رقم الهاتف بشكل صحيح",
              duration: const Duration(seconds: 3),
              flushbarPosition: FlushbarPosition.TOP,
              backgroundColor: Colors.red,
              margin: const EdgeInsets.all(12),
              borderRadius: BorderRadius.circular(12),
            ).show(context);
            return;
          }
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

        final String phoneNumber =
        '$selectedCountryCode${phoneController.text.trim()}';
        
        final response = await AuthService.loginUser(
          phone: phoneNumber,
          password: passwordController.text.trim(),
        );

        final userData = response['data'];

        print("================================");
        print(userData);
        print("================================");

        final int userId = userData['id'];
        final List roles = userData['roles'] ?? [];

        final prefs = await SharedPreferences.getInstance();

        await prefs.setString(
          'school_logo',
          userData['school_logo'] ?? '',
        );

        await prefs.setString(
          'school_name',
          userData['school_name'] ?? '',
        );

        await prefs.setString(
          'support_whatsapp',
          userData['support_whatsapp'] ?? '',
        );
        await prefs.setBool('is_logged_in', true);
        await prefs.setStringList(
          'roles',
          roles.map((e) => e.toString()).toList(),
        );
        // ======================================
        // حفظ بيانات المستخدم للاستئذان
        // ======================================

        // رقم المستخدم
        await prefs.setInt(
          'user_id',
          userData['id'],
        );


        // رقم المعلم
        // نستخدم id المستخدم لأنه هو المرتبط بالمعلم
        await prefs.setInt(
          'teacher_id',
          userData['id'],
        );


        // رقم المدرسة
        await prefs.setInt(
          'school_id',
          int.parse(
            userData['school_id'].toString(),
          ),
        );

        print("LOGIN USER ID: $userId");

        try {

          /// 🔥 طلب إذن الإشعارات (مهم جدا للايفون)
          await FirebaseMessaging.instance.requestPermission();

          await AuthService.sendFcmToken(userId);

        } catch (e) {
          print("FCM token error: $e");
        }

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

        /// ادمن
        if (roles.contains('admin')) {

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => const SchoolAdminScreen(),
            ),
            (route) => false,
          );

        }

        /// معلم وولي امر
        else if (roles.contains('teacher') && roles.contains('parent')) {

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

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {

                          Navigator.pop(context);

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

                        },
                        child: const Text("الدخول كمعلم"),
                      ),
                    ),

                    const SizedBox(height: 15),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {

                          Navigator.pop(context);

                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ParentHomeScreen(
                                userData: userData,
                              ),
                            ),
                            (route) => false,
                          );

                        },
                        child: const Text("الدخول كولي أمر"),
                      ),
                    ),

                  ],
                ),
              );
            },
          );

        }

        /// معلم فقط
        else if (roles.contains('teacher')) {

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

        }

        /// ولي امر فقط
        else {

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

              const SizedBox(height: 20),

              Stack(
  alignment: Alignment.center,
  clipBehavior: Clip.none,
  children: [

    /// شعار المنصة
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
            'assets/images/platform_logo.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    ),

    /// شعار المدرسة
    if (widget.schoolLogo.isNotEmpty)
      Positioned(
        top: 50,
        right: -30,
        child: Container(
          width: 46,
          height: 46,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
              ),
            ],
          ),
          child: ClipOval(
            child: Image.network(
              widget.schoolLogo,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
  ],
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

                        const SizedBox(height: 12),

                        FutureBuilder<SharedPreferences>(
                        future: SharedPreferences.getInstance(),
                        builder: (context, snapshot) {

                          if (!snapshot.hasData) {
                            return const SizedBox();
                          }

                          final schoolName = widget.schoolName;

                          if (schoolName.isEmpty) {
                            return const SizedBox();
                          }

                          return Column(
                            children: [

                              const Text(
                                'مخصص لمنسوبي مدرسة',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),

                              const SizedBox(height: 8),

                              Text(
                                schoolName,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),

                              const SizedBox(height: 20),

                            ],
                          );
                        },
                      ),
                        Row(
                          children: [

                            Container(
                                height: 60,
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: selectedCountryCode,
                                    isDense: true,
                                    items: countries.map((country) {
                                      return DropdownMenuItem<String>(
                                        value: country['code'],
                                        child: Text(
                                          "+${country['code']}",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedCountryCode = value!;
                                      });
                                    },
                                  ),
                                ),
                              ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: TextField(
                                controller: phoneController,
                                keyboardType: TextInputType.phone,
                                maxLength: 11,
                                decoration: InputDecoration(
                                  labelText: 'رقم الهاتف',
                                  counterText: '',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                            ),

                          ],
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
          
