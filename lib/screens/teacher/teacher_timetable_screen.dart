import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../services/teacher_timetable_service.dart';
import 'package:another_flushbar/flushbar.dart';

class TeacherTimetableScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const TeacherTimetableScreen({super.key, this.userData});

  @override
  State<TeacherTimetableScreen> createState() =>
      _TeacherTimetableScreenState();
}

class _TeacherTimetableScreenState
    extends State<TeacherTimetableScreen> {

  String? selectedTeacher;
  int? selectedTargetDay;
  int? selectedTargetPeriod;
  Map<String, dynamic>? selectedTargetPeriodInfo;
  List teachers = [];
  bool isLoadingTeachers = false;

  List timetable = [];
  bool isLoading = true;

  int selectedDay = () {
    final weekday = DateTime.now().weekday;

    if (weekday == 7) return 1;
    if (weekday == 1) return 2;
    if (weekday == 2) return 3;
    if (weekday == 3) return 4;
    if (weekday == 4) return 5;

    return 1;
  }();

  final List<String> arabicDays = [
    "الأحد",
    "الاثنين",
    "الثلاثاء",
    "الأربعاء",
    "الخميس",
  ];

  Future<void> loadTeachers() async {
  setState(() => isLoadingTeachers = true);

  final phone = widget.userData?['phone']?.toString() ?? "";
  final schoolId = int.tryParse(
          widget.userData?['school_id']?.toString() ?? "1") ??
      1;

  try {
    final response = await TeacherTimetableService.getTeachers(
      schoolId: schoolId,
    );

    setState(() {
      teachers = response;
      isLoadingTeachers = false;
    });
    print("TEACHERS LIST: $teachers"); 

  } catch (e) {
    setState(() => isLoadingTeachers = false);
  }
} 

  @override
  void initState() {
    super.initState();
    loadTimetable();
  }

  Future<void> loadTimetable() async {
    setState(() => isLoading = true);

    final phone =
        widget.userData?['phone']?.toString() ?? "";

    final schoolIdRaw =
        widget.userData?['school_id'];

    final schoolId = schoolIdRaw is int
        ? schoolIdRaw
        : int.tryParse(schoolIdRaw?.toString() ?? "1") ?? 1;

    if (phone.isEmpty) {
      setState(() => isLoading = false);
      return;
    }

    try {
      final data =
          await TeacherTimetableService.getTimetable(
        teacherPhone: phone,
        schoolId: schoolId,
        dayNumber: selectedDay,
      );
       print("TIMETABLE DATA: $data");
       
      setState(() {
        timetable = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  /// ألوان المواد
  Color getSubjectColor(String subject) {
    switch (subject.trim()) {
      case "الرياضيات":
        return Colors.blue;
      case "العلوم":
        return Colors.green;
      case "الكيمياء":
        return Colors.deepPurple;
      case "الفيزياء":
        return Colors.indigo;
      case "الأحياء":
        return Colors.teal;
      case "اللغة العربية":
        return Colors.orange;
      case "اللغة الإنجليزية":
        return Colors.redAccent;
      case "التربية الإسلامية":
        return Colors.brown;
      default:
        return AppColors.teacherPrimary;
    }
  }

  bool isCurrentPeriod(String start, String end) {
    final now = TimeOfDay.now();
    final startParts = start.split(":");
    final endParts = end.split(":");

    final startTime = TimeOfDay(
      hour: int.parse(startParts[0]),
      minute: int.parse(startParts[1]),
    );

    final endTime = TimeOfDay(
      hour: int.parse(endParts[0]),
      minute: int.parse(endParts[1]),
    );

    final nowMinutes = now.hour * 60 + now.minute;
    final startMinutes =
        startTime.hour * 60 + startTime.minute;
    final endMinutes =
        endTime.hour * 60 + endTime.minute;

    return nowMinutes >= startMinutes &&
        nowMinutes <= endMinutes;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xffF3F6FB),
      body: Column(
        children: [

          /// HEADER
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
                  AppColors.teacherPrimary,
                  AppColors.teacherSecondary,
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Row(
  children: [

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
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 22,
          ),
        ),
      ),
    ),

    const SizedBox(width: 18),  // 👈 هذا هو الحل

    const Text(
      "جدول المعلم",
      style: TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    ),
  ],
),

                const SizedBox(height: 15),

                Row(
  children: List.generate(arabicDays.length, (index) {

    final dayNumber = index + 1;
    final isSelected = selectedDay == dayNumber;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedDay = dayNumber;
          });
          loadTimetable();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.white
                : Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: Text(
            arabicDays[index],
            style: TextStyle(
              color: isSelected
                  ? AppColors.teacherPrimary
                  : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }),
),

                const SizedBox(height: 20),

                Text(
                  "عدد الحصص: ${timetable.length}",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                )
              ],
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator())
                : timetable.isEmpty
                    ? const Center(
                        child: Text(
                          "لا توجد حصص في هذا اليوم 🎉",
                          style:
                              TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding:
                            const EdgeInsets.symmetric(
                                horizontal: 20),
                        itemCount: timetable.length,
                        itemBuilder: (context, index) {

                          final item = timetable[index];
                          final subjectColor =
                              getSubjectColor(
                                  item['subject_name'] ?? "");

                          final isNow =
                              isCurrentPeriod(
                                  item['start_time'],
                                  item['end_time']);

                          return Stack(
  children: [

    /// الصندوق الأصلي للحصة (بدون أي تغيير في التصميم)
    AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      margin: const EdgeInsets.only(bottom: 22),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            subjectColor.withOpacity(isNow ? 0.95 : 0.8),
            subjectColor.withOpacity(isNow ? 0.8 : 0.6),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: subjectColor.withOpacity(0.4),
            blurRadius: 25,
            offset: const Offset(0, 12),
          )
        ],
      ),
      child: Row(
        children: [

          Container(
            width: 75,
            height: 75,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                "${item['period_number']}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(width: 20),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  item['subject_name'] ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "الصف ${item['section']} - الشعبة ${item['grade']}",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 6),

                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.white70,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      "${item['start_time'].toString().substring(0,5)} - ${item['end_time'].toString().substring(0,5)}",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),

                if (isNow)
                  const Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text(
                      "🔴 الحصة الحالية الآن",
                      style: TextStyle(
                        color: Colors.yellow,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    ),

    /// ===================== حالة التبديل =====================
Positioned(
  top: 10,
  left: 10,
  child: item['swap_status'] == 'approved'
      ? Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.9),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.thumb_up,
            size: 18,
            color: Colors.white,
          ),
        )
      : Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: () async {
              selectedTeacher = null;
              await loadTeachers();
              _openSwapSheet(
                subjectName: item['subject_name'] ?? '',
                section: item['section'] ?? '',
                grade: item['grade'] ?? '',
                periodNumber: int.tryParse(
                        item['period_number'].toString()) ??
                    0,
                dayNumber: selectedDay,
                teachersList: teachers,
              );
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.4),
                ),
              ),
              child: const Icon(
                Icons.swap_horiz_rounded,
                size: 18,
                color: Colors.white,
              ),
            ),
          ),
        ),
),
  ],
);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  void _openSwapSheet({
  required String subjectName,
  required String section,
  required String grade,
  required int periodNumber,
  required int dayNumber,
  required List teachersList,
}) {
  selectedTeacher = null;
  selectedTargetDay = null;
  selectedTargetPeriod = null;
  selectedTargetPeriodInfo = null;
  
  List<int> availablePeriods = [];   

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(30),
      ),
    ),
    builder: (_) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text(
                    "طلب تبديل حصة",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// معلومات الحصة الحالية
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("المادة: $subjectName"),
                        Text("الصف: $section - $grade"),
                        Text("اليوم: ${arabicDays[dayNumber - 1]}"),
                        Text("الحصة: $periodNumber"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  /// ================= المعلم البديل =================
                  const Text("اختر المعلم البديل"),
                  const SizedBox(height: 8),

                  DropdownButtonFormField<String>(
                    value: selectedTeacher,
                    isExpanded: true,
                    items: teachersList.map<DropdownMenuItem<String>>((teacher) {
                      return DropdownMenuItem<String>(
                        value: teacher['phone'].toString(),
                        child: Text(
                          teacher['name'],
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setModalState(() {
                        selectedTeacher = value;
                        selectedTargetPeriod = null;
                        selectedTargetPeriodInfo = null;
                      });
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// ================= اليوم البديل =================
                  const Text("اختر اليوم البديل"),
                  const SizedBox(height: 8),

                  DropdownButtonFormField<int>(
                    value: selectedTargetDay,
                    items: List.generate(arabicDays.length, (index) {
                      return DropdownMenuItem(
                        value: index + 1,
                        child: Text(arabicDays[index]),
                      );
                    }),
                    onChanged: (value) async {
  setModalState(() {
    selectedTargetDay = value;
    selectedTargetPeriod = null;
    selectedTargetPeriodInfo = null;
    availablePeriods = [];
  });

  if (selectedTeacher != null && value != null) {

    final schoolId = int.tryParse(
            widget.userData?['school_id'].toString() ?? "1") ??
        1;

    final data =
        await TeacherTimetableService.getTimetable(
      teacherPhone: selectedTeacher!,
      schoolId: schoolId,
      dayNumber: value,
    );

    setModalState(() {
      availablePeriods =
           data.map<int>((e) => int.parse(e['period_number'].toString())).toList();
    });

    print("AVAILABLE PERIODS: $availablePeriods");
  }
},
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// ================= الحصة البديلة =================
                  const Text("اختر الحصة البديلة"),
const SizedBox(height: 8),

DropdownButtonFormField<int>(
  value: selectedTargetPeriod,
  items: availablePeriods.map<DropdownMenuItem<int>>((period) {
    return DropdownMenuItem<int>(
      value: period,
      child: Text("الحصة $period"),
    );
  }).toList(),
  onChanged: (selectedTargetDay == null || selectedTeacher == null)
      ? null
      : (value) async {

          setModalState(() {
            selectedTargetPeriod = value;
            selectedTargetPeriodInfo = null;
          });

          final schoolId = int.tryParse(
                  widget.userData?['school_id'].toString() ?? "1") ??
              1;

          final result =
              await TeacherTimetableService.getTeacherPeriodInfo(
            teacherPhone: selectedTeacher!,
            schoolId: schoolId,
            dayNumber: selectedTargetDay!,
            periodNumber: value!,
          );

          setModalState(() {
            selectedTargetPeriodInfo = result;
          });
        },
  decoration: const InputDecoration(
    border: OutlineInputBorder(),
  ),
),

                  /// ================= عرض تفاصيل الحصة المختارة =================
                  if (selectedTargetPeriodInfo != null)
                    Container(
                      margin: const EdgeInsets.only(top: 20),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          const Text(
                            "تفاصيل الحصة المختارة:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            "المادة: ${selectedTargetPeriodInfo!['subject_name']}",
                          ),

                          Text(
                            "الصف: ${selectedTargetPeriodInfo!['section']} - ${selectedTargetPeriodInfo!['grade']}",
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 30),

                  /// ================= زر الإرسال =================
                  SizedBox(
  width: double.infinity,
  child: ElevatedButton(
    onPressed: (selectedTeacher == null ||
            selectedTargetDay == null ||
            selectedTargetPeriod == null)
        ? null
        : () async {

            print("SEND BUTTON PRESSED");

            final schoolId = int.tryParse(
                    widget.userData?['school_id'].toString() ?? "1") ??
                1;

            final requesterPhone =
                widget.userData?['phone'] ?? "";

            final requesterName =
                widget.userData?['name'] ?? "";

            final substitute =
                teachersList.firstWhere(
                    (t) =>
                        t['phone'].toString() ==
                        selectedTeacher);

            print("CALLING API NOW");

            final result =
    await TeacherTimetableService.sendSwapRequest(
  schoolId: schoolId,
  requesterPhone: requesterPhone,
  requesterName: requesterName,
  substitutePhone: selectedTeacher!,
  substituteName: substitute['name'],
  originalDay: dayNumber,
  originalPeriod: periodNumber,
  targetDay: selectedTargetDay!,
  targetPeriod: selectedTargetPeriod!,
  subjectName: subjectName,
  section: section,
  grade: grade,
);

print("API FINISHED");

Navigator.pop(context);

Flushbar(
  margin: const EdgeInsets.all(16),
  borderRadius: BorderRadius.circular(20),
  duration: const Duration(seconds: 3),
  flushbarPosition: FlushbarPosition.TOP,
  backgroundGradient: LinearGradient(
    colors: result['status']
        ? [Colors.green.shade600, Colors.green.shade400]
        : [Colors.red.shade600, Colors.red.shade400],
  ),
  icon: Icon(
    result['status']
        ? Icons.check_circle
        : Icons.error,
    color: Colors.white,
    size: 26,
  ),
  titleText: Text(
    result['status'] ? "تم بنجاح" : "تنبيه",
    style: const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 15,
    ),
  ),
  messageText: Text(
    result['message'],
    style: const TextStyle(
      color: Colors.white,
      fontSize: 14,
    ),
  ),
).show(context);
          },
    child: const Text("إرسال الطلب"), // 👈 هذا كان ناقص
  ),
),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

}