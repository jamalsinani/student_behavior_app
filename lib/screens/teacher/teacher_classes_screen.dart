import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../services/teacher_classes_service.dart';
import 'teacher_class_students_screen.dart';


class TeacherClassesScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const TeacherClassesScreen({super.key, this.userData});

  @override
  State<TeacherClassesScreen> createState() =>
      _TeacherClassesScreenState();
}

class _TeacherClassesScreenState
    extends State<TeacherClassesScreen> {

  List classes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadClasses();
  }

  Future<void> loadClasses() async {

    setState(() => isLoading = true);

    try {

      final phone =
          widget.userData?['phone']?.toString() ?? "";

      final schoolIdRaw =
          widget.userData?['school_id'];

      final schoolId = schoolIdRaw is int
          ? schoolIdRaw
          : int.tryParse(schoolIdRaw?.toString() ?? "1") ?? 1;

      final data =
          await TeacherClassesService.getTeacherClasses(
        teacherPhone: phone,
        schoolId: schoolId,
      );

      setState(() {
        classes = data;
        isLoading = false;
      });

    } catch (e) {
      setState(() => isLoading = false);
    }
  }

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

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xffF3F6FB),
      body: Column(
        children: [

          /// ================= HEADER =================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 60,
              right: 20,
              left: 20,
              bottom: 35,
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
            child: Row(
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
                  "الفصول الدراسية",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          /// ================= CONTENT =================
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : classes.isEmpty
                    ? const Center(
                        child: Text(
                          "لا توجد فصول حالياً 🎉",
                          style:
                              TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding:
                            const EdgeInsets.symmetric(
                                horizontal: 20),
                        itemCount: classes.length,
                        itemBuilder: (context, index) {

                          final item = classes[index];

                          final subjectColor =
                              getSubjectColor(
                                  item['subject_name'] ?? "");

                          return InkWell(
                            borderRadius:
                                BorderRadius.circular(30),
                            onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => TeacherClassStudentsScreen(
        classData: item,
        userData: widget.userData, 
      ),
    ),
  );
},
                            child: AnimatedContainer(
                              duration: const Duration(
                                  milliseconds: 400),
                              margin: const EdgeInsets.only(
                                  bottom: 20),
                              padding:
                                  const EdgeInsets.all(22),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    subjectColor
                                        .withOpacity(0.9),
                                    subjectColor
                                        .withOpacity(0.7),
                                  ],
                                  begin: Alignment.topRight,
                                  end:
                                      Alignment.bottomLeft,
                                ),
                                borderRadius:
                                    BorderRadius.circular(
                                        30),
                                boxShadow: [
                                  BoxShadow(
                                    color: subjectColor
                                        .withOpacity(0.4),
                                    blurRadius: 20,
                                    offset:
                                        const Offset(
                                            0, 10),
                                  )
                                ],
                              ),
                              child: Row(
                                children: [

                                  Container(
                                    width: 70,
                                    height: 70,
                                    decoration:
                                        BoxDecoration(
                                      color: Colors.white
                                          .withOpacity(0.2),
                                      shape:
                                          BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.class_,
                                      color:
                                          Colors.white,
                                      size: 30,
                                    ),
                                  ),

                                  const SizedBox(width: 20),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                      children: [

                                        Text(
                                          item['subject_name'] ??
                                              '',
                                          style:
                                              const TextStyle(
                                            color: Colors
                                                .white,
                                            fontSize:
                                                20,
                                            fontWeight:
                                                FontWeight
                                                    .bold,
                                          ),
                                        ),

                                        const SizedBox(
                                            height: 8),

                                        Text(
                                          "الصف ${item['section']} - الشعبة ${item['grade']}",
                                          style:
                                              const TextStyle(
                                            color: Colors
                                                .white70,
                                            fontWeight:
                                                FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ],
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