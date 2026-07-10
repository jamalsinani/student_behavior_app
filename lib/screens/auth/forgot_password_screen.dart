import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
import '../../core/app_colors.dart';
import '../../services/auth_service.dart';
import 'login_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {

  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  bool isLoading = false;

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


  Future<void> sendRequest() async {

  if (emailController.text.trim().isEmpty) {

    Flushbar(
      message: "يرجى إدخال البريد الإلكتروني",
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.red,
      margin: const EdgeInsets.all(12),
      borderRadius: BorderRadius.circular(12),
    ).show(context);

    return;
  }

  if (phoneController.text.trim().length < 7) {

    Flushbar(
      message: "يرجى إدخال رقم الهاتف بشكل صحيح",
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.red,
      margin: const EdgeInsets.all(12),
      borderRadius: BorderRadius.circular(12),
    ).show(context);

    return;
  }

  setState(() => isLoading = true);

  try {

  final result = await AuthService.checkEmailAndPhone(
    email: emailController.text.trim(),
    phone: '$selectedCountryCode${phoneController.text.trim()}',
  );

  setState(() => isLoading = false);

  if (result['status'] == true) {

    showResetPasswordDialog();

  } else {

    Flushbar(
      message: "البريد الإلكتروني أو رقم الهاتف غير صحيح",
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.red,
      margin: const EdgeInsets.all(12),
      borderRadius: BorderRadius.circular(12),
    ).show(context);

  }

} catch (e) {

  setState(() => isLoading = false);

  Flushbar(
    message: "البريد الإلكتروني أو رقم الهاتف غير صحيح",
    duration: const Duration(seconds: 3),
    backgroundColor: Colors.red,
    margin: const EdgeInsets.all(12),
    borderRadius: BorderRadius.circular(12),
  ).show(context);
}
}

  void showResetPasswordDialog() {

  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {

      return AlertDialog(

        title: const Text(
          "تغيير كلمة المرور",
          textAlign: TextAlign.center,
        ),

        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "كلمة المرور الجديدة",
                prefixIcon: Icon(Icons.lock),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "تأكيد كلمة المرور",
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),

          ],
        ),

        actions: [

          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("إلغاء"),
          ),

          ElevatedButton(
            onPressed: () async {

              if (passwordController.text.isEmpty ||
                  confirmPasswordController.text.isEmpty) {

                Flushbar(
                  message: "يرجى إدخال جميع البيانات",
                  duration: const Duration(seconds: 3),
                  backgroundColor: Colors.red,
                  margin: const EdgeInsets.all(12),
                  borderRadius: BorderRadius.circular(12),
                ).show(context);

                return;
              }

              if (passwordController.text !=
                  confirmPasswordController.text) {

                Flushbar(
                  message: "كلمتا المرور غير متطابقتين",
                  duration: const Duration(seconds: 3),
                  backgroundColor: Colors.red,
                  margin: const EdgeInsets.all(12),
                  borderRadius: BorderRadius.circular(12),
                ).show(context);

                return;
              }

              try {

                final result =
                    await AuthService.resetPasswordDirect(

                  email: emailController.text.trim(),
                  phone: '$selectedCountryCode${phoneController.text.trim()}',

                  password: passwordController.text.trim(),

                  passwordConfirmation:
                      confirmPasswordController.text.trim(),
                );

                if (result['status'] == true) {

                  Navigator.of(context, rootNavigator: true).pop();

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LoginScreen(),
                    ),
                    (route) => false,
                  );
                }

              } catch (e) {

                Flushbar(
                  message: "فشل تغيير كلمة المرور",
                  duration: const Duration(seconds: 3),
                  backgroundColor: Colors.red,
                  margin: const EdgeInsets.all(12),
                  borderRadius: BorderRadius.circular(12),
                ).show(context);
              }
            },
            child: const Text("حفظ"),
          ),

        ],
      );
    },
  );
}
  @override
  Widget build(BuildContext context) {

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(

        backgroundColor: AppColors.background,

        appBar: AppBar(
          title: const Text("نسيت كلمة المرور"),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),

        body: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              children: [

                const SizedBox(height: 30),

                const Text(
             "أدخل البريد الإلكتروني ورقم الهاتف المسجلين في النظام",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 30),
                /// 🔑 البريد الإلكتروني
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "البريد الإلكتروني",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// 📱 رقم الهاتف
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
                        labelText: "رقم الهاتف",
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),

                ],
              ),

                const SizedBox(height: 30),

                /// 🔘 زر إرسال الطلب
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : sendRequest,
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "إرسال الطلب",
                            style: TextStyle(fontSize: 18),
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                /// 📢 تنبيه للمستخدم
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.orange.shade100,
                        Colors.orange.shade50,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.orange.shade300),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0,4),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Row(
                        children: const [
                          Icon(Icons.info_outline, color: Colors.orange),
                          SizedBox(width: 8),
                          Text(
                            "تنبيه مهم",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                    

                      const SizedBox(height: 10),

                      const Row(
                        children: [
                          Icon(Icons.check_circle, size: 18, color: Colors.green),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              "أدخل البريد الإلكتروني ورقم الهاتف المسجلين في النظام.",
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      const Row(
                        children: [
                          Icon(Icons.check_circle, size: 18, color: Colors.green),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              "عند تطابق البيانات سيتم السماح لك بتعيين كلمة مرور جديدة مباشرة.",
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      const Row(
                        children: [
                          Icon(Icons.check_circle, size: 18, color: Colors.green),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              "بعد حفظ كلمة المرور الجديدة يمكنك تسجيل الدخول فوراً إلى حسابك.",
                            ),
                          ),
                        ],
                      ),

                      ],
                      ),
                      ),

                      /// 🔙 العودة

                /// 🔙 العودة
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "العودة لتسجيل الدخول",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}