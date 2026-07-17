import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // ليمتد على عرض الشاشة
      height: 90, // ارتفاع كافٍ لاستيعاب البروز العلوي للأيقونة
      color: Colors.transparent,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // 1. الشريط الأساسي (الخلفية الداكنة)
          Container(
            width: 370, // العرض المطلوب
            height: 64, // الارتفاع المطلوب
            margin: const EdgeInsets.only(bottom: 10), // ترك مسافة بسيطة من الأسفل
            decoration: BoxDecoration(
              // التدرج اللوني المحدد في طلبك
              gradient: const LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Color(0xFF001742), Color(0xFF001742)],
              ),
              borderRadius: BorderRadius.circular(17), // border-radius: 17px
              border: Border.all(
                color: const Color(0x1AFFFFFF), // #FFFFFF1A حدود شفافة 10%
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem('تاريخ', 'assets/icons/history.png', 0),
                _buildNavItem('الديون', 'assets/icons/debt.png', 1),
                const SizedBox(width: 50), // مساحة فارغة تحت أيقونة الرئيسة
                _buildNavItem('الأجهزة', 'assets/icons/devices.png', 3),
                _buildNavItem('العملاء', 'assets/icons/users.png', 4),
              ],
            ),
          ),

          // 2. الزر الأوسط البارز (الرئيسة)
          Positioned(
            top: 0, // ليعطي تأثير البروز العلوي
            child: GestureDetector(
              onTap: () => onItemSelected(2),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 55, // الدائرة الزرقاء الكبيرة
                    height: 55,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF0EA5E9),
                      border: Border.all(
                        color: const Color(0x1AFFFFFF),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: const Icon(
                      Icons.home_filled, // أيقونة البيت
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'الرئيسة',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
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

  Widget _buildNavItem(String label, String iconPath, int index) {
    bool isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () => onItemSelected(index),
      child: SizedBox(
        width: 60, // توحيد العرض لكل العناصر
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // استخدام ColorFiltered لضمان تغيير لون أي صورة PNG مهما كان نوعها
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                isSelected ? Colors.white : Colors.white.withOpacity(0.5),
                BlendMode.srcIn, // هذا النمط يغير لون الأيقونة بالكامل للون المحدد
              ),
              child: Image.asset(
                iconPath,
                width: 25,
                height: 25,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.money_off_csred_outlined,
                  color: isSelected ? Colors.white : Colors.white60,
                  size: 25,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
