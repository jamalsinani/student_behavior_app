import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/school_notification_service.dart';
import 'school_home_screen.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'school_records_screen.dart';
import 'school_send_message_screen.dart';
import 'school_send_teacher_message_screen.dart';
import 'school_sent_notifications_screen.dart';

class SchoolAdminScreen extends StatefulWidget {
  const SchoolAdminScreen({super.key});

  @override
  State<SchoolAdminScreen> createState() => _SchoolAdminScreenState();
}

class _SchoolAdminScreenState extends State<SchoolAdminScreen> {

  List notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadNotifications();
  }

  Future<void> loadNotifications() async {

    try {

      final data =
          await SchoolNotificationService.fetchNotifications(1);

      setState(() {
        notifications = data;
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

    return Scaffold(
      backgroundColor: const Color(0xfff4f6fb),

      body: SingleChildScrollView(
        child: Column(
          children: [

            /// ================= الهيدر =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 50),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xff0f2027),
                    Color(0xff203a43),
                    Color(0xff2c5364),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
              ),
              child: Column(
                children: [

                  Align(
                    alignment: Alignment.topLeft,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(40),
                      onTap: () async {

                        final prefs = await SharedPreferences.getInstance();

                        await prefs.remove('is_logged_in');
                        await prefs.remove('saved_phone');
                        await prefs.remove('saved_password');
                        await prefs.remove('remember_me');

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
                          color: Colors.white.withOpacity(0.18),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.logout_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ),

                  const CircleAvatar(
                    radius: 40,
                    backgroundImage:
                        AssetImage("assets/images/default_school.png"),
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    "مدرسة الشيخ ابو عبيدة عبدالله بن محمد البلوشي",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "إدارة المدرسة",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            /// ================= الإشعارات =================
            _sectionTitle("الإشعارات"),
const SizedBox(height: 15),

Padding(
  padding: const EdgeInsets.symmetric(horizontal: 20),
  child: isLoading
      ? const Center(child: CircularProgressIndicator())
      : Builder(
          builder: (context) {

            List messageNotifications =
                notifications.where((e) => e["source"] == "parent_message").toList();

            List swapNotifications =
                notifications.where((e) => e["source"] == "swap_request").toList();

            /// إزالة التكرار
            Map uniqueSwap = {};

            for (var item in swapNotifications) {
              uniqueSwap[item["id"]] = item;
            }

            swapNotifications = uniqueSwap.values.toList();

            List sliderItems = [
              ...messageNotifications,
              ...swapNotifications
            ];

            return CarouselSlider(
              options: CarouselOptions(
                height: 150,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 4),
                enlargeCenterPage: true,
                viewportFraction: 0.9,
              ),
              items: sliderItems.map((item) {

                bool isSwap =
                    item["source"] == "swap_request";

                return Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isSwap
                          ? [
                              const Color(0xfff7971e),
                              const Color(0xffffd200)
                            ]
                          : [
                              const Color(0xff2193b0),
                              const Color(0xff6dd5ed)
                            ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 10,
                      )
                    ],
                  ),
                  child: Row(
                    children: [

                      Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isSwap
                              ? Icons.swap_horiz
                              : Icons.mail,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),

                      const SizedBox(width: 15),

                      Expanded(
                        child: isSwap
                            ? Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [

                                  const Text(
                                    "طلب تبديل حصة",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  Row(
                                    children: [

                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [

                                            const Text(
                                              "المعلم الأصلي",
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.white70),
                                            ),

                                            Text(
                                              item["original_teacher"] ?? "-",
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(fontSize: 13, color: Colors.white),
                                            ),

                                            Text(
                                              "الحصة ${item["original_period"] ?? "-"}",
                                              style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.white70),
                                            ),
                                          ],
                                        ),
                                      ),

                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 10),
                                        child: Container(
                                          width: 1,
                                          height: 40,
                                          color: Colors.white30,
                                        ),
                                      ),

                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [

                                            const Text(
                                              "المعلم البديل",
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.white70),
                                            ),

                                            Text(
                                              item["replacement_teacher"] ?? "-",
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(fontSize: 13, color: Colors.white),
                                            ),

                                            Text(
                                              "الحصة ${item["target_period"] ?? "-"}",
                                              style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.white70),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            : Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [

                                  Text(
                                    item["student_name"] ??
                                        item["title"] ??
                                        "",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Colors.white,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  Text(
                                    "${item["class"] ?? ""} - ${item["section"] ?? ""}",
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),

                                  const SizedBox(height: 6),

                                  Row(
                                    children: [

                                      Expanded(
                                        child: Text(
                                          item["message"] ?? "",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),

                                      const SizedBox(width: 10),

                                      GestureDetector(
                                        onTap: () {
                                          _showMessageDialog(item);
                                        },
                                        child: Container(
                                          padding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 10,
                                                  vertical: 5),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: const Text(
                                            "عرض",
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      )

                                    ],
                                  )

                                ],
                              ),
                      )

                    ],
                  ),
                );

              }).toList(),
            );
          },
        ),
),

const SizedBox(height: 30),
            /// ================= الإجراءات =================
            _sectionTitle("الإجراءات"),

            const SizedBox(height: 15),

            Padding(
  padding: const EdgeInsets.symmetric(horizontal: 20),
  child: Column(
    children: [

      /// الصف الأول
      Row(
        children: [

          Expanded(
            child: _actionCard(
              icon: Icons.school,
              title: "اشعارات الطلاب",
              color: Colors.green,
              onTap: () {

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SchoolSendMessageScreen(),
                  ),
                );

              },
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: _actionCard(
              icon: Icons.person,
              title: "اشعارات المعلمين",
              color: const Color(0xff203a43),
              onTap: () {

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SchoolSendTeacherMessageScreen(),
                  ),
                );

              },
            ),
          ),

        ],
      ),

      const SizedBox(height: 15),

      /// الصف الثاني
      Row(
        children: [

          Expanded(
            child: _actionCard(
              icon: Icons.notifications,
              title: "الإشعارت المرسلة",
              color: Colors.orange,
              onTap: () {

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SchoolSentNotificationsScreen(),
                  ),
                );

              },
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: _actionCard(
              icon: Icons.archive,
              title: "الإشعارات المستقبلة",
              color: Colors.deepPurple,
              onTap: () {

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SchoolRecordsScreen(),
                  ),
                );

              },
            ),
          ),

        ],
      ),

    ],
  ),
),

            const SizedBox(height: 40),

          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

  }

  Widget _actionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.7)],
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Icon(icon, color: Colors.white, size: 28),

            const SizedBox(height: 10),

            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            )

          ],
        ),
      ),
    );

  }

  void _showMessageDialog(dynamic item) {

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
                Icons.mail_outline,
                size: 40,
                color: Colors.blue,
              ),

              const SizedBox(height: 10),

              Text(
                item["student_name"] ??
                item["title"] ??
                "",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                item["message"] ?? "",
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("إغلاق"),
              )

            ],
          ),
        ),
      );

    },
  );

}

}