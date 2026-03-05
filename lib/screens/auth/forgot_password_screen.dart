import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
import '../../core/app_colors.dart';
import '../../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {

  final TextEditingController phoneController = TextEditingController();
  bool isLoading = false;

  Future<void> sendRequest() async {

    if (phoneController.text.isEmpty) {

      Flushbar(
  message: "يرجى إدخال رقم الهاتف",
  duration: const Duration(seconds: 3),
  backgroundColor: Colors.red,
  margin: const EdgeInsets.all(12),
  borderRadius: BorderRadius.circular(12),
  ).show(context);

      return;
    }

    setState(() => isLoading = true);

    try {

      final result = await AuthService.forgotPassword(
        phone: phoneController.text.trim(),
      );

      setState(() => isLoading = false);

        String message = result["message"] ?? "تم إرسال الطلب بنجاح";

        Color flushColor = Colors.green;
        IconData icon = Icons.check_circle;

        /// إذا كان الطلب موجود مسبقاً
        if (message.contains("قيد") || message.contains("مسبق")) {
          message = "تم إرسال الطلب مسبقاً وهو قيد المراجعة";
          flushColor = Colors.orange;
          icon = Icons.info;
        }

        await Flushbar(
          message: message,
          duration: const Duration(seconds: 3),
          flushbarPosition: FlushbarPosition.TOP,
          backgroundColor: flushColor,
          icon: Icon(icon, color: Colors.white),
          margin: const EdgeInsets.all(12),
          borderRadius: BorderRadius.circular(12),
        ).show(context);

        Navigator.pop(context);

    } catch (e) {

      setState(() => isLoading = false);

      Flushbar(
        message: "حدث خطأ أثناء إرسال الطلب",
        duration: const Duration(seconds: 3),
        flushbarPosition: FlushbarPosition.TOP,
        backgroundColor: Colors.red,
        margin: const EdgeInsets.all(12),
        borderRadius: BorderRadius.circular(12),
      ).show(context);
    }
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
                  "أدخل رقم الهاتف المسجل في النظام",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 30),

                /// 📱 رقم الهاتف
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: "رقم الهاتف",
                    prefixIcon: const Icon(Icons.phone),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
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