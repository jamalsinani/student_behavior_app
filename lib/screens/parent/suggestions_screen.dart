import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
import '../../services/parent_service.dart';

class SuggestionsScreen extends StatefulWidget {

  final String studentId;

  const SuggestionsScreen({
    super.key,
    required this.studentId,
  });

  @override
  State<SuggestionsScreen> createState() => _SuggestionsScreenState();
}

class _SuggestionsScreenState extends State<SuggestionsScreen> {

  final titleController = TextEditingController();
  final messageController = TextEditingController();

  String type = "note";

  bool isSending = false;

  /// إرسال الرسالة
  sendSuggestion() async {

    if (titleController.text.isEmpty || messageController.text.isEmpty) {

      Flushbar(
        message: "يرجى إدخال العنوان والرسالة",
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red,
      ).show(context);

      return;
    }

    setState(() {
      isSending = true;
    });

    try {

      final res = await ParentService.sendSuggestion(

        studentId: widget.studentId,
        title: titleController.text,
        message: messageController.text,
        type: type,

      );

      if (res["success"] == true) {

        titleController.clear();
        messageController.clear();

        Flushbar(
          message: "تم إرسال الرسالة بنجاح",
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.green,
          flushbarPosition: FlushbarPosition.TOP,
          margin: const EdgeInsets.all(12),
          borderRadius: BorderRadius.circular(12),
        ).show(context);
      }

    } catch (e) {

      Flushbar(
        message: "حدث خطأ أثناء الإرسال",
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red,
        flushbarPosition: FlushbarPosition.TOP,
        margin: const EdgeInsets.all(12),
        borderRadius: BorderRadius.circular(12),
      ).show(context);

    }

    setState(() {
      isSending = false;
    });
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
                  "مقترحات وملاحظات",
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
            child: ListView(

              padding: const EdgeInsets.symmetric(horizontal: 20),

              children: [

                /// عنوان
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: "عنوان الرسالة",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 15),

                /// نوع الرسالة
                DropdownButtonFormField(
                  value: type,
                  items: const [
                    DropdownMenuItem(
                      value: "note",
                      child: Text("ملاحظة"),
                    ),
                    DropdownMenuItem(
                      value: "suggestion",
                      child: Text("مقترح"),
                    ),
                  ],
                  onChanged: (v) {
                    setState(() {
                      type = v.toString();
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: "نوع الرسالة",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 15),

                /// الرسالة
                TextField(
                  controller: messageController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: "نص الرسالة",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 25),

                /// زر الإرسال
                ElevatedButton(

                  onPressed: isSending ? null : sendSuggestion,

                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),

                  child: isSending
                      ? const CircularProgressIndicator()
                      : const Text("إرسال"),
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