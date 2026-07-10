import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
import '../services/school_message_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SchoolSendTeacherMessageScreen extends StatefulWidget {
  const SchoolSendTeacherMessageScreen({super.key});

  @override
  State<SchoolSendTeacherMessageScreen> createState() =>
      _SchoolSendTeacherMessageScreenState();
}

class _SchoolSendTeacherMessageScreenState
    extends State<SchoolSendTeacherMessageScreen> {

  int schoolId = 0;

  String sendType = "single";

  List subjects = [];
  List teachers = [];

  String? selectedSubject;
  String? selectedTeacherName;
  String? selectedTeacherPhone;

  final TextEditingController messageController = TextEditingController();
  bool isSending = false;

  Future<void> loadSchoolId() async {

  final prefs = await SharedPreferences.getInstance();

  schoolId = prefs.getInt('school_id') ?? 0;

  print('CURRENT SCHOOL ID = $schoolId');

  loadSubjects();
}

  @override
  void initState() {
    super.initState();
    loadSchoolId();
  }

  /// ================= جلب المواد =================
  void loadSubjects() async {

    final data =
        await SchoolMessageService.fetchSubjects(schoolId);

    setState(() {
      subjects = data;
    });

  }

  /// ================= جلب المعلمين =================
  void loadTeachers() async {

    final data =
        await SchoolMessageService.fetchTeachersBySubject(
            schoolId, selectedSubject!);

    setState(() {
      teachers = data;
    });

  }

  /// ================= إرسال رسالة =================
  void sendMessage() async {

  if (isSending) return;

  /// التحقق من اختيار المعلم
  if (sendType == "single" && selectedTeacherPhone == null) {

    Flushbar(
      message: "يرجى اختيار المعلم أولاً",
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.orange,
      flushbarPosition: FlushbarPosition.TOP,
    ).show(context);

    return;
  }

  /// التحقق من الرسالة
  if (messageController.text.trim().isEmpty) {

    Flushbar(
      message: "اكتب نص الرسالة",
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.orange,
      flushbarPosition: FlushbarPosition.TOP,
    ).show(context);

    return;
  }

  setState(() {
    isSending = true;
  });

  try {

    final res = await SchoolMessageService.sendTeacherMessage(
      schoolId: schoolId,
      teacherName: selectedTeacherName,
      teacherPhone: selectedTeacherPhone,
      message: messageController.text,
      type: sendType,
    );

    if (res["status"] == true) {

      Flushbar(
        message: res["message"],
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.green,
        flushbarPosition: FlushbarPosition.TOP,
      ).show(context);

      setState(() {
        messageController.clear();
        selectedTeacherName = null;
        selectedTeacherPhone = null;
        selectedSubject = null;
        teachers = [];
      });

    } else {

      Flushbar(
        message: "فشل إرسال الرسالة",
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red,
        flushbarPosition: FlushbarPosition.TOP,
      ).show(context);

    }

  } finally {

    if (mounted) {
      setState(() {
        isSending = false;
      });
    }

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
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back,color: Colors.white),
                  ),
                ),

                const SizedBox(width: 15),

                const Text(
                  "رسائل المعلمين",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

              ],
            ),
          ),

          const SizedBox(height: 25),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),

              child: Column(
                children: [

                  /// ================= اختيار النوع =================

                  Row(
                    children: [

                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              sendType = "single";
                            });
                          },
                          child: _typeCard(
                              "معلم واحد",
                              Icons.person,
                              sendType == "single"),
                        ),
                      ),

                      const SizedBox(width: 15),

                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              sendType = "all";
                            });
                          },
                          child: _typeCard(
                              "كل المعلمين",
                              Icons.groups,
                              sendType == "all"),
                        ),
                      )

                    ],
                  ),

                  const SizedBox(height: 30),

                  if(sendType == "single") ...[

                    /// ================= اختيار المادة =================
                    DropdownButtonFormField(
                      hint: const Text("اختر المادة"),
                      value: selectedSubject,
                      items: subjects.map<DropdownMenuItem>((e) {

                        return DropdownMenuItem(
                          value: e["subject_name"],
                          child: Text(e["subject_name"]),
                        );

                      }).toList(),
                      onChanged: (v) {

                        setState(() {
                          selectedSubject = v;
                          teachers = [];
                        });

                        loadTeachers();

                      },
                    ),

                    const SizedBox(height: 15),

                    /// ================= اختيار المعلم =================
                    DropdownButtonFormField(
                      hint: const Text("اختر المعلم"),
                      value: selectedTeacherName,
                      items: teachers.map<DropdownMenuItem>((e) {

                        return DropdownMenuItem(
                          value: e["teacher_name"],
                          child: Text(e["teacher_name"]),
                        );

                      }).toList(),
                      onChanged: (v) {

                        final teacher = teachers
                            .firstWhere((t) => t["teacher_name"] == v);

                        setState(() {
                          selectedTeacherName = teacher["teacher_name"];
                          selectedTeacherPhone = teacher["teacher_phone"];
                        });

                      },
                    ),

                    const SizedBox(height: 20),

                  ],

                  /// ================= الرسالة =================
                  TextField(
                    controller: messageController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: "اكتب الرسالة",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: isSending ? null : sendMessage,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          backgroundColor: isSending
                              ? Colors.orange
                              : const Color(0xff203a43),
                        ),
                        child: isSending
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              )
                            : const Text(
                                "إرسال الرسالة",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                  const SizedBox(height: 30),

                ],
              ),
            ),
          )

        ],
      ),
    );
  }

  /// ================= تصميم كرت النوع =================
  Widget _typeCard(String title, IconData icon, bool active){

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),

      decoration: BoxDecoration(
        color: active ? const Color(0xff203a43) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black12,
          )
        ],
      ),

      child: Column(
        children: [

          Icon(icon,
              color: active ? Colors.white : Colors.black54),

          const SizedBox(height: 10),

          Text(
            title,
            style: TextStyle(
              color: active ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          )

        ],
      ),
    );
  }

}