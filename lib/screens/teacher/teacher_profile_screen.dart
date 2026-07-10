import 'package:flutter/material.dart';
import '../../services/teacher_home_service.dart';
import '../../core/app_colors.dart';
import '../../services/profile_update_service.dart';
import 'package:another_flushbar/flushbar.dart';

class TeacherProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const TeacherProfileScreen({super.key, this.userData});

  @override
  State<TeacherProfileScreen> createState() =>
      _TeacherProfileScreenState();
}

class _TeacherProfileScreenState
    extends State<TeacherProfileScreen> {

  Map<String, dynamic>? profileData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      final phone =
          widget.userData?['phone']?.toString() ?? "";

      final schoolId = int.tryParse(
              widget.userData?['school_id']
                      ?.toString() ??
                  "1") ??
          1;

      final response =
          await TeacherHomeService.getTeacherProfile(
        teacherPhone: phone,
        schoolId: schoolId,
      );

      setState(() {
        profileData = response['data'];
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void _showEditDialog({
  required String title,
  required String currentValue,
}) {

  final controller =
      TextEditingController(text: currentValue);

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(20),
        ),
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            if (title == "رقم الهاتف")
              Container(
                padding:
                    const EdgeInsets.all(10),
                margin:
                    const EdgeInsets.only(
                        bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.orange
                      .withOpacity(0.1),
                  borderRadius:
                      BorderRadius.circular(
                          12),
                ),
                child: const Text(
                  "رقم الهاتف هو رقم تسجيل الدخول للتطبيق، بعد الحفظ استخدم الرقم الجديد للدخول.",
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
              ),

            TextField(
              controller: controller,
              decoration: InputDecoration(
                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                          12),
                ),
                hintText:
                    "أدخل القيمة الجديدة",
              ),
            ),
          ],
        ),
        actions: [

          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("إلغاء"),
          ),

          ElevatedButton(
                onPressed: () async {

                  final newValue =
                    controller.text.trim();

                if (newValue.isEmpty) {
                  return;
                }

                final result =
                    await ProfileUpdateService.updateField(
                  teacherPhone:
                      profileData!['phone'].toString(),
                  schoolId:
                      widget.userData!['school_id']
                          .toString(),
                  field: title == "رقم الهاتف"
                      ? "phone"
                      : "email",
                  value: newValue,
                );

                if (result['status'] == true) {

                  setState(() {

                    if (title == "رقم الهاتف") {
                      profileData!['phone'] = newValue;
                    } else {
                      profileData!['email'] = newValue;
                    }

                  });

                  Navigator.pop(context);

                  Flushbar(
                    message: "تم حفظ التغيير بنجاح",
                    duration: const Duration(seconds: 3),
                    flushbarPosition: FlushbarPosition.TOP,
                    backgroundColor: Colors.green,
                  ).show(context);

                } else {

                  Navigator.pop(context);

                    Flushbar(
                    message: result['message'] ??
                        "تعذر حفظ التغيير",
                    duration: const Duration(seconds: 3),
                    flushbarPosition: FlushbarPosition.TOP,
                    backgroundColor: Colors.red,
                  ).show(context);

                }
             },
            child: const Text("حفظ"),
          ),
        ],
      );
    },
  );
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
                bottomLeft: Radius.circular(45),
                bottomRight: Radius.circular(45),
              ),
            ),
            child: Row(
              children: [

                /// زر الرجوع بنفس ستايل النظام
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
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 18),

                const Expanded(
                  child: Text(
                    "الملف الشخصي",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          /// ================= CONTENT =================
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : profileData == null
                    ? const Center(
                        child: Text("حدث خطأ في تحميل البيانات"),
                      )
                    : ListView(
  padding: const EdgeInsets.symmetric(horizontal: 20),
  children: [

    /// 👤 بطاقة الاسم الجديدة
    _animatedItem(
      index: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
            )
          ],
        ),
        child: Row(
          children: [

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.teacherPrimary
                    .withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                color: AppColors.teacherPrimary,
                size: 28,
              ),
            ),

            const SizedBox(width: 18),

            Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  "اسم المعلم",
                  style:
                      TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 6),
                Text(
                  profileData!['name'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    ),

    const SizedBox(height: 18),

    _buildInfoCard(
      icon: Icons.phone,
      title: "رقم الهاتف",
      value: profileData?['phone'] ?? "-",
    ),

    _buildInfoCard(
      icon: Icons.email,
      title: "البريد الإلكتروني",
      value: profileData?['email'] ?? "-",
    ),
    _animatedItem(
      index: 3,
      child: _buildInfoCard(
        icon: Icons.school,
        title: "المدرسة",
        value: profileData!['school_name'],
      ),
    ),

    _animatedItem(
      index: 4,
      child: _buildInfoCard(
        icon: Icons.timer,
        title: "عدد الحصص الأسبوعية",
        value:
            profileData!['total_periods']
                .toString(),
      ),
    ),

    const SizedBox(height: 20),

    /// المواد
    _animatedItem(
      index: 5,
      child: Container(
        padding:
            const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withOpacity(0.05),
              blurRadius: 12,
            )
          ],
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            const Text(
              "المواد التي يدرسها",
              style: TextStyle(
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List<String>.from(
                      profileData![
                          'subjects'])
                  .map(
                    (subject) =>
                        Container(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration:
                          BoxDecoration(
                        color: AppColors
                            .teacherPrimary
                            .withOpacity(
                                0.1),
                        borderRadius:
                            BorderRadius
                                .circular(
                                    20),
                      ),
                      child: Text(
                        subject,
                        style:
                            const TextStyle(
                          color: AppColors
                              .teacherPrimary,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    ),

    const SizedBox(height: 30),
  ],
)
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
  required IconData icon,
  required String title,
  required String value,
  bool isEditable = false,
  VoidCallback? onEdit,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
          )
        ],
      ),
      child: Column(
        children: [

          if (isEditable)
            Row(
              children: [

                const Spacer(),

                InkWell(
                  onTap: onEdit,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.teacherPrimary
                          .withOpacity(0.08),
                      borderRadius:
                          BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        Icon(
                          Icons.edit,
                          size: 15,
                          color: AppColors.teacherPrimary,
                        ),

                        SizedBox(width: 4),

                        Text(
                          "تغيير",
                          style: TextStyle(
                            color: AppColors.teacherPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

          if (isEditable)
            const SizedBox(height: 10),

          Row(
            children: [

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.teacherPrimary
                      .withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: AppColors.teacherPrimary,
                ),
              ),

              const SizedBox(width: 18),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [

                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      value,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _animatedItem({
  required int index,
  required Widget child,
}) {
  return TweenAnimationBuilder(
    tween: Tween(
        begin: 50.0, end: 0.0),
    duration:
        Duration(milliseconds: 400 + (index * 100)),
    curve: Curves.easeOut,
    builder:
        (context, double value, widgetChild) {
      return Transform.translate(
        offset: Offset(0, value),
        child: Opacity(
          opacity:
              1 - (value / 50),
          child: widgetChild,
        ),
      );
    },
    child: child,
  );
}

}