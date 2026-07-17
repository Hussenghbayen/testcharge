import 'package:flutter/material.dart';

import '../../widgets/common_widgets.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            radius: 0.8,
            center: Alignment(0.0, -0.2),
            colors: [Color(0xFF1C1D21), Color(0xFF131416)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  const SizedBox(height: 80),
                  Center(
                    child: Image.asset(
                      'assets/icons/splahchar.png',
                      width: 250,
                      height: 250,
                      fit: BoxFit.contain,
                      // إظهار أيقونة في حال لم يجد الصورة
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.battery_charging_full,
                        size: 150,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'اشحن جوالك\nبسهولة',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'منصة لتنظيم استخدام نقاط شحن الجوالات وتوزيع الأدوار بشكل عادل وسريع',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 80),
                  // الزر باستخدام الـ Routing اللي عملناه
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: PrimaryButton(
                      label: 'ابدأ الآن ←',
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                    ),

                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
