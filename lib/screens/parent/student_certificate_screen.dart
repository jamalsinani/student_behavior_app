import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:another_flushbar/flushbar.dart';
import '../../services/parent_service.dart';

class StudentCertificateScreen extends StatefulWidget {

  final String studentId;

  const StudentCertificateScreen({
    super.key,
    required this.studentId,
  });

  @override
  State<StudentCertificateScreen> createState() => _StudentCertificateScreenState();
}

class _StudentCertificateScreenState extends State<StudentCertificateScreen> {

  Map certificates = {};
  bool isLoading = true;

  /// جلب الشهادات
  Future fetchCertificates() async {

    try {

      final data = await ParentService.getStudentCertificates(widget.studentId);

      setState(() {
        certificates = data;
        isLoading = false;
      });

    } catch (e) {

      setState(() {
        isLoading = false;
      });

      Flushbar(
        message: "تعذر جلب الشهادات",
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red,
      ).show(context);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCertificates();
  }

  /// فتح الشهادة
  Future openCertificate(String url) async {

    final Uri uri = Uri.parse(url);

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {

      Flushbar(
        message: "تعذر فتح الشهادة",
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red,
      ).show(context);

    }
  }

  /// بطاقة الشهادة
  Widget certificateCard({
    required String title,
    required String? url,
    required Color color,
  }) {

    return Container(

      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(

        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.9),
            color.withOpacity(0.7),
          ],
        ),

        borderRadius: BorderRadius.circular(22),

        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.35),
            blurRadius: 15,
            offset: const Offset(0,6),
          )
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [

              const Icon(
                Icons.workspace_premium,
                color: Colors.white,
                size: 30,
              ),

              const SizedBox(width: 10),

              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          if (url != null && url.isNotEmpty)

            ElevatedButton.icon(

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

              onPressed: () => openCertificate(url),

              icon: const Icon(Icons.picture_as_pdf),

              label: const Text("عرض الشهادة"),
            )

          else

            const Text(
              "لم يتم رفع الشهادة بعد",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final colors = Theme.of(context).colorScheme;

    return Scaffold(

      body: Column(
        children: [

          /// HEADER
          Container(
            width: double.infinity,

            padding: const EdgeInsets.only(
              top: 65,
              right: 20,
              left: 20,
              bottom: 30,
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

                const SizedBox(width: 10),

                const Text(
                  "الشهادات الدراسية",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Expanded(

            child: isLoading

                ? const Center(child: CircularProgressIndicator())

                : ListView(

              children: [

                certificateCard(
                  title: "شهادة الفصل الأول",
                  url: certificates["first"],
                  color: Colors.green,
                ),

                certificateCard(
                  title: "شهادة الفصل الثاني",
                  url: certificates["second"],
                  color: Colors.blue,
                ),

                const SizedBox(height: 30),
              ],
            ),
          )
        ],
      ),
    );
  }
}