import 'package:flutter/material.dart';
import '../services/school_notification_service.dart';

class SchoolSentNotificationsScreen extends StatefulWidget {
  const SchoolSentNotificationsScreen({super.key});

  @override
  State<SchoolSentNotificationsScreen> createState() =>
      _SchoolSentNotificationsScreenState();
}

class _SchoolSentNotificationsScreenState
    extends State<SchoolSentNotificationsScreen> {

  List notifications = [];
  bool isLoading = true;

  int schoolId = 1;

  @override
  void initState() {
    super.initState();
    loadNotifications();
  }

  Future loadNotifications() async {

    try {

      final data =
          await SchoolNotificationService.fetchSentNotifications(schoolId);

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

                InkWell(
                  onTap: (){
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
                  "الإشعارات المرسلة",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                )

              ],
            ),
          ),

          const SizedBox(height: 25),

          /// ================= القائمة =================
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: notifications.length,
                    itemBuilder: (context,index){

                      final item = notifications[index];

                      String name = "إشعار";
                      String sub = "";

                      /// رسائل الطلاب
                      if(item["type"] == "parent"){

                        if(item["send_to"] == "all"){

                          name = "لكل الطلاب";
                          sub = "رسالة جماعية";

                        }else{

                          name = item["student_name"] ?? "طالب";
                          sub = "رسالة لطالب";

                        }

                      }

                      /// رسائل المعلمين
                      if(item["type"] == "teacher"){

                        if(item["send_to"] == "all"){

                          name = "لكل المعلمين";
                          sub = "رسالة جماعية";

                        }else{

                          name = item["teacher_name"] ?? "معلم";
                          sub = "رسالة لمعلم";

                        }

                      }

                      return _notificationCard(
                        name: name,
                        sub: sub,
                        message: item["message"] ?? "",
                        color1: item["type"] == "teacher"
                            ? const Color(0xff7f00ff)
                            : const Color(0xff36d1dc),
                        color2: item["type"] == "teacher"
                            ? const Color(0xffe100ff)
                            : const Color(0xff5b86e5),
                      );

                    },
                  ),
          )

        ],
      ),
    );
  }

  /// ================= بطاقة الإشعار =================
  Widget _notificationCard({
    required String name,
    required String sub,
    required String message,
    required Color color1,
    required Color color2,
  }) {

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color1,color2],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color1.withOpacity(0.35),
            blurRadius: 12,
            offset: const Offset(0,6),
          )
        ],
      ),

      child: Row(
        children: [

          Container(
            height: 45,
            width: 45,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications,
              color: Colors.white,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  sub,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),

              ],
            ),
          )

        ],
      ),
    );
  }

}