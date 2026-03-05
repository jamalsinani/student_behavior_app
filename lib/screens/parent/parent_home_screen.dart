import 'package:flutter/material.dart';
import '../../services/parent_service.dart';
import 'student_profile_screen.dart';
import '../school_home_screen.dart';

class ParentHomeScreen extends StatefulWidget {

  final Map<String, dynamic> userData;

  const ParentHomeScreen({
    super.key,
    required this.userData,
  });

  @override
  State<ParentHomeScreen> createState() => _ParentHomeScreenState();
}

class _ParentHomeScreenState extends State<ParentHomeScreen> {

  List students = [];
  List notes = [];

  bool isLoading = true;

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "صباح الخير ☀️";
    if (hour < 17) return "مساء الخير 🌤";
    return "مساء الخير 🌙";
  }

  @override
  void initState() {
    super.initState();
    loadStudents();
  }

  Future<void> loadStudents() async {

    try {

      final phone = widget.userData['phone'].toString();
      final schoolId = widget.userData['school_id'].toString();

      final data = await ParentService.getChildren(
        phone: phone,
        schoolId: schoolId,
      );

      setState(() {
        students = data;
        isLoading = false;
      });

    } catch (e) {

      setState(() {
        isLoading = false;
      });

    }
  }

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final parentName = widget.userData['name'] ?? "ولي الأمر";

    return Scaffold(
      backgroundColor: const Color(0xffF4F7FC),

      body: Column(
        children: [

          /// ================= HEADER =================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 60,
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
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(35),
                bottomRight: Radius.circular(35),
              ),
            ),

            child: Row(
              children: [

                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/parent_icon.png',
                      width: 45,
                      height: 45,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text(
                        getGreeting(),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        parentName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        "عدد الأبناء: ${students.length}",
                        style: const TextStyle(
                          color: Colors.white70,
                        ),
                      ),

                    ],
                  ),
                ),

                /// زر الخروج
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(40),
                    onTap: () {

                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SchoolHomeScreen(),
                        ),
                        (route) => false,
                      );

                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.red.withOpacity(0.35),
                        ),
                      ),
                      child: const Icon(
                        Icons.logout_rounded,
                        color: Colors.red,
                        size: 22,
                      ),
                    ),
                  ),
                )

              ],
            ),
          ),

          const SizedBox(height: 20),

          /// ================= الملاحظات =================
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(16),

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                )
              ],
            ),

            child: Row(
              children: [

                Icon(
                  Icons.notifications,
                  color: colors.primary,
                ),

                const SizedBox(width: 10),

                const Text(
                  "الملاحظات",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

              ],
            ),
          ),

          const SizedBox(height: 20),

          /// ================= قائمة الأبناء =================
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: students.length,
              itemBuilder: (context, index) {

                final student = students[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),

                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),

                    onTap: () {

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => StudentProfileScreen(
                            student: student,
                          ),
                        ),
                      );

                    },

                    child: Container(

                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),

                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 12,
                          )
                        ],
                      ),

                      child: Row(
                        children: [

                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.school,
                              color: colors.primary,
                            ),
                          ),

                          const SizedBox(width: 15),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                Text(
                                  student['name'] ?? "",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                Text(
                                  "الصف ${student['class'] ?? '-'} - الشعبة ${student['section'] ?? '-'}",
                                  style: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),

                              ],
                            ),
                          ),

                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: colors.primary,
                          )

                        ],
                      ),
                    ),
                  ),
                );

              },
            ),
          ),

        ],
      ),
    );
  }
}