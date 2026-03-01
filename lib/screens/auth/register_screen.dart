import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  int step = 1;
  bool isLoading = false;
  bool isAddingRole = false;

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String accountType = '';
  String fullName = '';
  String accountTypeValue = ''; // teacher / parent
  
    List students = []; // 👈 قائمة أبناء ولي الأمر
    
  /// ==============================
  /// 🔹 STEP 1 – تحقق من الرقم
  /// ==============================
  void checkPhone() async {

  if (phoneController.text.trim().isEmpty) return;

  setState(() => isLoading = true);

  try {

    final result = await AuthService.checkPhone(
      phoneController.text.trim(),
    );

    print(result);

    setState(() => isLoading = false);

    // 🔴 1️⃣ مسجل بجميع الأدوار
    if (result['already_registered'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("أنت مسجل مسبقاً بجميع الأدوار"),
        ),
      );
      return;
    }

    // 🟡 2️⃣ لديه حساب ويمكن إضافة دور
    if (result['existing_user'] == true &&
        result['can_add_roles'] != null &&
        (result['can_add_roles'] as List).isNotEmpty) {

      List newRoles = result['can_add_roles'];

      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(25),
          ),
        ),
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                const Text(
                  "يمكنك إضافة دور جديد",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                ...newRoles.map<Widget>((role) {
                  return SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        accountTypeValue = role;
                        accountType =
                            role == 'teacher' ? "معلم" : "ولي أمر";

                        students = result['students'] ?? [];
                          isAddingRole = true; 
                        Navigator.pop(context);

                        setState(() {
                          step = 2;
                        });
                      },
                      child: Text(
                        role == 'teacher'
                            ? "إضافة دور معلم"
                            : "إضافة دور ولي أمر",
                      ),
                    ),
                  );
                }).toList(),

              ],
            ),
          );
        },
      );

      return;
    }

    // 🟢 3️⃣ تسجيل جديد
    if (result['status'] == true && result['existing_user'] == false) {

      fullName = result['name'];
      students = result['students'] ?? [];

      List roles = result['roles'] ?? [];

      if (roles.length == 1) {

        accountTypeValue = roles.first;
        accountType =
            accountTypeValue == 'teacher' ? "معلم" : "ولي أمر";

        setState(() {
          step = 2;
        });

      } else if (roles.length > 1) {

        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(25),
            ),
          ),
          builder: (context) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  const Text(
                    "اختر نوع الحساب",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  ...roles.map<Widget>((role) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16), // 👈 التباعد هنا
    child: SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () {
          accountTypeValue = role;
          accountType =
              role == 'teacher' ? "معلم" : "ولي أمر";

          students = result['students'] ?? [];
          isAddingRole = true;

          Navigator.pop(context);

          setState(() {
            step = 2;
          });
        },
        child: Text(
          role == 'teacher'
              ? "إضافة دور معلم"
              : "إضافة دور ولي أمر",
        ),
      ),
    ),
  );
}).toList(),
                ],
              ),
            );
          },
        );
      }

      return;
    }

  } catch (e) {

    setState(() => isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("خطأ في الاتصال بالخادم")),
    );
  }
}

  /// ==============================
  /// 🔹 STEP 3 – إنشاء الحساب
  /// ==============================
  void registerAccount() async {

    if (emailController.text.isEmpty ||
        passwordController.text.isEmpty) return;

    setState(() => isLoading = true);

    try {

      final result = await AuthService.registerUser(
        name: fullName,
        phone: phoneController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        type: accountTypeValue,
      );

      setState(() => isLoading = false);

      if (result['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تم إنشاء الحساب بنجاح")),
        );

        Navigator.pop(context);
      }

    } catch (e) {
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("فشل إنشاء الحساب")),
      );
    }
  }

  void confirmAddRole() async {

  if (passwordController.text.isEmpty) return;

  setState(() => isLoading = true);

  try {

    final result = await AuthService.addRole(
      phone: phoneController.text.trim(),
      password: passwordController.text.trim(),
      role: accountTypeValue,
    );

    setState(() => isLoading = false);

    if (result['status'] == true) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("تم إضافة الدور بنجاح")),
      );

      Navigator.pop(context);

    } else {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? "حدث خطأ")),
      );
    }

  } catch (e) {

    setState(() => isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("فشل إضافة الدور")),
    );
  }
}

  @override
  Widget build(BuildContext context) {

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text("تسجيل جديد"),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              children: [

                /// ==========================
                /// 🔹 STEP 1 – رقم الهاتف
                /// ==========================
                if (step == 1) ...[
                  const SizedBox(height: 20),

                  TextField(
                    controller: phoneController,
                    decoration: InputDecoration(
                      labelText: 'رقم الهاتف',
                      prefixIcon: const Icon(Icons.phone),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : checkPhone,
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("تحقق"),
                    ),
                  ),
                ],

               /// ==========================
/// 🔹 STEP 2 – عرض البيانات
/// ==========================
if (step == 2) ...[
  const SizedBox(height: 30),

  Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 15,
          offset: const Offset(0, 5),
        )
      ],
    ),
    child: Column(
      children: [

        /// 🔹 أيقونة حسب النوع
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withOpacity(0.1),
          ),
          child: Icon(
            accountTypeValue == 'teacher'
                ? Icons.school
                : Icons.family_restroom,
            size: 35,
            color: AppColors.primary,
          ),
        ),

        const SizedBox(height: 20),

        /// 🔹 التعريف
        Text(
          accountTypeValue == 'teacher'
              ? "المعلم:"
              : "ولي الأمر:",
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey.shade600,
          ),
        ),

        const SizedBox(height: 10),

        // =============================
        // 🔹 عرض الاسم أو الأبناء
        // =============================

        if (accountTypeValue == 'parent') ...[

          // 👈 إذا عنده طالب واحد
          if (students.length == 1) ...[
            Text(
              students.first['name'],
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ]

          // 👈 إذا عنده أكثر من طالب
          else if (students.length > 1) ...[
            const Text(
              "أبناؤك في المدرسة:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 10),

            Column(
              children: students.map<Widget>((student) {
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.person, color: Colors.blue),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          student['name'],
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ]

        ]

        // 👈 إذا كان معلم
        else ...[
          Text(
            fullName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],

        const SizedBox(height: 15),

        /// 🔹 نوع الحساب
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            accountType,
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  ),

  const SizedBox(height: 30),

  SizedBox(
  width: double.infinity,
  height: 55,
  child: ElevatedButton(
    onPressed: () {
      if (isAddingRole) {
        setState(() => step = 4); // إضافة دور
      } else {
        setState(() => step = 3); // تسجيل جديد
      }
    },
    child: const Text("متابعة"),
  ),
),
],
                /// ==========================
/// 🔹 STEP 3 – إنشاء حساب جديد
/// ==========================
if (step == 3) ...[
  const SizedBox(height: 20),

  TextField(
    controller: emailController,
    decoration: InputDecoration(
      labelText: 'البريد الإلكتروني',
      prefixIcon: const Icon(Icons.email),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    ),
  ),

  const SizedBox(height: 16),

  TextField(
    controller: passwordController,
    obscureText: true,
    decoration: InputDecoration(
      labelText: 'كلمة المرور',
      prefixIcon: const Icon(Icons.lock),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    ),
  ),

  const SizedBox(height: 24),

  SizedBox(
    width: double.infinity,
    height: 55,
    child: ElevatedButton(
      onPressed: isLoading ? null : registerAccount,
      child: isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text("إنشاء الحساب"),
    ),
  ),
],



/// ==========================
/// 🔹 STEP 4 – تأكيد كلمة المرور لإضافة الدور
/// ==========================
if (step == 4) ...[
  const SizedBox(height: 20),

  TextField(
    controller: passwordController,
    obscureText: true,
    decoration: InputDecoration(
      labelText: 'أدخل كلمة المرور الحالية',
      prefixIcon: const Icon(Icons.lock),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    ),
  ),

  const SizedBox(height: 24),

  SizedBox(
    width: double.infinity,
    height: 55,
    child: ElevatedButton(
      onPressed: isLoading ? null : confirmAddRole,
      child: isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text("تأكيد وإضافة الدور"),
    ),
  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}