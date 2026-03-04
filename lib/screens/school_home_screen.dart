import 'dart:async';
import 'package:flutter/material.dart';
import 'auth/login_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class SchoolHomeScreen extends StatefulWidget {
  const SchoolHomeScreen({super.key});

  @override
  State<SchoolHomeScreen> createState() => _SchoolHomeScreenState();
}

class _SchoolHomeScreenState extends State<SchoolHomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final PageController _adsController = PageController();

  int currentAd = 0;
  Timer? _timer;

  String schoolLogo = "assets/images/default_school.png";

  List<String> adsImages = [];

  List<Map<String, String>> stats = [];

  List<Map<String, String>> latestNews = [];

  List<Map<String, String>> supporters = [];

  Future<void> loadAds() async {

  final url = Uri.parse(
      "https://abuobaida-edu.com/api/school-home/1");

  final response = await http.get(url);

  if (response.statusCode == 200) {

    final data = json.decode(response.body);

    setState(() {
          // الإعلانات
      adsImages = List<String>.from(
        data["ads"].map((item) => item["image"])
      );
      // الاحصائيات
    
      stats = [
    {"icon": "👨‍🎓", "title": data["school"]["students"], "subtitle": "طالب"},
    {"icon": "👨‍🏫", "title": data["school"]["teachers"], "subtitle": "معلم"},
    {"icon": "🏫", "title": data["school"]["classes"], "subtitle": "فصل"},
    {"icon": "📍", "title": data["school"]["location"], "subtitle": "الموقع"},
    {"icon": "🎓", "title": data["school"]["stage"], "subtitle": "المرحلة"},
  ];
      // آخر الأخبار
      latestNews = List<Map<String, String>>.from(
    data["news"].map((item) => {
      "title": item["title"].toString(),
      "subtitle": item["subtitle"].toString(),
      "instagram_url": item["instagram_url"].toString(),
    }),
  );

      // الداعمون
      // الداعمون
  supporters = List<Map<String, String>>.from(
    data["supporters"].map((item) => {
      "name": item["name"].toString(),
      "logo": item["logo"].toString(),
    }),
  );

  
    });

  }

}

  @override
void initState() {
  super.initState();

  loadAds();

  _timer = Timer.periodic(const Duration(seconds: 4), (timer) {

    if (adsImages.isEmpty) return;

    currentAd = (currentAd + 1) % adsImages.length;

    _adsController.animateToPage(
      currentAd,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );

  });
}

  @override
  void dispose() {
    _timer?.cancel();
    _adsController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff4f6fb),

      // ================= BODY =================
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [

            // ================= HERO =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 50),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xff0f2027),
                    Color(0xff203a43),
                    Color(0xff2c5364),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage(schoolLogo),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "مدرسة الشيخ ابو عبيدة عبدالله بن محمد البلوشي (5-9)",
                    textAlign: TextAlign.center,
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

            // ================= ADS =================
            _sectionTitle("الإعلانات"),
            const SizedBox(height: 15),

            SizedBox(
  height: 200,
  child: adsImages.isEmpty
      ? const Center(child: CircularProgressIndicator())
      : PageView.builder(
          controller: _adsController,
          itemCount: adsImages.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Image.network(
                  adsImages[index],
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
        ),
),

            const SizedBox(height: 30),

            // ================= STATS =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: stats.map((item) {
                  return Expanded(
                    child: Column(
                      children: [
                        Container(
                          height: 65,
                          width: 65,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xff203a43),
                                Color(0xff2c5364),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              )
                            ],
                          ),
                          child: Center(
                            child: Text(
                              item["icon"]!,
                              style: const TextStyle(fontSize: 22),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(item["title"]!,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold)),
                        Text(item["subtitle"]!,
                            style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 25),

           // ================= NEWS =================
Padding(
  padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
  child: Align(
    alignment: Alignment.centerRight,
    child: Text(
      "آخر الأخبار",
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
),

const SizedBox(height: 12),

Column(
  children: List.generate(latestNews.length, (index) {
    final news = latestNews[index];

    return GestureDetector(
  onTap: () {
    if (news["instagram_url"] != null &&
        news["instagram_url"]!.isNotEmpty) {
      openInstagram(news["instagram_url"]!);
    }
  },
  child: Container(
    margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 10,
        )
      ],
    ),
    child: Row(
      children: [
        Container(
          width: 4,
          height: 45,
          decoration: BoxDecoration(
            color: const Color(0xff203a43),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                news["title"] ?? "",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                news["subtitle"] ?? "",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        )
      ],
    ),
  ),
);
  }),
),


const SizedBox(height: 30),

            // ================= SUPPORTERS =================
_sectionTitle("الداعمون"),
const SizedBox(height: 15),

SizedBox(
  height: 130,
  child: ListView.builder(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(horizontal: 20),
    itemCount: supporters.length,
    itemBuilder: (context, index) {
      final supporter = supporters[index];

      return Container(
        width: 140,
        margin: const EdgeInsets.only(left: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey.shade200,
              child: supporter["logo"]!.isEmpty
                  ? const Icon(Icons.business, size: 30)
                  : Image.network(
                    supporter["logo"]!,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              supporter["name"]!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    },
  ),
),

const SizedBox(height: 40),
          ],
        ),
      ),

      // ================= LOGIN BUTTON =================
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: SizedBox(
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff203a43),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 10,
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  ),
                );
              },
              child: const Text(
                "الدخول إلى التطبيق",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          title,
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Future<void> openInstagram(String url) async {

  final uri = Uri.parse(url);

  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

}

}