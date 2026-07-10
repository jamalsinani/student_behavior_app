import 'package:flutter/material.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f7fb),

      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [

          /// ================= الهيدر =================
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            elevation: 0,
            backgroundColor: const Color(0xff203A43),

            leading: Padding(
            padding: const EdgeInsets.all(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: () => Navigator.pop(context),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),

            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,

              title: const Text(
                "عن التطبيق",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xff0F2027),
                      Color(0xff203A43),
                      Color(0xff2C5364),
                    ],
                  ),
                ),

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    const SizedBox(height: 40),

                    Container(
                    width: 120,
                    height: 120,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(35),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 25,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      "assets/images/platform_logo.png",
                      fit: BoxFit.contain,
                    ),
                  ),
                    const SizedBox(height: 20),

                    const Text(
                      "EduBehave Platform",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "منصة رقمية متكاملة لإدارة التواصل",
                      style: TextStyle(
                        color: Colors.white.withOpacity(.9),
                        fontSize: 14,
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ),

          /// ================= المحتوى =================
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [

                  /// نبذة
                  _sectionCard(
                    title: "نبذة عن التطبيق",
                    icon: Icons.info_outline_rounded,
                    content:
                        "يهدف التطبيق إلى تعزيز التواصل بين المدرسة وأولياء الأمور والمعلمين، وتوفير منصة ذكية لمتابعة السلوك الطلابي والإنجازات اليومية بشكل فوري وآمن.",
                  ),

                  const SizedBox(height: 18),

                  /// الأهداف
                  _sectionCard(
                    title: "أهداف التطبيق",
                    icon: Icons.flag_outlined,
                    content:
                        "• تعزيز الانضباط المدرسي\n\n"
                        "• تحسين التواصل مع أولياء الأمور\n\n"
                        "• متابعة الأداء السلوكي للطلاب\n\n"
                        "• دعم اتخاذ القرار التربوي",
                  ),

                  const SizedBox(height: 18),

                  /// المميزات
                  _sectionCard(
                    title: "مميزات التطبيق",
                    icon: Icons.star_outline_rounded,
                    content:
                        "• إشعارات فورية\n\n"
                        "• متابعة السلوك اليومي\n\n"
                        "• عرض الإنجازات والشهادات\n\n"
                        "• التواصل مع المدرسة\n\n"
                        "• واجهة سهلة وسريعة",
                  ),

                  const SizedBox(height: 22),

                  /// بطاقات المعلومات
                  Row(
                    children: [

                      Expanded(
                        child: _statCard(
                          icon: Icons.person,
                          title: "المطور",
                          value: "جمال السناني",
                        ),
                      ),

                      const SizedBox(width: 15),

                      Expanded(
                        child: _statCard(
                          icon: Icons.verified,
                          title: "الإصدار",
                          value: "1.0.1",
                        ),
                      ),

                    ],
                  ),

                  const SizedBox(height: 15),

                  Row(
                    children: [

                      Expanded(
                        child: _statCard(
                          icon: Icons.code,
                          title: "رقم النظام",
                          value: "38",
                        ),
                      ),

                      const SizedBox(width: 15),

                      Expanded(
                        child: _statCard(
                          icon: Icons.calendar_month,
                          title: "سنة الإصدار",
                          value: "2026",
                        ),
                      ),

                    ],
                  ),

                  const SizedBox(height: 30),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xff203A43),
                          Color(0xff2C5364),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Column(
                      children: [

                        Icon(
                          Icons.favorite,
                          color: Colors.white,
                          size: 30,
                        ),

                        SizedBox(height: 10),

                        Text(
                          "صنع بعناية لخدمة البيئة التعليمية",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                ],
              ),
            ),
          ),

        ],
      ),
    );
  }

  static Widget _sectionCard({
    required String title,
    required IconData icon,
    required String content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 15,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [

              Icon(
                icon,
                color: const Color(0xff203A43),
              ),

              const SizedBox(width: 10),

              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),

            ],
          ),

          const SizedBox(height: 15),

          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.8,
            ),
          ),

        ],
      ),
    );
  }

  static Widget _statCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 20,
        horizontal: 15,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        children: [

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xff203A43).withOpacity(.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: const Color(0xff203A43),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            title,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),

        ],
      ),
    );
  }
}