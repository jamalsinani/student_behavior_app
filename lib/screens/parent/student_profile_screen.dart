import 'package:flutter/material.dart';
import '../parent/student_schedule_screen.dart';
import '../parent/student_reports_screen.dart';
import '../parent/services_screen.dart';
import 'student_records_screen.dart';


class StudentProfileScreen extends StatelessWidget {

  final Map<String, dynamic> student;

  const StudentProfileScreen({
    super.key,
    required this.student,
  });

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    print(student);

    return Scaffold(
      body: Column(
        children: [

          /// ===== HEADER =====
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 65,
              right: 20,
              left: 20,
              bottom: 40,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colors.primary,
                  colors.primaryContainer,
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Row(
              children: [

                /// زر الرجوع
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(40),
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                /// عنوان الصفحة
                const Text(
                  "ملف الطالب",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          /// ===== معلومات الطالب =====
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0,6),
                  )
                ],
              ),
              child: Column(
                children: [

                  /// اسم الطالب
                  Row(
                    children: [
                      Icon(Icons.person, color: colors.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          student['name'] ?? "",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  ),

                  const SizedBox(height: 15),

                  /// الصف
                  Row(
                    children: [
                      Icon(Icons.school, color: colors.primary),
                      const SizedBox(width: 10),
                      Text(
                        "الصف: ${student['class'] ?? '-'}",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  /// الشعبة
                  Row(
                    children: [
                      Icon(Icons.class_, color: colors.primary),
                      const SizedBox(width: 10),
                      Text(
                        "الشعبة: ${student['section'] ?? '-'}",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          /// ===== خدمات الطالب =====
const SizedBox(height: 25),

Padding(
  padding: const EdgeInsets.symmetric(horizontal: 20),
  child: GridView.count(
    crossAxisCount: 2,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    crossAxisSpacing: 15,
    mainAxisSpacing: 15,
    childAspectRatio: 1.2,
    children: [

      /// جدول الطالب
      _buildStudentBox(
        context,
        title: "جدول الطالب",
        icon: Icons.calendar_month,
        color: const Color(0xff4CAF50),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StudentScheduleScreen(
                student: student,
              ),
            ),
          );
        },
      ),

      /// التقارير
        _buildStudentBox(
          context,
          title: "التقارير",
          icon: Icons.assessment,
          color: const Color(0xff2196F3),
          onTap: () {

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StudentReportsScreen(
                  student: student,
                ),
              ),
            );

          },
        ),

      /// السجلات
      _buildStudentBox(
            context,
            title: "السجلات",
            icon: Icons.menu_book,
            color: const Color(0xffFF9800),
            onTap: () {

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StudentRecordsScreen(
                    student: student,
                  ),
                ),
              );

            },
          ),
                /// الخدمات
                    _buildStudentBox(
                      context,
                      title: "الخدمات",
                      icon: Icons.miscellaneous_services,
                      color: const Color(0xff9C27B0),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ServicesScreen(
                              student: student,
                            ),
                          ),
                        );
                      },
                    ),
                    ],
                  ),
                ),

                ],
              ),
            );
          }

  /// =================================
/// كرت خدمات الطالب
/// =================================
Widget _buildStudentBox(
  BuildContext context, {
  required String title,
  required IconData icon,
  required Color color,
  VoidCallback? onTap,
}) {

  return Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              color,
              color.withOpacity(0.7),
            ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0,6),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Icon(
              icon,
              color: Colors.white,
              size: 34,
            ),

            const SizedBox(height: 12),

            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            )

          ],
        ),
      ),
    ),
  );

}


}