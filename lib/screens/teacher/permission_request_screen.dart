// =======================================================
// 📝 صفحة طلب الاستئذان للمعلم
// تصميم متوافق مع صفحات المعلم
//
// المهام:
// - اختيار التاريخ
// - اختيار وقت الخروج والعودة
// - كتابة السبب
// - فحص موقع المدرسة
// - إرسال الطلب
// =======================================================

import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';

import '../../core/app_colors.dart';
import '../../services/location_service.dart';
import '../../services/teacher_permission_service.dart';
import 'dart:async';

class PermissionRequestScreen extends StatefulWidget {

  final int teacherId;
  final int schoolId;


  const PermissionRequestScreen({
    super.key,
    required this.teacherId,
    required this.schoolId,
  });


  @override
  State<PermissionRequestScreen> createState()
      => _PermissionRequestScreenState();
}



class _PermissionRequestScreenState
    extends State<PermissionRequestScreen> {


  DateTime selectedDate = DateTime.now();

  DateTime currentExitTime = DateTime.now();

  Timer? timer;

  TimeOfDay? toTime;

  bool loading = false;


  final reasonController =
      TextEditingController();

      @override
void initState() {
  super.initState();

  timer = Timer.periodic(
    const Duration(seconds: 1),
    (timer) {

      setState(() {
        currentExitTime = DateTime.now();
      });

    },
  );
}


@override
void dispose() {

  timer?.cancel();
  reasonController.dispose();

  super.dispose();
}



  // ==============================
  // اختيار التاريخ
  // ==============================
  Future<void> pickDate() async {

    final picked =
        await showDatePicker(

      context: context,

      firstDate: DateTime.now(),

      lastDate:
          DateTime.now()
              .add(
                const Duration(days: 60),
              ),

      initialDate:
          DateTime.now(),

    );


    if (picked != null) {

      setState(() {

        selectedDate = picked;

      });

    }

  }



  // ==============================
  // اختيار الوقت
  // ==============================
  Future<void> pickTime(
      bool start) async {


    final picked =
        await showTimePicker(

      context: context,

      initialTime:
          TimeOfDay.now(),

    );


    if (picked != null) {

  setState(() {

    toTime = picked;

  });

}
      }

    // ==============================
  // رسالة من الأعلى
  // ==============================
  void showMessage(
    String title,
    String message,
    bool success,
  ) {

    Flushbar(

      margin: const EdgeInsets.all(16),

      borderRadius:
          BorderRadius.circular(20),

      duration:
          const Duration(seconds: 3),

      flushbarPosition:
          FlushbarPosition.TOP,

      backgroundGradient:
          LinearGradient(

        colors: success

            ? [
                Colors.green.shade600,
                Colors.green.shade400,
              ]

            : [
                Colors.red.shade600,
                Colors.red.shade400,
              ],

      ),


      icon: Icon(

        success
            ? Icons.check_circle
            : Icons.error,

        color: Colors.white,

      ),


      titleText: Text(

        title,

        style: const TextStyle(

          color: Colors.white,

          fontWeight:
              FontWeight.bold,

        ),

      ),


      messageText: Text(

        message,

        style: const TextStyle(

          color: Colors.white,

        ),

      ),


    ).show(context);

  }



  // ==============================
  // إرسال طلب الاستئذان
  // ==============================
  Future<void> sendPermission() async {


    if (toTime == null) {

      showMessage(
        "تنبيه",
        "يرجى اختيار التاريخ والوقت",
        false,
      );

      return;

    }



    setState(() {
      loading = true;
    });

    print("=========================");
print("SCHOOL FROM SCREEN = ${widget.schoolId}");
print("TEACHER FROM SCREEN = ${widget.teacherId}");
print("=========================");

    // 📍 فحص موقع المدرسة
    final location =
        await LocationService
            .checkTeacherLocation(

      schoolId:
          widget.schoolId,

    );



    if (location['status'] != true) {


      setState(() {
        loading = false;
      });


      showMessage(

        "خارج نطاق المدرسة",

        location['message'],

        false,

      );


      return;

    }



    // إرسال للسيرفر
    final result =
        await TeacherPermissionService
            .sendPermission(


      schoolId:
          widget.schoolId,


      teacherId:
          widget.teacherId,


      date:
        selectedDate
            .toString()
            .substring(0, 10),


      fromTime:
        "${currentExitTime.hour}:${currentExitTime.minute}",


      toTime:
          "${toTime!.hour}:${toTime!.minute}",


      reason:
          reasonController.text,


      // موقع المعلم الحقيقي
      latitude:
          location['latitude'],

      longitude:
          location['longitude'],

    );



    setState(() {
      loading = false;
    });



    showMessage(

      result['status'] == true
          ? "تم بنجاح"
          : "تنبيه",


      result['message'],


      result['status'] == true,

    );

    if (result['status'] == true) {

    setState(() {

      selectedDate =
          DateTime.now();

      toTime = null;

      reasonController.clear();

    });

  }


  }

    @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(0xffF3F6FB),


      body: Column(

        children: [


          // ==============================
          // الهيدر
          // ==============================
          Container(

            width: double.infinity,

            padding:
                const EdgeInsets.only(
              top: 60,
              right: 20,
              left: 20,
              bottom: 35,
            ),


            decoration:
                const BoxDecoration(

              gradient:
                  LinearGradient(

                colors: [

                  AppColors.teacherPrimary,

                  AppColors.teacherSecondary,

                ],

                begin:
                    Alignment.topRight,

                end:
                    Alignment.bottomLeft,

              ),


              borderRadius:
                  BorderRadius.only(

                bottomLeft:
                    Radius.circular(40),

                bottomRight:
                    Radius.circular(40),

              ),

            ),


            child: Row(

              children: [


                InkWell(

                  onTap: () {
                    Navigator.pop(context);
                  },


                  child: Container(

                    padding:
                        const EdgeInsets.all(12),


                    decoration:
                        BoxDecoration(

                      color:
                          Colors.white
                              .withOpacity(0.18),

                      shape:
                          BoxShape.circle,

                    ),


                    child:
                        const Icon(

                      Icons.arrow_back,

                      color:
                          Colors.white,

                    ),

                  ),

                ),


                const SizedBox(width: 18),


                const Text(

                  "طلب استئذان",

                  style:
                      TextStyle(

                    color:
                        Colors.white,

                    fontSize: 24,

                    fontWeight:
                        FontWeight.bold,

                  ),

                ),

              ],

            ),

          ),



          const SizedBox(height: 25),



          Expanded(

            child:
                SingleChildScrollView(

              padding:
                  const EdgeInsets.all(20),


              child: Column(

                children: [


                  // التاريخ
                  _card(
                      icon:
                          Icons.calendar_month,

                      title:
                          "تاريخ اليوم",


                      value:
                          selectedDate
                              .toString()
                              .substring(0,10),


                      onTap: () {},

                    ),



                  const SizedBox(height: 15),



                  Row(

                    children: [


                     Expanded(

  child: _card(

    icon:
        Icons.access_time,

    title:
        "وقت الخروج الآن",

    value:
        "${currentExitTime.hour.toString().padLeft(2,'0')}:"
        "${currentExitTime.minute.toString().padLeft(2,'0')}:"
        "${currentExitTime.second.toString().padLeft(2,'0')}",

    onTap: () {},

  ),

),



                      const SizedBox(width: 15),



                      Expanded(

                        child: _card(

                          icon:
                              Icons.logout,

                          title:
                              "إلى الساعة",


                          value:
                              toTime == null

                                  ? "--"

                                  : toTime!
                                      .format(context),


                          onTap:
                              () => pickTime(false),

                        ),

                      ),

                    ],

                  ),



                  const SizedBox(height: 15),



                  Container(

                    padding:
                        const EdgeInsets.all(20),


                    decoration:
                        BoxDecoration(

                      color:
                          Colors.white,


                      borderRadius:
                          BorderRadius.circular(25),


                      boxShadow: [

                        BoxShadow(

                          color:
                              Colors.black
                                  .withOpacity(0.05),

                          blurRadius: 15,

                        )

                      ],

                    ),


                    child:
                        TextField(

                      controller:
                          reasonController,


                      maxLines: 4,


                      decoration:
                          const InputDecoration(

                        border:
                            InputBorder.none,

                        hintText:
                            "اكتب سبب الاستئذان...",

                      ),

                    ),

                  ),



                  const SizedBox(height: 30),



                  SizedBox(

                    width:
                        double.infinity,

                    height:
                        55,


                    child:

                    loading

                        ? const Center(
                            child:
                                CircularProgressIndicator(),
                          )


                        : ElevatedButton(

                            style:
                                ElevatedButton.styleFrom(

                              backgroundColor:
                                  AppColors.teacherPrimary,


                              shape:
                                  RoundedRectangleBorder(

                                borderRadius:
                                    BorderRadius.circular(20),

                              ),

                            ),


                            onPressed:
                                sendPermission,


                            child:
                                const Text(

                              "إرسال طلب الاستئذان",

                              style:
                                  TextStyle(

                                fontSize: 17,

                                fontWeight:
                                    FontWeight.bold,

                              ),

                            ),

                          ),

                  )

                ],

              ),

            ),

          )

        ],

      ),

    );

  }



  // ==============================
  // كرت اختيار
  // ==============================
  Widget _card({

    required IconData icon,

    required String title,

    required String value,

    required VoidCallback onTap,

  }) {

    return GestureDetector(

      onTap:
          onTap,


      child:
          Container(

        padding:
            const EdgeInsets.all(18),


        decoration:
            BoxDecoration(

          color:
              Colors.white,


          borderRadius:
              BorderRadius.circular(25),


          boxShadow: [

            BoxShadow(

              color:
                  Colors.black
                      .withOpacity(0.05),

              blurRadius: 15,

            ),

          ],

        ),


        child:
            Row(

          children: [


            Icon(

              icon,

              color:
                  AppColors.teacherPrimary,

            ),


            const SizedBox(width: 12),


            Expanded(

              child:
                  Column(

                crossAxisAlignment:
                    CrossAxisAlignment.start,


                children: [


                  Text(

                    title,

                    style:
                        const TextStyle(

                      fontWeight:
                          FontWeight.bold,

                    ),

                  ),


                  const SizedBox(height: 5),


                  Text(

                    value,

                    style:
                        const TextStyle(

                      color:
                          Colors.grey,

                    ),

                  ),

                ],

              ),

            ),

          ],

        ),

      ),

    );

  }

}