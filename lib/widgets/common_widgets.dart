import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

// ─────────────────────────────────────────────
// DARK BACKGROUND SCAFFOLD
// ─────────────────────────────────────────────
class DarkScaffold extends StatelessWidget {
  const DarkScaffold({
    super.key,
    required this.child,
    this.gradient = AppGradients.darkBackground,
  });

  final Widget child;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: gradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: child,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// BACK BUTTON ROW
// ─────────────────────────────────────────────
class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: onTap ?? () => Navigator.maybePop(context),
        child: const Icon(Icons.arrow_back, color: Colors.white),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// STEP INDICATOR TEXT  e.g. "الخطوة 1/3"
// ─────────────────────────────────────────────
class StepIndicator extends StatelessWidget {
  const StepIndicator({super.key, required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Text(
      'الخطوة $current/$total',
      style: AppTextStyles.stepText,
    );
  }
}

// ─────────────────────────────────────────────
// PRIMARY BUTTON
// ─────────────────────────────────────────────

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final double height;
  final double width;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.height = 44, // الارتفاع المطلوب من تصميمك
    this.width = 264,  // العرض المطلوب من تصميمك
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        // التدرج اللوني الأزرق الاحترافي
        gradient: LinearGradient(
          colors: isLoading
              ? [Colors.grey, Colors.grey] // تغيير اللون عند التحميل
              : [const Color(0xFF138FD5), const Color(0xFF0884CC)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        // الحواف 9px كما في طلبك
        borderRadius: BorderRadius.circular(9),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9),
          ),
        ),
        // تعطيل الزر إذا كان في حالة تحميل
        onPressed: isLoading ? null : onPressed,
        child: Center(
          child: isLoading
              ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          )
              : Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}


// ─────────────────────────────────────────────
// GRADIENT BUTTON
// ─────────────────────────────────────────────
class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.gradient = AppGradients.primaryBlueVertical,
    this.height = 55,
    this.icon,
    required this.isLoading, // أضف "this." هنا
  });

  final String label;
  final VoidCallback onPressed;
  final Gradient gradient;
  final double height;
  final IconData? icon;
  final bool isLoading; // تعريف المتغير هنا

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed, // تعطيل الزر أثناء التحميل
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white) // إظهار التحميل
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white),
              const SizedBox(width: 10),
            ],
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}



// ─────────────────────────────────────────────
// LIGHT SEARCH BAR  (used in light screens)
// ─────────────────────────────────────────────

class CustomSearchBar extends StatefulWidget {
  final String hintText;
  final IconData leadingIcon;
  final IconData trailingIcon;
  final VoidCallback? onLeadingPressed;
  final Function(String)? onChanged;

  const CustomSearchBar({
    super.key,
    this.hintText = 'ابحث عن اسم زبون ...',
    this.leadingIcon = Icons.tune,
    this.trailingIcon = Icons.search,
    this.onLeadingPressed,
    this.onChanged,
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1B8ED8), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          IconButton(
            icon: Icon(widget.leadingIcon,
                color: const Color(0xFF1B8ED8), size: 24),
            onPressed: widget.onLeadingPressed,
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _controller,
              textAlign: TextAlign.right,
              onChanged: widget.onChanged,
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle:
                const TextStyle(color: Colors.grey, fontSize: 14),
                border: InputBorder.none,
                contentPadding:
                const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          Icon(widget.trailingIcon, color: Colors.grey),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// BOTTOM NAV BAR  (dark navy shared bar)
// ─────────────────────────────────────────────
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    this.currentIndex = 2,
    this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int>? onTap;

  static const _items = [
    BottomNavigationBarItem(icon: Icon(Icons.people), label: 'العملاء'),
    BottomNavigationBarItem(icon: Icon(Icons.devices), label: 'الأجهزة'),
    BottomNavigationBarItem(icon: Icon(Icons.home, size: 30), label: 'الرئيسية'),
    BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'التقارير'),
    BottomNavigationBarItem(icon: Icon(Icons.history), label: 'السجل'),
  ];

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      backgroundColor: AppColors.navyBlue,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white54,
      onTap: onTap,
      items: _items,
    );
  }
}

// ─────────────────────────────────────────────
// NOTCHED BOTTOM APP BAR  (with FAB slot)
// ─────────────────────────────────────────────
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
    return SizedBox(
      height: 85,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // الشريط الأساسي
          Container(
            height: 64,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            decoration: BoxDecoration(
              color: const Color(0xFF001742),
              borderRadius: BorderRadius.circular(17),
              border: Border.all(color: const Color(0x1AFFFFFF), width: 1),
            ),
            child: Row(
              children: [
                Expanded(child: _buildNavItem('تاريخ', 'assets/icons/history.png', 0)),
                Expanded(child: _buildNavItem('ديون', 'assets/icons/debt.png', 1)),

                const SizedBox(width: 60), // مكان الزر الأوسط

                Expanded(child: _buildNavItem('الأجهزة', 'assets/icons/devices.png', 3)),
                Expanded(child: _buildNavItem('العملاء', 'assets/icons/users.png', 4)),
              ],
            ),
          ),

          // الزر الأوسط
          Positioned(
            top: 0,
            child: GestureDetector(
              onTap: () => onItemSelected(2),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF0EA5E9),
                      border: Border.all(color: const Color(0x1AFFFFFF), width: 1),
                    ),
                    child: const Icon(
                      Icons.home_filled,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'الرئيسة',
                    style: TextStyle(color: Colors.white, fontSize: 10),
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
    final isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () => onItemSelected(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            iconPath,
            width: 25,
            height: 25,
            color: isSelected ? Colors.white : Colors.white60,
            errorBuilder: (c, e, s) => Icon(
              Icons.circle,
              color: isSelected ? Colors.white : Colors.white60,
              size: 25,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white60,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
// ─────────────────────────────────────────────
// HOME FAB
// ─────────────────────────────────────────────
class HomeFab extends StatelessWidget {
  const HomeFab({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed ?? () {},
      backgroundColor: AppColors.lightBlue,
      elevation: 4,
      child: const Icon(Icons.home, size: 30, color: Colors.white),
    );
  }
}

// ─────────────────────────────────────────────
// AUTH FOOTER LINK  "هل لديك حساب بالفعل؟ تسجيل"
// ─────────────────────────────────────────────
class AuthFooterLink extends StatelessWidget {
  const AuthFooterLink({
    super.key,
    required this.question,
    required this.actionText,
    this.onTap,
  });

  final String question;
  final String actionText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: RichText(
        text: TextSpan(
          text: '$question ',
          style: const TextStyle(color: Colors.white54),
          children: [
            TextSpan(
              text: actionText,
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// BORDERED IMAGE BOX  (forgot / otp screens)
// ─────────────────────────────────────────────
class BorderedImageBox extends StatelessWidget {
  const BorderedImageBox({
    super.key,
    required this.imagePath,
    this.size = 252,
  });

  final String imagePath;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(width: 2),
      ),
      child: Image.asset(imagePath, fit: BoxFit.contain),
    );
  }
}

// ─────────────────────────────────────────────
// INPUT BOX  (light themed, used in add device)
// ─────────────────────────────────────────────
class LightInputField extends StatelessWidget {
  const LightInputField({
    super.key,
    required this.label,
    required this.hint,
    this.controller, // 1. أضفنا هاد السطر
    this.keyboardType, // أضفنا هاد عشان لو بدك كيبورد أرقام
  });

  final String label;
  final String hint;
  final TextEditingController? controller; // 2. تعريف المتغير
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // يفضل يكون المحاذات لليمين/اليسار
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(height: 6),
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.grey[100], // استبدلتها بـ grey لو AppColors مش معرفة هون
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller, // 3. ربط الـ controller بالـ TextField
            keyboardType: keyboardType,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// LIGHT DROPDOWN FIELD
// ─────────────────────────────────────────────
class LightDropdownField extends StatelessWidget {
  const LightDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    this.onChanged,
  });

  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(height: 6),
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.lightGrey,
            borderRadius: AppBorderRadius.rounded15,
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
            items: items
                .map(
                  (v) => DropdownMenuItem(
                    value: v,
                    child: Center(child: Text(v)),
                  ),
                )
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
