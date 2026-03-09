import 'package:flutter/material.dart';
import '../../services/parent_service.dart';

class StudentRecordsScreen extends StatefulWidget {

  final Map<String, dynamic> student;

  const StudentRecordsScreen({
    super.key,
    required this.student,
  });

  @override
  State<StudentRecordsScreen> createState() => _StudentRecordsScreenState();
}

class _StudentRecordsScreenState extends State<StudentRecordsScreen> {

  List reports = [];
  List adminMessages = [];
  bool loading = true;

  Map<String, List> groupedReports = {};

  @override
  void initState() {
    super.initState();
    loadReports();
  }

  /// جلب التقارير
  Future loadReports() async {

  try {

    final reportsData = await ParentService.getStudentReportsHistory(
      studentId: widget.student["id"].toString(),
    );

    final messagesData = await ParentService.getParentMessages(
      studentId: widget.student["id"].toString(),
      schoolId: widget.student["school_id"].toString(),
    );

    reports = reportsData;
    adminMessages = messagesData;

    /// دمج الرسائل مع التقارير
    String today = DateTime.now().toString().substring(0,10);

      for (var msg in adminMessages) {

        String date = msg["created_at"].toString().substring(0,10);

        /// لا نضيف رسائل اليوم للسجلات
        if (date != today) {

          reports.add({
            "report_date": date,
            "report_title": msg["title"],
            "report_text": msg["message"],
            "report_type": "admin",
          });

        }

      }

    groupReportsByDate();

  } catch (e) {

    print("ERROR:");
    print(e);

  }

  setState(() {
    loading = false;
  });

}

  /// تجميع التقارير حسب التاريخ
  void groupReportsByDate() {

    groupedReports.clear();

    for (var report in reports) {

      String date = report["report_date"] ?? "غير معروف";

      if (!groupedReports.containsKey(date)) {
        groupedReports[date] = [];
      }

      groupedReports[date]!.add(report);
    }
  }

  /// أيقونات التقارير
  IconData getIcon(String type) {

    switch (type) {

      case "star":
        return Icons.star;

      case "grade":
        return Icons.bar_chart;

      case "note":
        return Icons.edit_note;

      case "absence_period":
        return Icons.cancel;

      case "behavior":
        return Icons.warning;

      case "tardy":
        return Icons.access_time;

      default:
        return Icons.info;
    }
  }

  /// ألوان التقارير
  Color getColor(String type) {

    switch (type) {

      case "star":
        return Colors.amber;

      case "grade":
        return Colors.blue;

      case "note":
        return Colors.teal;

      case "absence_period":
        return Colors.red;

      case "behavior":
        return Colors.orange;

      case "tardy":
        return Colors.deepPurple;

      default:
        return Colors.grey;
    }
  }

  Widget buildReportCard(report) {

    final type = report["report_type"] ?? "";
    final color = getColor(type);

    return Container(
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
            color: color.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0,6),
          )
        ],
      ),

      child: Row(
        children: [

          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              getIcon(type),
              color: Colors.white,
              size: 30,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  report["report_title"] ?? "",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                if (report["subject_name"] != null)
                  Text(
                    "المادة: ${report["subject_name"]}",
                    style: const TextStyle(color: Colors.white70),
                  ),

                if (report["period_number"] != null)
                  Text(
                    "الحصة: ${report["period_number"]}",
                    style: const TextStyle(color: Colors.white70),
                  ),

                if (report["report_text"] != null)
                  Padding(
                    padding: const EdgeInsets.only(top:6),
                    child: Text(
                      report["report_text"],
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }

  /// اسم اليوم
  String getDayName(String date) {

    try {

      DateTime d = DateTime.parse(date);

      const days = [
        "الأحد",
        "الاثنين",
        "الثلاثاء",
        "الأربعاء",
        "الخميس",
        "الجمعة",
        "السبت"
      ];

      return days[d.weekday % 7];

    } catch(e) {
      return "";
    }
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
                  "سجل التقارير",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
                child: loading
    ? const Center(child: CircularProgressIndicator())

          /// في حال لا توجد سجلات
          : reports.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: Text(
                      "لا توجد سجلات لهذا الطالب",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                )

        /// عرض السجلات مجمعة حسب التاريخ
                : ListView(
              children: groupedReports.entries.map((entry) {

                String date = entry.key;
                List dayReports = entry.value;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// اليوم والتاريخ
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10),
                      child: Row(
                        children: [

                          Text(
                            getDayName(date),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(width: 10),

                          Text(
                            date,
                            style: TextStyle(
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),

                    /// التقارير
                    ...dayReports.map(buildReportCard).toList(),

                  ],
                );

              }).toList(),
            ),
          )
        ],
      ),
    );
  }
}