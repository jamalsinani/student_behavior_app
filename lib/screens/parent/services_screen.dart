import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'update_student_data_screen.dart';

class ServicesScreen extends StatelessWidget {

  final Map student;

  const ServicesScreen({
    super.key,
    required this.student,
  });

  /// بطاقة الخدمة
  Widget buildServiceCard(
      BuildContext context, {
        required String title,
        required String desc,
        required IconData icon,
        required Color color,
        required VoidCallback onTap,
      }) {

    return GestureDetector(

      onTap: onTap,

      child: Container(

        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

        padding: const EdgeInsets.all(18),

        decoration: BoxDecoration(

          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.9),
              color.withOpacity(0.65),
            ],
          ),

          borderRadius: BorderRadius.circular(22),

          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0,6),
            )
          ],
        ),

        child: Row(
          children: [

            /// الايقونة
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 30,
              ),
            ),

            const SizedBox(width: 14),

            /// النص
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    desc,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 18,
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final colors = Theme.of(context).colorScheme;

    return Scaffold(

      body: Column(
        children: [

          /// HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 65,
              right: 20,
              left: 20,
              bottom: 30,
            ),

            decoration: BoxDecoration(

              gradient: LinearGradient(
                colors: [
                  colors.primary,
                  colors.primaryContainer,
                ],
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
              ),

              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),

            child: Row(
              children: [

                GestureDetector(

                  onTap: () => Navigator.pop(context),

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

                const SizedBox(width: 10),

                const Text(
                  "الخدمات",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: ListView(
              children: [

                /// تحديث البيانات
                buildServiceCard(
                  context,
                  title: "تحديث البيانات",
                  desc: "تعديل بيانات ولي الأمر أو الطالب",
                  icon: Icons.edit_note,
                  color: Colors.blue,
                  onTap: () {

                    Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UpdateStudentDataScreen(
                        studentId: student["id"].toString(),
                      ),
                    ),
                  );

                  },
                ),

                /// عرض الشهادة
                buildServiceCard(
                  context,
                  title: "عرض الشهادة",
                  desc: "عرض شهادة الطالب الدراسية",
                  icon: Icons.workspace_premium,
                  color: Colors.green,
                  onTap: () {},
                ),

                /// الشكاوي
                buildServiceCard(
                  context,
                  title: "الشكاوي والملاحظات",
                  desc: "إرسال ملاحظة أو شكوى للإدارة",
                  icon: Icons.support_agent,
                  color: Colors.orange,
                  onTap: () {},
                ),

                const SizedBox(height: 30),
              ],
            ),
          )
        ],
      ),
    );
  }
  

}