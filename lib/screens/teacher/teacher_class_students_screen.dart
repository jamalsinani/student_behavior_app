import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:another_flushbar/flushbar.dart';
import '../../core/app_colors.dart';
import '../../services/teacher_class_students_service.dart';
import '../../services/teacher_student_service.dart';
import 'package:another_flushbar/flushbar.dart';

class TeacherClassStudentsScreen extends StatefulWidget {
  final Map<String, dynamic> classData;
  final Map<String, dynamic>? userData;

  const TeacherClassStudentsScreen({
    super.key,
    required this.classData,
    this.userData,
  });

  @override
  State<TeacherClassStudentsScreen> createState() =>
      _TeacherClassStudentsScreenState();
}

class _TeacherClassStudentsScreenState
    extends State<TeacherClassStudentsScreen>
    with TickerProviderStateMixin {

  List students = [];
  Set<int> absentStudents = {};
  bool isLoading = true;

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
     print("🔥🔥 SCREEN OPENED 🔥🔥");
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    loadStudents();
  }

  Future<void> loadStudents() async {
    setState(() => isLoading = true);

    try {

      final schoolIdRaw = widget.userData?['school_id'];
      final schoolId = schoolIdRaw is int
          ? schoolIdRaw
          : int.tryParse(schoolIdRaw?.toString() ?? "1") ?? 1;
        print("SECTION: ${widget.classData['section']}");
print("GRADE: ${widget.classData['grade']}");
print("SCHOOL ID: $schoolId");
      final data =
      await TeacherClassStudentsService.getClassStudents(
        section: widget.classData['section'].toString(),
        grade: widget.classData['grade'].toString(),
        schoolId: schoolId,
      );

      final today = DateTime.now();
final formattedDate =
    "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

final periodNumber =
    widget.classData['period_number'] ?? 1;

final teacherPhone =
    widget.userData?['phone']?.toString() ?? "";

final absences = await TeacherStudentService.getTodayAbsences(
  schoolId: schoolId,
  subjectName: widget.classData['subject_name'],
  teacherPhone: teacherPhone,
  periodNumber: periodNumber,
  absenceDate: formattedDate,
);

setState(() {
  students = data;
  absentStudents = absences.toSet();
  isLoading = false;
});
      _animationController.forward();

    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xffF4F7FC),
      body: Column(
        children: [

          _buildHeader(),

          const SizedBox(height: 25),

          Expanded(
            child: isLoading
                ? const Center(
                child: CircularProgressIndicator())
                : students.isEmpty
                ? const Center(
              child: Text(
                "لا يوجد طلاب في هذا الفصل",
                style: TextStyle(color: Colors.grey),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: students.length,
              itemBuilder: (context, index) {

                final student = students[index];

                final animation = Tween<double>(
                  begin: 0,
                  end: 1,
                ).animate(
                  CurvedAnimation(
                    parent: _animationController,
                    curve: Interval(
                      (index / students.length) * 0.7,
                      1,
                      curve: Curves.easeOutBack,
                    ),
                  ),
                );

                return AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: animation.value,
                      child: Transform.translate(
                        offset: Offset(
                            0, 60 * (1 - animation.value)),
                        child: Transform.scale(
                          scale: 0.92 + (animation.value * 0.08),
                          child: child,
                        ),
                      ),
                    );
                  },
                  child: _buildStudentCard(student),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.only(
      top: 65,
      right: 20,
      left: 20,
      bottom: 40,
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
        bottomLeft: Radius.circular(50),
        bottomRight: Radius.circular(50),
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

            const SizedBox(width: 10),

            const Text(
              "طلاب الفصل",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 15),

        Text(
          widget.classData['subject_name'],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            Text(
              "الصف ${widget.classData['section']} - الشعبة ${widget.classData['grade']}",
              style: const TextStyle(
                color: Colors.white70,
              ),
            ),

            // زر إرسال للكل
            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                 _showSendToAllDialog();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: const [

                    Icon(
                      Icons.send_rounded,
                      size: 16,
                      color: Colors.white,
                    ),

                    SizedBox(width: 6),

                    Text(
                      "إرسال للكل",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        // عدد الطلاب تحت الصف
        Text(
          "عدد الطلاب: ${students.length}",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
          ),
        ),
      ],
    ),
  );
}

  Widget _buildStudentCard(Map<String, dynamic> student) {

    final schoolIdRaw = widget.userData?['school_id'];
    final schoolId = schoolIdRaw is int
        ? schoolIdRaw
        : int.tryParse(schoolIdRaw?.toString() ?? "1") ?? 1;

    final teacherPhone =
        widget.userData?['phone']?.toString() ?? "";

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Colors.white,
            Color(0xffF9FAFF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.teacherPrimary.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

     Row(
  mainAxisAlignment: MainAxisAlignment.end,
  children: [

    // 🔴 زر الغياب
    GestureDetector(
  onTap: () async {

    final studentId = int.parse(student['id'].toString());

    final schoolIdRaw = widget.userData?['school_id'];
    final schoolId = schoolIdRaw is int
        ? schoolIdRaw
        : int.tryParse(schoolIdRaw?.toString() ?? "1") ?? 1;

    final teacherPhone =
        widget.userData?['phone']?.toString() ?? "";

    final periodNumber =
        widget.classData['period_number'] ?? 1;

    final today = DateTime.now();
    final formattedDate =
        "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    // ===============================
    // إذا كان مسجل مسبقًا → احذفه
    // ===============================
    if (absentStudents.contains(studentId)) {

  final removed = await TeacherStudentService.removeAbsence(
    studentId: studentId,
    schoolId: schoolId,
    subjectName: widget.classData['subject_name'],
    teacherPhone: teacherPhone,
    periodNumber: periodNumber,
    absenceDate: formattedDate,
  );

  if (removed) {
    setState(() {
      absentStudents.remove(studentId);
    });

    _showTopMessage(
      message: "تم إلغاء الغياب",
      isSuccess: true,
    );
  } else {
    _showTopMessage(
      message: "فشل إلغاء الغياب",
      isSuccess: false,
    );
  }

  return;
}

    // ===============================
    // تسجيل غياب جديد
    // ===============================
    final success = await TeacherStudentService.addAbsence(
      studentId: studentId,
      studentName: student['name'],
      schoolId: schoolId,
      subjectName: widget.classData['subject_name'],
      teacherPhone: teacherPhone,
      periodNumber: periodNumber,
      absenceDate: formattedDate,
    );

    if (success) {
      setState(() {
        absentStudents.add(studentId);
      });

      _showTopMessage(
        message: "تم تسجيل الغياب بنجاح",
        isSuccess: true,
      );
    } else {
      _showTopMessage(
        message: "هذا الطالب مسجل مسبقًا",
        isSuccess: false,
      );
    }
  },
  child: Container(
    width: 34,
    height: 34,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: absentStudents.contains(
              int.parse(student['id'].toString()))
          ? Colors.red
          : Colors.grey.shade300,
    ),
    child: Text(
      "غ",
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: absentStudents.contains(
                int.parse(student['id'].toString()))
            ? Colors.white
            : Colors.black54,
      ),
    ),
  ),
),

    const SizedBox(width: 8),

    _iconButton(
      icon: Icons.edit_note_rounded,
      color: Colors.blue,
      onTap: () {
        _showAddGradeDialog(student);
      },
    ),

    const SizedBox(width: 8),

    _iconButton(
      icon: Icons.note_add_rounded,
      color: Colors.green,
      onTap: () {
        _showAddNoteDialog(student);
      },
    ),

    const SizedBox(width: 8),

    _iconButton(
      icon: Icons.emoji_events_rounded,
      color: Colors.amber,
      onTap: () async {
        HapticFeedback.lightImpact();

        final schoolIdRaw = widget.userData?['school_id'];
        final schoolId = schoolIdRaw is int
            ? schoolIdRaw
            : int.tryParse(schoolIdRaw?.toString() ?? "1") ?? 1;

        final teacherPhone =
            widget.userData?['phone']?.toString() ?? "";

        final success =
            await TeacherStudentService.addStar(
          studentId:
              int.parse(student['id'].toString()),
          teacherPhone: teacherPhone,
          schoolId: schoolId,
          subjectName:
              widget.classData['subject_name'],
        );

        if (success) {
          setState(() {
            student['stars_count'] =
                (student['stars_count'] ?? 0) + 1;
          });

          _showTopMessage(
            message: "تم إضافة نجمة للطالب ⭐",
            isSuccess: true,
          );
        } else {
          _showTopMessage(
            message: "فشل إضافة النجمة",
            isSuccess: false,
          );
        }
      },
    ),

    const SizedBox(width: 6),

    Text(
      "${student['stars_count'] ?? 0}",
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    ),
  ],
),

          const SizedBox(height: 18),

          Row(
            children: [

              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.teacherPrimary.withOpacity(0.25),
                      blurRadius: 15,
                    )
                  ],
                ),
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor:
                  AppColors.teacherPrimary.withOpacity(0.15),
                  child: Text(
                    student['name'][0],
                    style: TextStyle(
                      color: AppColors.teacherPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Text(
                  student['name'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _iconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(
          icon,
          size: 19,
          color: color,
        ),
      ),
    );
  }
  
  // ===============================
// 🔔 رسالة علوية احترافية
// ===============================
void _showTopMessage({
  required String message,
  required bool isSuccess,
}) {
  Flushbar(
    message: message,
    duration: const Duration(seconds: 2),
    flushbarPosition: FlushbarPosition.TOP,
    margin: const EdgeInsets.all(16),
    borderRadius: BorderRadius.circular(12),
    backgroundColor:
        isSuccess ? Colors.green.shade600 : Colors.red.shade600,
    icon: Icon(
      isSuccess ? Icons.check_circle : Icons.error,
      color: Colors.white,
    ),
  ).show(context);
}

  void _showAddGradeDialog(Map<String, dynamic> student) {

  final gradeController = TextEditingController();
  final noteController = TextEditingController();

  final schoolIdRaw = widget.userData?['school_id'];
  final schoolId = schoolIdRaw is int
      ? schoolIdRaw
      : int.tryParse(schoolIdRaw?.toString() ?? "1") ?? 1;

  final teacherPhone =
      widget.userData?['phone']?.toString() ?? "";

  String? errorText;

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "",
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (context, animation, secondaryAnimation) {

      return StatefulBuilder(
        builder: (context, setStateDialog) {

          return Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                padding: const EdgeInsets.all(26),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  gradient: const LinearGradient(
                    colors: [
                      Colors.white,
                      Color(0xffF5F8FF),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.teacherPrimary.withOpacity(0.3),
                      blurRadius: 50,
                      offset: const Offset(0, 25),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const Text(
                      "إضافة درجة",
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      student['name'],
                      style: const TextStyle(color: Colors.grey),
                    ),

                    const SizedBox(height: 22),

                    TextField(
                      controller: gradeController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: "الدرجة (أرقام فقط)",
                        errorText: errorText,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    TextField(
                      controller: noteController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: "تعريف الدرجة (وصف)",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),

                    const SizedBox(height: 26),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          backgroundColor: AppColors.teacherPrimary,
                        ),
                        onPressed: () async {

                          final gradeText = gradeController.text.trim();

                          if (gradeText.isEmpty) {
                            setStateDialog(() {
                              errorText = "الرجاء إدخال الدرجة";
                            });
                            return;
                          }

                          final parsedGrade = double.tryParse(gradeText);

                          if (parsedGrade == null) {
                            setStateDialog(() {
                              errorText = "يجب إدخال أرقام فقط بدون / أو -";
                            });
                            return;
                          }

                          final success =
                              await TeacherStudentService.addGrade(
                            studentId:
                                int.parse(student['id'].toString()),
                            schoolId: schoolId,
                            subjectName:
                                widget.classData['subject_name'],
                            gradeValue: parsedGrade,
                            gradeNote: noteController.text,
                            teacherPhone: teacherPhone,
                          );

                          if (success) {
                            Navigator.pop(context);

                            _showTopMessage(
                              message: "تم حفظ الدرجة بنجاح",
                              isSuccess: true,
                            );
                          } else {
                            _showTopMessage(
                              message: "فشل حفظ الدرجة",
                              isSuccess: false,
                            );
                          }
                        },
                        child: const Text(
                          "حفظ الدرجة",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
    transitionBuilder: (context, animation,
        secondaryAnimation, child) {

      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
          ),
          child: child,
        ),
      );
    },
  );
}

void _showAddNoteDialog(Map<String, dynamic> student) {

  final noteController = TextEditingController();

  final schoolIdRaw = widget.userData?['school_id'];
  final schoolId = schoolIdRaw is int
      ? schoolIdRaw
      : int.tryParse(schoolIdRaw?.toString() ?? "1") ?? 1;

  final teacherPhone =
      widget.userData?['phone']?.toString() ?? "";

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "",
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (context, animation, secondaryAnimation) {

      return Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: const EdgeInsets.all(26),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              gradient: const LinearGradient(
                colors: [
                  Colors.white,
                  Color(0xffF5F8FF),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.teacherPrimary.withOpacity(0.3),
                  blurRadius: 50,
                  offset: const Offset(0, 25),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const Text(
                  "إضافة ملاحظة",
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  student['name'],
                  style: const TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 22),

                TextField(
                  controller: noteController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: "اكتب الملاحظة هنا",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),

                const SizedBox(height: 26),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      backgroundColor:
                          AppColors.teacherPrimary,
                    ),
                    onPressed: () async {

                        if (noteController.text.isEmpty) return;

                        final success =
                            await TeacherStudentService.addNote(
                          studentId: int.parse(student['id'].toString()),
                          schoolId: schoolId,
                          subjectName: widget.classData['subject_name'],
                          noteText: noteController.text,
                          teacherPhone: teacherPhone,
                        );

                        if (success) {
                          Navigator.of(context, rootNavigator: true).pop();

                          _showTopMessage(
                            message: "تم حفظ الملاحظة بنجاح",
                            isSuccess: true,
                          );
                        } else {
                          _showTopMessage(
                            message: "فشل حفظ الملاحظة",
                            isSuccess: false,
                          );
                        }

                      },
                    child: const Text(
                      "حفظ الملاحظة",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation,
        secondaryAnimation, child) {

      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
          ),
          child: child,
        ),
      );
    },
  );
}

void _showSendToAllDialog() {

  final messageController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {

      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const Text(
                "إرسال رسالة لكل الطلاب",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "سيتم إرسال الرسالة إلى جميع طلاب الفصل",
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: messageController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: "اكتب الرسالة هنا",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: AppColors.teacherPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () async {

                    if (messageController.text.isEmpty) {
                      _showTopMessage(
                        message: "اكتب الرسالة أولاً",
                        isSuccess: false,
                      );
                      return;
                    }

                    Navigator.pop(context);

                    await _sendMessageToAll(messageController.text);
                  },
                  child: const Text(
                    "إرسال الرسالة",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),

            ],
          ),
        ),
      );
    },
  );
}
  



  Future<void> _sendMessageToAll(String message) async {

  try {

    final schoolIdRaw = widget.userData?['school_id'];
    final schoolId = schoolIdRaw is int
        ? schoolIdRaw
        : int.tryParse(schoolIdRaw?.toString() ?? "1") ?? 1;

    final teacherPhone =
        widget.userData?['phone']?.toString() ?? "";

    final response = await TeacherStudentService.sendClassMessage(
      schoolId: schoolId,
      section: widget.classData['section'],
      grade: widget.classData['grade'],
      subjectName: widget.classData['subject_name'],
      teacherPhone: teacherPhone,
      message: message,
    );

    if (response['status'] == true) {

      final count = response['count'] ?? 0;

      _showTopMessage(
        message: "تم إرسال الرسالة بنجاح لعدد $count طالب",
        isSuccess: true,
      );

    } else {

      _showTopMessage(
        message: "فشل إرسال الرسالة",
        isSuccess: false,
      );
    }

  } catch (e) {

    print("SEND MESSAGE ERROR: $e");

    _showTopMessage(
      message: "حدث خطأ أثناء الإرسال",
      isSuccess: false,
    );
  }
}


    }
