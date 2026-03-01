import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/widgets/app_card.dart';

class ParentHomeScreen extends StatelessWidget {

  final Map<String, dynamic> userData;

  const ParentHomeScreen({
    super.key,
    required this.userData,
  });

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "صباح الخير ☀️";
    if (hour < 17) return "مساء الخير 🌤";
    return "مساء الخير 🌙";
  }

  @override
  Widget build(BuildContext context) {

    final parentName =
    userData['account_type'] == 'parent'
        ? "ولي الأمر"
        : (userData['name'] ?? "المستخدم");
    final List students = userData['students'] ?? [];

    return Scaffold(
      body: Column(
        children: [

          /// 🔹 HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 60,
              right: 20,
              left: 20,
              bottom: 30,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.parentPrimary,
                  AppColors.parentSecondary,
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
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
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.notifications_none,
                    color: Colors.white,
                  ),
                )
              ],
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView(
                children: [

                  /// 🔹 ملاحظات عامة
                  AppCard(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "ملاحظات اليوم",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              "لا توجد ملاحظات جديدة",
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          Icons.note_alt_outlined,
                          size: 32,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// 🔹 قائمة الأبناء
                  const Text(
                    "أبناؤك في المدرسة",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  if (students.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          "لا يوجد أبناء مسجلين",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),

                  ...students.map((student) {

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AppCard(
                        child: Row(
                          children: [

                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.person,
                                color: AppColors.primary,
                              ),
                            ),

                            const SizedBox(width: 15),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    student['name'],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    "عرض السجل السلوكي",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey,
                            )

                          ],
                        ),
                      ),
                    );

                  }).toList(),

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}