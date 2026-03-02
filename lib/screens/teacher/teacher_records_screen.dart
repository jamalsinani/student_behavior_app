import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../services/teacher_student_service.dart';

class TeacherRecordsScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const TeacherRecordsScreen({super.key, this.userData});

  @override
  State<TeacherRecordsScreen> createState() =>
      _TeacherRecordsScreenState();
}

class _TeacherRecordsScreenState
    extends State<TeacherRecordsScreen>
    with TickerProviderStateMixin {

  late TabController _tabController;

  // ================= سجلات الطلاب =================
  List studentRecords = [];
  bool isLoadingStudents = true;

  // ================= سجلاتي (الأرشيف) =================
  List myRecords = [];
  bool isLoadingMyRecords = true;

  @override
  void initState() {
    super.initState();

    _tabController =
        TabController(length: 2, vsync: this);

    loadStudentRecords();
    loadMyRecords();
  }

  // ============================================================
  // تحميل سجلات الطلاب
  // ============================================================
  Future<void> loadStudentRecords() async {
    try {

      final phone =
          widget.userData?['phone']?.toString() ?? "";

      final schoolId = int.tryParse(
              widget.userData?['school_id']
                      ?.toString() ??
                  "1") ??
          1;

      final data =
          await TeacherStudentService.getStudentRecords(
        teacherPhone: phone,
        schoolId: schoolId,
      );

      setState(() {
        studentRecords = data;
        isLoadingStudents = false;
      });

    } catch (e) {
      print("STUDENT RECORDS ERROR: $e");
      setState(() => isLoadingStudents = false);
    }
  }

  // ============================================================
  // تحميل سجلاتي (الأرشيف)
  // ============================================================
  Future<void> loadMyRecords() async {
    try {

      final phone =
          widget.userData?['phone']?.toString() ?? "";

      final schoolId = int.tryParse(
              widget.userData?['school_id']
                      ?.toString() ??
                  "1") ??
          1;

      final data =
          await TeacherStudentService.getTeacherArchive(
        teacherPhone: phone,
        schoolId: schoolId,
      );

      setState(() {
        myRecords = data;
        isLoadingMyRecords = false;
      });

    } catch (e) {
      print("MY RECORDS ERROR: $e");
      setState(() => isLoadingMyRecords = false);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xffF3F6FB),
      body: Column(
        children: [

          // ================= HEADER =================
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
                bottomLeft: Radius.circular(45),
                bottomRight: Radius.circular(45),
              ),
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                Row(
                  children: [

                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding:
                            const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white
                              .withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),

                    const SizedBox(width: 15),

                    const Text(
                      "السجلات",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                // ================= TabBar بخط سفلي =================
                TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.white,
                  indicatorWeight: 3,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  tabs: const [
                    Tab(text: "سجلاتي"),
                    Tab(text: "سجلات الطلاب"),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMyRecords(),
                _buildStudentRecords(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ================= سجلاتي (الأرشيف) =========================
  // ============================================================
  Widget _buildMyRecords() {

    if (isLoadingMyRecords) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (myRecords.isEmpty) {
      return const Center(
        child: Text("لا توجد سجلات سابقة"),
      );
    }

    return ListView.builder(
      padding:
          const EdgeInsets.symmetric(horizontal: 20),
      itemCount: myRecords.length,
      itemBuilder: (context, index) {

        final item = myRecords[index];

        Color color;

        switch (item['type']) {
          case 'coverage':
            color = Colors.red;
            break;
          case 'admin_note':
            color = Colors.orange;
            break;
          default:
            color = Colors.grey;
        }

        return _myRecordCard(
          title: item['title'].toString(),
          subtitle: item['description'].toString(),
          date: item['date']?.toString() ?? "",
          color: color,
        );
      },
    );
  }

  Widget _myRecordCard({
    required String title,
    required String subtitle,
     required String date,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.9),
            color.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white70,
            ),
          ),
           const SizedBox(height: 12),

        Text(
          date,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        ],
      ),
    );
  }

  // ============================================================
  // ================= سجلات الطلاب =============================
  // ============================================================
  Widget _buildStudentRecords() {

    if (isLoadingStudents) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (studentRecords.isEmpty) {
      return const Center(
        child: Text("لا توجد سجلات"),
      );
    }

    return ListView.builder(
      padding:
          const EdgeInsets.symmetric(horizontal: 20),
      itemCount: studentRecords.length,
      itemBuilder: (context, index) {

        final item = studentRecords[index];

        Color color;

        switch (item['type']) {
          case 'note':
            color = Colors.orange;
            break;
          case 'star':
            color = Colors.green;
            break;
          case 'grade':
            color = Colors.blue;
            break;
          default:
            color = Colors.grey;
        }

        return _recordCard(
          id: int.tryParse(item['id'].toString()) ?? 0,
          type: item['type'].toString(),
          title: item['title'].toString(),
          subtitle: item['description'].toString(),
          studentName: item['student_name'].toString(),
          color: color,
        );
      },
    );
  }

  Widget _recordCard({
    required int id,
    required String type,
    required String title,
    required String subtitle,
    required String studentName,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.9),
            color.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                Text(
                  "$title للطالب ($studentName)",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          InkWell(
            onTap: () async {

              final confirm =
                  await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("تأكيد الحذف"),
                  content: const Text(
                      "هل أنت متأكد من حذف هذا السجل؟"),
                  actions: [
                    TextButton(
                      onPressed: () =>
                          Navigator.pop(context, false),
                      child: const Text("إلغاء"),
                    ),
                    TextButton(
                      onPressed: () =>
                          Navigator.pop(context, true),
                      child: const Text(
                        "حذف",
                        style: TextStyle(
                            color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm == true) {

                final success =
                    await TeacherStudentService
                        .deleteStudentRecord(
                  id: id,
                  type: type,
                );

                if (success) {
                  loadStudentRecords();
                }
              }
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white
                    .withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_outline,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}