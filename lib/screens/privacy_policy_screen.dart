import 'package:flutter/material.dart';
import '../services/privacy_service.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {

  String policyText = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPolicy();
  }

  Future<void> loadPolicy() async {
    try {
      final data = await PrivacyService.fetchPrivacyPolicy();

      setState(() {
        policyText = data;
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
            padding: const EdgeInsets.fromLTRB(25, 70, 25, 35),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xff0f2027),
                  Color(0xff203a43),
                  Color(0xff2c5364),
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(35),
                bottomRight: Radius.circular(35),
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
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),

                const SizedBox(width: 15),

                const Text(
                  "سياسة الاستخدام",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

              ],
            ),
          ),

          const SizedBox(height: 20),

          /// ================= المحتوى =================
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),

              child: isLoading
                  ? const Center(child: CircularProgressIndicator())

                  : policyText.isEmpty
                      ? _emptyState()

                      : SingleChildScrollView(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                )
                              ],
                            ),

                            child: Text(
                              policyText,
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontSize: 15.5,
                                height: 2,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
            ),
          ),

        ],
      ),
    );
  }

  /// ================= حالة فارغة =================
  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [

          Icon(Icons.description_outlined,
              size: 60,
              color: Colors.grey),

          SizedBox(height: 10),

          Text(
            "لا توجد سياسة حالياً",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          )

        ],
      ),
    );
  }
}