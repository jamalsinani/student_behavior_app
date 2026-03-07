import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
import '../services/school_message_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class SchoolSendMessageScreen extends StatefulWidget {
  const SchoolSendMessageScreen({super.key});

  @override
  State<SchoolSendMessageScreen> createState() =>
      _SchoolSendMessageScreenState();
}

class _SchoolSendMessageScreenState extends State<SchoolSendMessageScreen> {

  int schoolId = 1;

  String sendType = "single";

  List classes = [];
  List sections = [];
  List students = [];

  String? selectedClass;
  String? selectedSection;
  int? selectedStudent;

  final TextEditingController messageController = TextEditingController();
  File? selectedImage;

  @override
  void initState() {
    super.initState();
    loadClasses();
  }

  /// ================= جلب الصفوف =================
  void loadClasses() async {

    final data = await SchoolMessageService.fetchClasses(schoolId);

    setState(() {
      classes = data;
    });
  }

  /// ================= جلب الشعب =================
  void loadSections() async {

    final data =
        await SchoolMessageService.fetchSections(schoolId, selectedClass!);

    setState(() {
      sections = data;
    });
  }

  /// ================= جلب الطلاب =================
  void loadStudents() async {

    final data = await SchoolMessageService.fetchStudents(
        schoolId, selectedClass!, selectedSection!);

    setState(() {
      students = data;
    });
  }

  /// ================= ارسال رسالة =================
  void sendMessage() async {

  final res = await SchoolMessageService.sendMessage(
  schoolId: schoolId,
  studentId: sendType == "single" ? selectedStudent : null,
  message: messageController.text,
  type: sendType,
  image: sendType == "all" ? selectedImage : null,
);

  if (res["status"] == true) {

    Flushbar(
      message: res["message"],
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.green,
      flushbarPosition: FlushbarPosition.TOP,
    ).show(context);

    /// إعادة ضبط الصفحة
    setState(() {
      messageController.clear();
      selectedImage = null;
      selectedStudent = null;
      selectedClass = null;
      selectedSection = null;
      students = [];
      sections = [];
    });

  } else {

    Flushbar(
      message: res["message"] ?? "فشل إرسال الرسالة",
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.red,
      flushbarPosition: FlushbarPosition.TOP,
    ).show(context);

    setState(() {
    messageController.clear();
    selectedImage = null;
    selectedStudent = null;
    selectedClass = null;
    selectedSection = null;
    students = [];
    sections = [];
  });

  }
}

  Future pickImage() async {

  final picker = ImagePicker();

  final image = await picker.pickImage(source: ImageSource.gallery);

  if (image != null) {

    setState(() {
      selectedImage = File(image.path);
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
                  "إرسال رسالة",
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
                              "طالب",
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
                              "كل الطلاب",
                              Icons.groups,
                              sendType == "all"),
                        ),
                      )

                    ],
                  ),

                  const SizedBox(height: 30),

                  /// ================= ارسال لطالب =================

                  if(sendType == "single") ...[

                    _dropdownClass(),

                    const SizedBox(height: 15),

                    _dropdownSection(),

                    const SizedBox(height: 15),

                    _dropdownStudent(),

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

                  if(sendType == "all") ...[

                    const SizedBox(height: 15),

                    GestureDetector(
                      onTap: pickImage,
                      child: Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: selectedImage == null
                            ? const Center(
                                child: Text("إضافة صورة للإعلان"),
                              )
                            : Image.file(selectedImage!, fit: BoxFit.cover),
                      ),
                    ),

                  ],

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: sendMessage,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        backgroundColor: const Color(0xff203a43),
                      ),
                      child: const Text("إرسال الرسالة"),
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

  /// ================= كرت النوع =================
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

  /// ================= Dropdown الصف =================
  Widget _dropdownClass(){

    return DropdownButtonFormField(
      hint: const Text("اختر الصف"),
      value: selectedClass,
      items: classes.map<DropdownMenuItem>((e) {
        return DropdownMenuItem(
          value: e["class"].toString(),
          child: Text("الصف ${e["class"]}"),
        );
      }).toList(),
      onChanged: (v) {

        setState(() {
          selectedClass = v;
          selectedSection = null;
          selectedStudent = null;
        });

        loadSections();
      },
    );
  }

  /// ================= Dropdown الشعبة =================
  Widget _dropdownSection(){

    return DropdownButtonFormField(
      hint: const Text("اختر الشعبة"),
      value: selectedSection,
      items: sections.map<DropdownMenuItem>((e) {
        return DropdownMenuItem(
          value: e["section"].toString(),
          child: Text("الشعبة ${e["section"]}"),
        );
      }).toList(),
      onChanged: (v) {

        setState(() {
          selectedSection = v;
          selectedStudent = null;
        });

        loadStudents();
      },
    );
  }

  /// ================= Dropdown الطالب =================
  Widget _dropdownStudent(){

    return DropdownButtonFormField(
      hint: const Text("اختر الطالب"),
      value: selectedStudent,
      items: students.map<DropdownMenuItem>((e) {
        return DropdownMenuItem(
          value: e["id"],
          child: Text(e["name"]),
        );
      }).toList(),
      onChanged: (v) {

        setState(() {
          selectedStudent = v;
        });
      },
    );
  }
}