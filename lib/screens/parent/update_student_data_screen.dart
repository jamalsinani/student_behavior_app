import 'package:flutter/material.dart';
import '../../services/parent_service.dart';
import 'package:another_flushbar/flushbar.dart';

class UpdateStudentDataScreen extends StatefulWidget {

  final String studentId;
  final String userId;

  const UpdateStudentDataScreen({
    super.key,
    required this.studentId,
    required this.userId,
  });

  @override
  State<UpdateStudentDataScreen> createState() => _UpdateStudentDataScreenState();
}

class _UpdateStudentDataScreenState extends State<UpdateStudentDataScreen> {

  bool loading = true;

  Map student = {};

  final parentName = TextEditingController();
  final phone = TextEditingController();
  final phoneAlt = TextEditingController();
  final relation = TextEditingController();
  final job = TextEditingController();
  final area = TextEditingController();
  final transport = TextEditingController();
  final driverPhone = TextEditingController();
  final talent = TextEditingController();
  final diseases = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadStudent();
  }

  Future loadStudent() async {

  try {

    final res = await ParentService.getStudentInfo(widget.studentId);

    print("STUDENT DATA: $res");

    if (res == null || res["status"] != true) {

      Flushbar(
        message: "فشل في تحميل بيانات الطالب",
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red,
        flushbarPosition: FlushbarPosition.TOP,
      ).show(context);

      setState(() {
        loading = false;
      });

      return;
    }

    student = res["student"] ?? {};

    parentName.text = student["parent_name"] ?? "";
    phone.text = student["guardian_phone"] ?? "";
    phoneAlt.text = student["guardian_phone_alt"] ?? "";
    relation.text = student["guardian_relation"] ?? "";
    job.text = student["guardian_job"] ?? "";
    area.text = student["residence_area"] ?? "";
    transport.text = student["transport_type"] ?? "";
    driverPhone.text = student["driver_phone"] ?? "";
    talent.text = student["talent"] ?? "";
    diseases.text = student["diseases"] ?? "";

    setState(() {
      loading = false;
    });

  } catch (e) {

    print("LOAD STUDENT ERROR: $e");

    Flushbar(
      message: "حدث خطأ أثناء تحميل البيانات",
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.red,
      flushbarPosition: FlushbarPosition.TOP,
    ).show(context);

    setState(() {
      loading = false;
    });
  }
}

  Future save() async {

    final res = await ParentService.updateStudentData(
      id: widget.studentId,
      userId: widget.userId,
      parentName: parentName.text,
      phone: phone.text,
      phoneAlt: phoneAlt.text,
      relation: relation.text,
      job: job.text,
      area: area.text,
      transport: transport.text,
      driverPhone: driverPhone.text,
      talent: talent.text,
      diseases: diseases.text,
    );

    if(res["status"]){

      Flushbar(
        message: "تم تحديث البيانات بنجاح",
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.green,
        flushbarPosition: FlushbarPosition.TOP,
      ).show(context);

    }
  }

  Widget field(title, controller,{readOnly=false}){

    return Padding(
      padding: const EdgeInsets.symmetric(vertical:8),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: title,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  /// بطاقة قسم
  Widget sectionCard(String title, IconData icon, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0,6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [

              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon,color: Colors.blue),
              ),

              const SizedBox(width:10),

              Text(
                title,
                style: const TextStyle(
                  fontSize:18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height:15),

          ...children
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final colors = Theme.of(context).colorScheme;

    return Scaffold(

      backgroundColor: const Color(0xffF4F7FC),

      /// زر الحفظ
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: 55,
        child: ElevatedButton(
          onPressed: save,
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text(
            "حفظ التعديلات",
            style: TextStyle(
              fontSize:17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [

          /// HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top:65,
              left:20,
              right:20,
              bottom:30,
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

                const SizedBox(width:10),

                const Text(
                  "تحديث البيانات",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize:22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [

                /// بيانات الطالب
                sectionCard(
                  "بيانات الطالب",
                  Icons.person,
                  [
                    field("اسم الطالب",
                        TextEditingController(text: student["name"] ?? ""),
                        readOnly: true),

                    field("الرقم المدني",
                        TextEditingController(text: student["civil_id"] ?? ""),
                        readOnly: true),
                  ],
                ),

                /// بيانات ولي الأمر
                sectionCard(
                  "بيانات ولي الأمر",
                  Icons.family_restroom,
                  [
                    field("اسم ولي الأمر", parentName),
                    field("رقم الهاتف", phone, readOnly: true),
                    field("هاتف بديل", phoneAlt),
                    field("صلة القرابة", relation),
                    field("الوظيفة", job),
                  ],
                ),

                /// بيانات إضافية
                sectionCard(
                  "بيانات إضافية",
                  Icons.info_outline,
                  [
                    field("منطقة السكن", area),
                    field("نوع النقل", transport),
                    field("هاتف السائق", driverPhone),
                    field("الموهبة", talent),
                    field("الأمراض", diseases),
                  ],
                ),

                const SizedBox(height:120),
              ],
            ),
          )
        ],
      ),
    );
  }
}