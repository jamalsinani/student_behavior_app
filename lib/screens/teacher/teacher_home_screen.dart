import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../services/teacher_home_service.dart';
import 'teacher_timetable_screen.dart';
import 'teacher_classes_screen.dart';
import '../auth/login_screen.dart';
import 'package:quickalert/quickalert.dart';
import 'teacher_profile_screen.dart';
import 'teacher_records_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:another_flushbar/flushbar.dart';

class TeacherHomeScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const TeacherHomeScreen({super.key, this.userData});

  @override
  State<TeacherHomeScreen> createState() =>
      _TeacherHomeScreenState();
}

class _TeacherHomeScreenState
    extends State<TeacherHomeScreen> {

  List notes = [];
  List coverages = [];
  List swapRequests = [];
  List swapResponses = [];
  bool isLoading = true;

  final PageController _notesController =
      PageController(viewportFraction: 0.9);

  final PageController _coverageController =
      PageController(viewportFraction: 0.9);

  @override
  void initState() {
    super.initState();
    loadData();
  }
  
  Future<void> updateSwapStatus(
  int id,
  String status,
  int index,
) async {

  try {

    final schoolId =
        int.parse(widget.userData?['school_id'].toString() ?? "1");

    final uri = Uri.parse(
      "https://abuobaida-edu.com/api/teacher/update-swap-status",
    ).replace(queryParameters: {
      "id": id.toString(),
      "status": status,
      "school_id": schoolId.toString(),
    });

    final response = await http.post(uri);

    final data = jsonDecode(response.body);

    if (data["status"] == true) {

      setState(() {
        swapRequests.removeAt(index);
      });

      /// 🔔 رسالة عصرية حديثة
      Flushbar(
        margin: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(20),
        duration: const Duration(seconds: 3),
        flushbarPosition: FlushbarPosition.TOP,
        backgroundGradient: LinearGradient(
          colors: status == "approved"
              ? [Colors.green.shade600, Colors.green.shade400]
              : [Colors.red.shade600, Colors.red.shade400],
        ),
        icon: Icon(
          status == "approved"
              ? Icons.check_circle
              : Icons.cancel,
          color: Colors.white,
          size: 28,
        ),
        titleText: Text(
          status == "approved"
              ? "تم اعتماد التبديل"
              : "تم رفض الطلب",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        messageText: Text(
          data["message"] ?? "",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
      ).show(context);

    } else {

      Flushbar(
        margin: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(20),
        duration: const Duration(seconds: 3),
        flushbarPosition: FlushbarPosition.TOP,
        backgroundColor: Colors.orange.shade600,
        icon: const Icon(
          Icons.warning_amber_rounded,
          color: Colors.white,
        ),
        messageText: Text(
          data["message"] ?? "حدث خطأ غير متوقع",
          style: const TextStyle(color: Colors.white),
        ),
      ).show(context);
    }

  } catch (e) {

    Flushbar(
      margin: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(20),
      duration: const Duration(seconds: 3),
      flushbarPosition: FlushbarPosition.TOP,
      backgroundColor: Colors.red.shade700,
      icon: const Icon(
        Icons.error_outline,
        color: Colors.white,
      ),
      messageText: const Text(
        "تعذر الاتصال بالخادم",
        style: TextStyle(color: Colors.white),
      ),
    ).show(context);
  }
}

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "صباح الخير ☀️";
    if (hour < 17) return "مساء الخير 🌤";
    return "مساء الخير 🌙";
  }
  
  String getDayName(int? day) {
  switch (day) {
    case 1:
      return "الأحد";
    case 2:
      return "الاثنين";
    case 3:
      return "الثلاثاء";
    case 4:
      return "الأربعاء";
    case 5:
      return "الخميس";
    default:
      return "-";
  }
}

  Future<void> loadData() async {
    setState(() => isLoading = true);

    try {
      final phone =
          widget.userData?['phone']?.toString() ?? "";

      final schoolId =
          int.tryParse(
                  widget.userData?['school_id']
                          ?.toString() ??
                      "1") ??
              1;

      final data =
          await TeacherHomeService.getTodayData(
        teacherPhone: phone,
        schoolId: schoolId,
      );

      setState(() {
        notes = List.from(data['notes'] ?? []);
        coverages = List.from(data['coverages'] ?? []);
        swapRequests =
            List.from(data['swap_requests'] ?? []);
            swapResponses = List.from(data['swap_responses'] ?? []);
        isLoading = false;
      });

    } catch (e) {
      print("HOME ERROR: $e");
      setState(() => isLoading = false);
    }
  }
   
  Future<void> handleSwapStatus(
    int id,
    String status,
    int index,
) async {

  try {

    final result =
        await TeacherHomeService.updateSwapStatus(
      id: id,
      status: status,
      schoolId: int.parse(
          widget.userData?['school_id'].toString() ?? "1"),
    );

    if (result["status"] == true) {

      setState(() {
        swapRequests.removeAt(index);
      });

      QuickAlert.show(
        context: context,
        type: status == "approved"
            ? QuickAlertType.success
            : QuickAlertType.error,
        title: status == "approved"
            ? "تمت الموافقة"
            : "تم الرفض",
        text: result["message"],
      );
    }

  } catch (e) {
    print("ERROR: $e");
  }
}


  @override
  Widget build(BuildContext context) {

    final teacherName =
        widget.userData?['teacher_name'] ??
            widget.userData?['name'] ??
            "المعلم";

    final subjectName =
        widget.userData?['subject_name'] ??
            "غير محدد";

    return Scaffold(
      backgroundColor:
          const Color(0xffF3F6FB),
      body: Column(
        children: [

          /// ================= HEADER =================
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.only(
                    top: 60,
                    right: 20,
                    left: 20,
                    bottom: 40),
            decoration:
                const BoxDecoration(
              gradient:
                  LinearGradient(
                colors: [
                  AppColors
                      .teacherPrimary,
                  AppColors
                      .teacherSecondary,
                ],
                begin:
                    Alignment.topRight,
                end: Alignment
                    .bottomLeft,
              ),
              borderRadius:
                  BorderRadius.only(
                bottomLeft:
                    Radius.circular(
                        45),
                bottomRight:
                    Radius.circular(
                        45),
              ),
            ),
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [

                Expanded(
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 34,
                        backgroundColor:
                            Colors.white,
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/omani_teacher.png',
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              getGreeting(),
                              style: const TextStyle(
                                  color: Colors.white70),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              teacherName,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight:
                                      FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              subjectName,
                              style: const TextStyle(
                                  color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius:
                        BorderRadius.circular(40),
                    onTap: _confirmLogout,
                    child: Container(
                      padding:
                          const EdgeInsets.all(12),
                      decoration:
                          BoxDecoration(
                        color: Colors.white
                            .withOpacity(0.18),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white
                              .withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.logout_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: isLoading
                ? const Center(
                    child:
                        CircularProgressIndicator(),
                  )
                : ListView(
                    padding:
                        const EdgeInsets.symmetric(
                            horizontal: 20),
                    children: [

                      /// ================= تنبيهات اليوم =================
                      const Text(
                        "تنبيهات اليوم",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 15),

                      SizedBox(
  height: 145,
  child: (notes.isEmpty &&
          coverages.isEmpty &&
          swapRequests.isEmpty &&
          swapResponses.isEmpty)
      ? Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(25),
          ),
          child: const Text(
            "لا توجد تنبيهات اليوم 🎉",
            style: TextStyle(color: Colors.grey),
          ),
        )
      : PageView.builder(
          controller:
              PageController(viewportFraction: 0.92),
          itemCount:
              swapRequests.length +
              swapResponses.length +
              coverages.length +
              notes.length,
          itemBuilder: (context, index) {

                                  /// 1️⃣ طلبات التبديل
                                 /// 1️⃣ طلبات التبديل
if (index < swapRequests.length) {

  final item = swapRequests[index];

  return Container(
    margin: const EdgeInsets.only(right: 12),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Colors.deepPurple.withOpacity(0.9),
          Colors.deepPurple.withOpacity(0.7),
        ],
      ),
      borderRadius: BorderRadius.circular(30),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        /// 🔥 العنوان + الأيقونات في الأعلى
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Expanded(
              child: Text(
                "طلب تبديل حصة - مادة ${item['subject_name'] ?? ''}",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),

            Row(
              children: [

                InkWell(
                  onTap: () {
                    updateSwapStatus(
                      int.parse(item['id'].toString()),
                      "approved",
                      index,
                    );
                  },
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4),
                      ),
                    ),
                    child: const Icon(
                      Icons.thumb_up_alt_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                InkWell(
                  onTap: () {
                    updateSwapStatus(
                      int.parse(item['id'].toString()),
                      "rejected",
                      index,
                    );
                  },
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4),
                      ),
                    ),
                    child: const Icon(
                      Icons.thumb_down_alt_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 10),

        /// الصف والشعبة
        Row(
          children: [
            const Icon(Icons.school,
                color: Colors.white70,
                size: 14),
            const SizedBox(width: 6),
            Text(
              "الصف ${item['grade']} - شعبة ${item['section']}",
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        /// الحصة الأصلية
        Row(
          children: [
            const Icon(Icons.access_time,
                color: Colors.white70,
                size: 14),
            const SizedBox(width: 6),
            Text(
              "الأصلية: ${getDayName(int.tryParse(item['original_day'].toString()))} - حصة ${item['original_period']}",
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        /// الحصة المطلوبة
        Row(
          children: [
            const Icon(Icons.swap_horiz,
                color: Colors.white70,
                size: 14),
            const SizedBox(width: 6),
            Text(
              "المطلوبة: ${getDayName(int.tryParse(item['target_day'].toString()))} - حصة ${item['target_period']}",
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}


// =========================================================
// 2️⃣ ردود طلباتي (للمعلم الأصلي)
// =========================================================
if (index <
    swapRequests.length +
        swapResponses.length) {

  final item =
      swapResponses[index -
          swapRequests.length];

  final bool isApproved =
      item['status'] == 'approved';

  return Container(
    margin: const EdgeInsets.only(right: 12),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: isApproved
            ? [
                Colors.green.withOpacity(0.9),
                Colors.green.withOpacity(0.7),
              ]
            : [
                Colors.red.withOpacity(0.9),
                Colors.red.withOpacity(0.7),
              ],
      ),
      borderRadius: BorderRadius.circular(30),
    ),
    child: Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [

        /// 🔥 العنوان
        Row(
          children: [
            Icon(
              isApproved
                  ? Icons.thumb_up
                  : Icons.thumb_down,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isApproved
                    ? "تم قبول طلب التبديل"
                    : "تم رفض طلب التبديل",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        /// المادة
        Text(
          "مادة ${item['subject_name'] ?? ''}",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        /// الصف والشعبة
        Row(
          children: [
            const Icon(Icons.school,
                color: Colors.white70,
                size: 14),
            const SizedBox(width: 6),
            Text(
              "الصف ${item['grade']} - شعبة ${item['section']}",
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        /// اليوم + الحصة
        Row(
          children: [
            const Icon(Icons.access_time,
                color: Colors.white70,
                size: 14),
            const SizedBox(width: 6),
            Text(
  "${getDayName(int.tryParse(item['original_day'].toString()))} - الحصة ${item['original_period']} "
  "// ${getDayName(int.tryParse(item['target_day'].toString()))} - الحصة ${item['target_period']}",
  style: const TextStyle(
    color: Colors.white70,
    fontSize: 13,
  ),
),
          ],
        ),
      ],
    ),
  );
}


                                  /// 2️⃣ التغطيات
if (index <
    swapRequests.length +
    swapResponses.length +
    coverages.length) {

  final item =
      coverages[index -
    swapRequests.length -
    swapResponses.length];

  return Container(
    margin: const EdgeInsets.only(right: 12),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Colors.red.withOpacity(0.9),
          Colors.red.withOpacity(0.7),
        ],
      ),
      borderRadius: BorderRadius.circular(30),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        /// 🔥 العنوان
        Text(
          "تغطية حصة - مادة ${item['subject_name'] ?? ''}",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),

        const SizedBox(height: 14),

        /// الصف والشعبة
        Row(
          children: [
            const Icon(Icons.school,
                color: Colors.white70, size: 14),
            const SizedBox(width: 6),
            Text(
              "الصف ${item['grade']} - شعبة ${item['section']}",
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        /// رقم الحصة
        Row(
          children: [
            const Icon(Icons.access_time,
                color: Colors.white70, size: 14),
            const SizedBox(width: 6),
            Text(
              "الحصة ${item['period_number']}",
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        /// تاريخ التغطية
        Row(
          children: [
            const Icon(Icons.calendar_today,
                color: Colors.white70, size: 14),
            const SizedBox(width: 6),
            Text(
              "التاريخ ${item['coverage_date']}",
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
                                  /// 3️⃣ الملاحظات
                                  final note = notes[
  index -
  swapRequests.length -
  swapResponses.length -
  coverages.length
];

                                  return Container(
                                    margin:
                                        const EdgeInsets
                                                .only(
                                            right:
                                                12),
                                    padding:
                                        const EdgeInsets
                                                .all(
                                            20),
                                    decoration:
                                        BoxDecoration(
                                      gradient:
                                          LinearGradient(
                                        colors: [
                                          Colors.orange
                                              .withOpacity(
                                                  0.85),
                                          Colors.orange
                                              .withOpacity(
                                                  0.65),
                                        ],
                                      ),
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                                  30),
                                    ),
                                    child:
                                        Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                      children: [
                                        const Text(
                                          "ملاحظة إدارية",
                                          style:
                                              TextStyle(
                                            color:
                                                Colors.white,
                                            fontWeight:
                                                FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(
                                            height:
                                                8),
                                        Text(
                                          note['note'] ??
                                              '',
                                          style:
                                              const TextStyle(
                                            color:
                                                Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),

                      const SizedBox(height: 20),

                      /// ================= الخدمات =================
                      const Text(
                        "الخدمات",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight:
                                FontWeight.bold),
                      ),

                      const SizedBox(height: 8),

                      GridView.count(
                        padding: EdgeInsets.zero,
                        crossAxisCount: 2,
                        crossAxisSpacing: 18,
                        mainAxisSpacing: 18,
                        shrinkWrap: true,
                        physics:
                            const NeverScrollableScrollPhysics(),
                        children: [

                          _buildServiceCard(
                            icon:
                                Icons.calendar_today,
                            title:
                                "جدول المعلم",
                            color:
                                Colors.indigo,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) =>
                                          TeacherTimetableScreen(
                                    userData:
                                        widget
                                            .userData,
                                  ),
                                ),
                              );
                            },
                          ),

                          _buildServiceCard(
                            icon:
                                Icons.class_,
                            title:
                                "الفصول الدراسية",
                            color:
                                Colors.teal,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) =>
                                          TeacherClassesScreen(
                                    userData:
                                        widget
                                            .userData,
                                  ),
                                ),
                              );
                            },
                          ),

                          _buildServiceCard(
                            icon:
                                Icons.archive_rounded,
                            title:
                                "السجلات",
                            color:
                                Colors.deepPurple,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) =>
                                          TeacherRecordsScreen(
                                    userData:
                                        widget
                                            .userData,
                                  ),
                                ),
                              );
                            },
                          ),

                          _buildServiceCard(
                            icon:
                                Icons.person,
                            title:
                                "الملف الشخصي",
                            color:
                                Colors.orange,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) =>
                                          TeacherProfileScreen(
                                    userData:
                                        widget
                                            .userData,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius:
          BorderRadius.circular(30),
      onTap: onTap,
      child: Container(
        decoration:
            BoxDecoration(
          gradient:
              LinearGradient(
            colors: [
              color.withOpacity(0.9),
              color.withOpacity(0.7),
            ],
          ),
          borderRadius:
              BorderRadius.circular(30),
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 35,
                color: Colors.white),
            const SizedBox(height: 15),
            Text(
              title,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight:
                      FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _infoRow({
  required IconData icon,
  required String text,
}) {
  return Row(
    children: [
      Icon(icon,
          size: 16,
          color: Colors.grey.shade600),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.black87,
          ),
        ),
      ),
    ],
  );
}

  void _confirmLogout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (_) =>
              const LoginScreen()),
    );
  }
}