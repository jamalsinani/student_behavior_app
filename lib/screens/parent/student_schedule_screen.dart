import 'package:flutter/material.dart';
import '../../services/parent_service.dart';

class StudentScheduleScreen extends StatefulWidget {

  final Map<String, dynamic> student;

  const StudentScheduleScreen({
    super.key,
    required this.student,
  });

  @override
  State<StudentScheduleScreen> createState() => _StudentScheduleScreenState();
}

class _StudentScheduleScreenState extends State<StudentScheduleScreen> {

  @override
  void initState() {
    super.initState();
    loadSchedule();
  }

  /// اليوم المختار (الأحد → الخميس فقط)
int selectedDay = () {
  int day = DateTime.now().weekday;

  // الجمعة أو السبت → يرجع الأحد
  if (day == DateTime.friday || day == DateTime.saturday) {
    return 1;
  }

  // تحويل نظام الأيام ليبدأ من الأحد
  if (day == DateTime.sunday) return 1;
  if (day == DateTime.monday) return 2;
  if (day == DateTime.tuesday) return 3;
  if (day == DateTime.wednesday) return 4;
  if (day == DateTime.thursday) return 5;

  return 1;
}();

  /// أيام الأسبوع
  final List<Map<String, dynamic>> days = [
    {"name": "الأحد", "value": 1},
    {"name": "الاثنين", "value": 2},
    {"name": "الثلاثاء", "value": 3},
    {"name": "الأربعاء", "value": 4},
    {"name": "الخميس", "value": 5},
  ];

  List schedule = [];
  bool loading = false;

  Future<void> loadSchedule() async {

    setState(() {
      loading = true;
    });

    final data = await ParentService.getStudentSchedule(
      schoolId: widget.student["school_id"].toString(),
      studentClass: widget.student["class"].toString(),
      section: widget.student["section"].toString(),
      day: selectedDay,
    );

    setState(() {
      schedule = data;
      loading = false;
    });
  }

  /// ألوان البطاقات
  final List<List<Color>> cardColors = [
    [Color(0xff5f9cff), Color(0xff3d6eff)],
    [Color(0xff00c6a7), Color(0xff1abc9c)],
    [Color(0xffffb347), Color(0xffff7b54)],
    [Color(0xfff857a6), Color(0xffff5858)],
    [Color(0xff8e2de2), Color(0xff4a00e0)],
    [Color(0xff43cea2), Color(0xff185a9d)],
  ];

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
                      "جدول الطالب",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                /// أيام الأسبوع
                Row(
                  children: days.map((day) {

                    bool isSelected = selectedDay == day["value"];

                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedDay = day["value"];
                          });
                          loadSchedule();
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white
                                : Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              day["name"],
                              style: TextStyle(
                                color: isSelected
                                    ? colors.primary
                                    : Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );

                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          /// جدول الحصص
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : schedule.isEmpty
                ? const Center(
              child: Text(
                "لا يوجد جدول لهذا اليوم",
                style: TextStyle(fontSize: 16),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.only(bottom: 20),
              itemCount: schedule.length,
              itemBuilder: (context, index) {

                final item = schedule[index];
                final colorsCard = cardColors[index % cardColors.length];

                return Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8
                  ),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: colorsCard,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: colorsCard[1].withOpacity(0.4),
                        blurRadius: 14,
                        offset: const Offset(0,6),
                      )
                    ],
                  ),
                  child: Row(
                    children: [

                      /// رقم الحصة
                      Container(
                        width: 55,
                        height: 55,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            "${item["period_number"] ?? ''}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 15),

                      /// المعلومات
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Text(
                              item["subject_name"] ?? '',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Text(
                              "المعلم: ${item["teacher_name"] ?? ''}",
                              style: const TextStyle(
                                color: Colors.white70,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Row(
                              children: [

                                const Icon(
                                  Icons.access_time,
                                  size: 16,
                                  color: Colors.white,
                                ),

                                const SizedBox(width: 5),

                                Text(
                                  "${item["start_time"] ?? ''} - ${item["end_time"] ?? ''}",
                                  style: const TextStyle(
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}