import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:another_flushbar/flushbar.dart';
import '../core/app_colors.dart';
import '../core/widgets/app_card.dart';
import 'school_home_screen.dart';

class SchoolSelectorScreen extends StatefulWidget {

  final bool showBackButton;

  const SchoolSelectorScreen({
    super.key,
    this.showBackButton = false,
  });

  @override
  State<SchoolSelectorScreen> createState() =>
      _SchoolSelectorScreenState();
}


class _SchoolSelectorScreenState extends State<SchoolSelectorScreen> {
  String? selectedCountry;
  int? selectedSchoolId;

  bool isLoadingSchools = false;

  List<Map<String, dynamic>> schools = [];

  final List<Map<String, String>> countries = [
  {
    "name": "سلطنة عمان",
    "value": "Oman",
    "flag": "🇴🇲",
  },
  {
    "name": "دولة قطر",
    "value": "Qatar",
    "flag": "🇶🇦",
  },
  {
    "name": "الإمارات العربية المتحدة",
    "value": "UAE",
    "flag": "🇦🇪",
  },
  {
    "name": "المملكة العربية السعودية",
    "value": "Saudi Arabia",
    "flag": "🇸🇦",
  },
  {
    "name": "دولة الكويت",
    "value": "Kuwait",
    "flag": "🇰🇼",
  },
  {
    "name": "مملكة البحرين",
    "value": "Bahrain",
    "flag": "🇧🇭",
  },
  {
    "name": "جمهورية العراق",
    "value": "Iraq",
    "flag": "🇮🇶",
  },
  {
    "name": "المملكة الأردنية الهاشمية",
    "value": "Jordan",
    "flag": "🇯🇴",
  },
  {
    "name": "الجمهورية العربية السورية",
    "value": "Syria",
    "flag": "🇸🇾",
  },
  {
    "name": "جمهورية مصر العربية",
    "value": "Egypt",
    "flag": "🇪🇬",
  },
];

  Future<void> loadSchools(String country) async {
    setState(() {
      isLoadingSchools = true;
      schools.clear();
      selectedSchoolId = null;
    });

    try {
      final response = await http.get(
        Uri.parse(
          'https://abuobaida-edu.com/api/schools-by-country/$country',
        ),
      );

      if (response.statusCode == 200) {
  final List data = json.decode(response.body);

  setState(() {
    schools = data.map<Map<String, dynamic>>((item) {
      return {
        "id": item["id"],
        "name": item["name"],
        "logo": item["logo"] ?? "",
      };
    }).toList();
  });

  if (schools.isEmpty && mounted) {
    Flushbar(
      message: 'لا توجد مدارس متاحة في هذه الدولة حالياً',
      duration: const Duration(seconds: 3),
      flushbarPosition: FlushbarPosition.TOP,
      margin: const EdgeInsets.all(12),
      borderRadius: BorderRadius.circular(12),
      icon: const Icon(
        Icons.info_outline,
        color: Colors.white,
      ),
    ).show(context);
  }
}
    } catch (e) {
      debugPrint(e.toString());
    }

    setState(() {
      isLoadingSchools = false;
    });
  }

  Future<void> saveSchool() async {
    if (selectedSchoolId == null) return;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(
      'school_id',
      selectedSchoolId!,
    );

    if (!mounted) return;

    final selectedSchool = schools.firstWhere(
  (school) => school["id"] == selectedSchoolId,
);

await prefs.setString(
  'school_name',
  selectedSchool["name"] ?? '',
);

await prefs.setString(
  'school_logo',
  selectedSchool["logo"] ?? '',
);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const SchoolHomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
     print('BUILD SchoolSelectorScreen');
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 70,
              bottom: 50,
              left: 24,
              right: 24,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.secondary,
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
              children: [
                if (widget.showBackButton)
                    Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.20),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                  if (widget.showBackButton)
                    const SizedBox(height: 20),
                Container(
                  width: 95,
                  height: 95,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    "assets/images/platform_logo.png",
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "EduBehave Platform",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "اختر دولتك ومدرستك للمتابعة",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "الدولة",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 12),

                        DropdownButtonFormField<String>(
                          value: selectedCountry,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          items: countries.map((country) {
                            return DropdownMenuItem<String>(
                              value: country["value"],
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    country["flag"]!,
                                    style: const TextStyle(fontSize: 22),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(country["name"]!),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value == null) return;

                            setState(() {
                              selectedCountry = value;
                            });

                            loadSchools(value);
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  if (isLoadingSchools)
                    const Padding(
                      padding: EdgeInsets.all(30),
                      child: CircularProgressIndicator(),
                    ),

                  if (!isLoadingSchools && schools.isNotEmpty)
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "المدرسة",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<int>(
                              value: selectedSchoolId,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                prefixIcon: const Icon(Icons.school),
                              ),
                              items: schools.map((school) {
                                return DropdownMenuItem<int>(
                                  value: school["id"],
                                  child: Text(
                                    school["name"],
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedSchoolId = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),

                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed:
                          selectedSchoolId == null
                              ? null
                              : saveSchool,
                      icon: const Icon(
                        Icons.arrow_forward_rounded,
                      ),
                      label: const Text(
                        "دخول المنصة",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    "© EduBehave Platform",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}