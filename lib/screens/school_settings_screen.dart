import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import 'school_home_screen.dart';
import 'about_app_screen.dart';
import 'privacy_policy_screen.dart';

class SchoolSettingsScreen extends StatelessWidget {
  const SchoolSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xfff4f6fb),

      body: Column(
        children: [

          /// ================= الهيدر =================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(30, 70, 30, 40),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xff0f2027),
                  Color(0xff203a43),
                  Color(0xff2c5364),
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Row(
              children: [

                /// زر الرجوع
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(width: 15),

                const Text(
                  "الإعدادات",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

              ],
            ),
          ),

          const SizedBox(height: 25),

          /// ================= المحتوى =================
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [

                  _settingCard(
                    title: "عن التطبيق",
                    icon: Icons.info_outline,
                    color: Colors.blue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AboutAppScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 15),

                  _settingCard(
                    title: "سياسة الاستخدام",
                    icon: Icons.privacy_tip_outlined,
                    color: Colors.teal,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PrivacyPolicyScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 15),

                  _settingCard(
                    title: "تواصل معنا",
                    icon: Icons.support_agent,
                    color: Colors.orange,
                    onTap: () {
                        openWhatsApp(context);
                    },
                  ),

                  const SizedBox(height: 15),

                  _settingCard(
                    title: "حذف الحساب",
                    icon: Icons.delete_outline,
                    color: Colors.red,
                    onTap: () {
                      confirmDeleteAccount(context);
                    },
                  ),

                  const SizedBox(height: 30),

                ],
              ),
            ),
          )

        ],
      ),
    );
  }

  /// ================= كرت الإعداد =================
  Widget _settingCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ],
        ),

        child: Row(
          children: [

            /// أيقونة ملونة
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),

            const SizedBox(width: 15),

            /// النص
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            /// سهم
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.black45,
            )

          ],
        ),
      ),
    );
  }

  Future<void> openWhatsApp(BuildContext context) async {

  Flushbar(
    message: "سيتم تحويلك إلى واتساب للتواصل معنا",
    duration: const Duration(seconds: 2),
    backgroundColor: Colors.blue,
    flushbarPosition: FlushbarPosition.TOP,
  ).show(context);

  await Future.delayed(const Duration(seconds: 2));

  String message = Uri.encodeComponent("السلام عليكم، أريد الاستفسار");

  final Uri url = Uri.parse("whatsapp://send?phone=96891365580&text=$message");

  try {
    await launchUrl(url);
  } catch (e) {

    Flushbar(
      message: "تأكد من تثبيت واتساب على الجهاز",
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.red,
      flushbarPosition: FlushbarPosition.TOP,
    ).show(context);

  }
}

void confirmDeleteAccount(BuildContext context) {

  showDialog(
    context: context,
    builder: (context) {

      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
                size: 50,
              ),

              const SizedBox(height: 15),

              const Text(
                "حذف الحساب",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "هل أنت متأكد أنك تريد حذف الحساب؟ لا يمكن التراجع عن هذا الإجراء.",
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              Row(
                children: [

                  /// إلغاء
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("إلغاء"),
                    ),
                  ),

                  const SizedBox(width: 10),

                  /// تأكيد
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        confirmFinalDelete(context);
                      },
                      child: const Text("تأكيد"),
                    ),
                  ),

                ],
              )

            ],
          ),
        ),
      );

    },
  );
}

void confirmFinalDelete(BuildContext context) {

  showDialog(
    context: context,
    builder: (context) {

      return AlertDialog(
        title: const Text("تأكيد نهائي"),
        content: const Text("سيتم حذف الحساب نهائيًا، هل تريد المتابعة؟"),
        actions: [

          TextButton(
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
            },
            child: const Text("تراجع"),
          ),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {

              Navigator.of(context, rootNavigator: true).pop();
              /// هنا لاحقًا API
              deleteAccount(context);

            },
            child: const Text("نعم، احذف"),
          ),

        ],
      );

    },
  );
}

void deleteAccount(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();

  try {
    String phone = prefs.getString('saved_phone') ?? '';
    String password = prefs.getString('saved_password') ?? '';

    /// 🔥 نحفظ navigator قبل أي async
    final navigator = Navigator.of(context, rootNavigator: true);

    /// ================= اللودنج =================
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    /// ================= API =================
    final res = await AuthService.deleteAccount(
      phone: phone,
      password: password,
    );

    /// ================= إغلاق اللودنج =================
    navigator.pop();

    /// ================= الرسالة =================
    Flushbar(
      message: res["message"] ?? "تم حذف الحساب بنجاح",
      duration: const Duration(seconds: 2),
      backgroundColor: Colors.green,
      flushbarPosition: FlushbarPosition.TOP,
    ).show(navigator.context); // 🔥 بدون استخدام context القديم

    /// ================= حذف البيانات =================
    await prefs.clear();

    await Future.delayed(const Duration(seconds: 2));

    /// ================= الانتقال =================
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const SchoolHomeScreen(),
      ),
      (route) => false,
    );

  } catch (e) {

    final navigator = Navigator.of(context, rootNavigator: true);

    navigator.pop();

    Flushbar(
      message: "حدث خطأ أثناء حذف الحساب",
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.red,
      flushbarPosition: FlushbarPosition.TOP,
    ).show(navigator.context);
  }
}

}