import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SchoolRecordsScreen extends StatefulWidget {
  const SchoolRecordsScreen({super.key});

  @override
  State<SchoolRecordsScreen> createState() => _SchoolRecordsScreenState();
}

class _SchoolRecordsScreenState extends State<SchoolRecordsScreen> {

  List records = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadRecords();
  }

  Future<void> loadRecords() async {

    try {

      final response = await http.get(
        Uri.parse("https://abuobaida-edu.com/api/school/records/1"),
      );

      final data = json.decode(response.body);

      setState(() {
        records = data["data"];
        isLoading = false;
      });

    } catch (e) {

      setState(() {
        isLoading = false;
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
                  borderRadius: BorderRadius.circular(40),
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),

                const SizedBox(width: 15),

                const Text(
                  "الإشعارات المستقبلة",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

              ],
            ),
          ),

          const SizedBox(height: 20),

          /// ================= قائمة السجلات =================
          Expanded(

            child: isLoading

                ? const Center(child: CircularProgressIndicator())

                : ListView.builder(

                    padding: const EdgeInsets.symmetric(horizontal: 20),

                    itemCount: records.length,

                    itemBuilder: (context, index) {

                      var item = records[index];

                      bool isSwap =
                          item["source"] == "swap_request";

                      return Container(

                        margin: const EdgeInsets.only(bottom: 15),

                        padding: const EdgeInsets.all(18),

                        decoration: BoxDecoration(

                          gradient: LinearGradient(
                            colors: isSwap
                                ? [
                                    const Color(0xfff7971e),
                                    const Color(0xffffd200)
                                  ]
                                : [
                                    const Color(0xff2193b0),
                                    const Color(0xff6dd5ed)
                                  ],
                          ),

                          borderRadius: BorderRadius.circular(20),

                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 10,
                            )
                          ],
                        ),

                        child: Row(
                          children: [

                            Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isSwap ? Icons.swap_horiz : Icons.mail,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),

                            const SizedBox(width: 15),

                            Expanded(
                              child: isSwap

                                  /// ================= طلب تبديل =================
                                  ? Row(
                                      children: [

                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [

                                              const Text(
                                                "المعلم الأصلي",
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.white70,
                                                ),
                                              ),

                                              Text(
                                                item["original_teacher"] ?? "-",
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),

                                              Text(
                                                "الحصة ${item["original_period"] ?? "-"}",
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.white70,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 10),
                                          child: Container(
                                            width: 1,
                                            height: 40,
                                            color: Colors.white30,
                                          ),
                                        ),

                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [

                                              const Text(
                                                "المعلم البديل",
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.white70,
                                                ),
                                              ),

                                              Text(
                                                item["replacement_teacher"] ?? "-",
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),

                                              Text(
                                                "الحصة ${item["target_period"] ?? "-"}",
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.white70,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                      ],
                                    )

                                  /// ================= رسالة ولي أمر =================
                                    : Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [

                                          Text(
                                            item["student_name"] ?? "",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: Colors.white,
                                            ),
                                          ),

                                          const SizedBox(height: 4),

                                          Text(
                                            "${item["class"] ?? ""} - ${item["section"] ?? ""}",
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 12,
                                            ),
                                          ),

                                          const SizedBox(height: 6),

                                          Row(
                                            children: [

                                              const Expanded(
                                                child: Text(
                                                  "رسالة من ولي الأمر",
                                                  style: TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),

                                              GestureDetector(
                                                onTap: () {
                                                  _showMessageDialog(item);
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 6,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(20),
                                                  ),
                                                  child: const Text(
                                                    "عرض",
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              )

                                            ],
                                          ),

                                        ],
                                    ),
                                                                ),

                                                              ],
                                                            ),
                                                          );

                                                        },
                                                      ),

                                              ),

                                            ],
                                          ),
                                        );
                                      }

  void _showMessageDialog(dynamic item) {

  showDialog(
    context: context,
    builder: (context) {

      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),

        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [

              const Icon(
                Icons.mail_outline,
                size: 40,
                color: Colors.blue,
              ),

              const SizedBox(height: 10),

              Text(
                item["student_name"] ?? "",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 15),

              Text(
                item["message"] ?? "",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("إغلاق"),
              )

            ],
          ),
        ),
      );

    },
  );

}

}