import 'package:flutter/material.dart';
import '../../services/parent_service.dart';

class StudentReportsScreen extends StatefulWidget {

  final Map<String, dynamic> student;

  const StudentReportsScreen({
    super.key,
    required this.student,
  });

  @override
  State<StudentReportsScreen> createState() => _StudentReportsScreenState();
}

class _StudentReportsScreenState extends State<StudentReportsScreen> {

  List reports = [];
  List adminReports = [];
  List teacherReports = [];

  bool loading = true;

  String todayName = "";
  String todayDate = "";


  @override
  void initState() {
    super.initState();
    setTodayDate();
    loadReports();
  }

  /// اليوم والتاريخ
  void setTodayDate() {

  final now = DateTime.now();

  const days = [
    "الأحد",
    "الاثنين",
    "الثلاثاء",
    "الأربعاء",
    "الخميس",
    "الجمعة",
    "السبت"
  ];

  /// تحويل weekday ليبدأ من الأحد
  int index = now.weekday % 7;

  todayName = days[index];

  todayDate = "${now.year}/${now.month}/${now.day}";
}

  /// جلب التقارير
  Future loadReports() async {

    try {

      final data = await ParentService.getStudentReports(
        studentId: widget.student["id"].toString(),
      );

      reports = data;

      /// تقسيم التقارير
      adminReports = reports.where((r) =>
      r["source"] == "admin").toList();

      teacherReports = reports.where((r) =>
      r["source"] != "admin").toList();

    } catch (e) {
      print(e);
    }

    setState(() {
      loading = false;
    });
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

                if (report["report_value"] != null)
                  Padding(
                    padding: const EdgeInsets.only(top:6),
                    child: Text(
                      "الدرجة: ${num.parse(report["report_value"].toString()).toInt()}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Row(
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
                      "تقارير اليوم",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    Text(
                      "اليوم : $todayName",
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(width: 20),

                    Text(
                      "التاريخ : $todayDate",
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),

          const SizedBox(height: 10),

          Expanded(

            child: loading
                ? const Center(child: CircularProgressIndicator())

                : ListView(
              children: [

                /// تقارير الإدارة
                if (adminReports.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: Text(
                      "تقارير الإدارة",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  ...adminReports.map(buildReportCard),
                ],

                /// تقارير المعلمين
                if (teacherReports.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: Text(
                      "تقارير المعلمين",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  ...teacherReports.map(buildReportCard),
                ],

                if (reports.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(30),
                      child: Text("لا توجد تقارير اليوم"),
                    ),
                  )
              ],
            ),
          )
        ],
      ),
    );
  }
}