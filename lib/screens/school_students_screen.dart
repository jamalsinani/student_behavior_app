import 'package:flutter/material.dart';
import 'school_send_message_screen.dart';

class SchoolStudentsScreen extends StatelessWidget {
  const SchoolStudentsScreen({super.key});

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
                  borderRadius: BorderRadius.circular(40),
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),

                const SizedBox(width: 15),

                const Text(
                  "الطلاب",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

              ],
            ),
          ),

          const SizedBox(height: 30),

          /// ================= البوكسات =================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [

                /// ارسال لطالب
                _actionCard(
                  icon: Icons.person,
                  title: "إرسال إشعار لطالب",
                  color1: const Color(0xff36d1dc),
                  color2: const Color(0xff5b86e5),
                  onTap: () {

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SchoolSendMessageScreen(),
                      ),
                    );

                  },
                ),

                const SizedBox(height: 20),

                /// ارسال لكل الطلاب
                _actionCard(
                  icon: Icons.groups,
                  title: "إرسال إشعار لكل الطلاب",
                  color1: const Color(0xffff7e5f),
                  color2: const Color(0xfffeb47b),
                  onTap: () {
                    /// سنربطها لاحقاً
                  },
                ),

              ],
            ),
          )

        ],
      ),
    );
  }


  /// ================= تصميم البوكس =================
  Widget _actionCard({
    required IconData icon,
    required String title,
    required Color color1,
    required Color color2,
    required VoidCallback onTap,
  }) {

    return GestureDetector(
      onTap: onTap,

      child: Container(
        height: 120,
        width: double.infinity,

        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color1, color2],
          ),

          borderRadius: BorderRadius.circular(25),

          boxShadow: [
            BoxShadow(
              color: color1.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 6),
            )
          ],
        ),

        child: Row(
          children: [

            const SizedBox(width: 20),

            Container(
              height: 50,
              width: 50,

              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                shape: BoxShape.circle,
              ),

              child: Icon(
                icon,
                color: Colors.white,
                size: 28,
              ),
            ),

            const SizedBox(width: 20),

            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )

          ],
        ),
      ),
    );
  }
}