import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/auth_cubit/auth_cubit.dart';
import '../../../widgets/common_widgets.dart';

class RegisterGenderScreen extends StatefulWidget {
  const RegisterGenderScreen({super.key});

  @override
  State<RegisterGenderScreen> createState() => _RegisterGenderScreenState();
}

class _RegisterGenderScreenState extends State<RegisterGenderScreen> {
  int _selectedIndex = -1;

  static const _options = [
    _GenderOption(index: 0, title: 'أنثى', image: 'assets/icons/female.png'),
    _GenderOption(index: 1, title: 'ذكر', image: 'assets/icons/male.png'),
  ];

  @override
  Widget build(BuildContext context) {
    return DarkScaffold(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            const Align(alignment: Alignment.centerRight, child: AppBackButton()),
            const SizedBox(height: 10),
            const StepIndicator(current: 2, total: 3),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: Image.asset('assets/icons/genderid.png', fit: BoxFit.contain),
            ),
            const SizedBox(height: 20),
            const Text(
              'ما هو جنسك؟',
              style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: _GenderCard(
                    option: _options[0],
                    isSelected: _selectedIndex == 0,
                    onTap: () => setState(() => _selectedIndex = 0),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _GenderCard(
                    option: _options[1],
                    isSelected: _selectedIndex == 1,
                    onTap: () => setState(() => _selectedIndex = 1),
                  ),
                ),
              ],
            ),
            const Spacer(),
            PrimaryButton(
              label: 'الخطوة التالية ←',
              onPressed: () {
                if (_selectedIndex != -1) {
                  String selectedGender = _selectedIndex == 1 ? "Male" : "Female";
                  context.read<AuthCubit>().saveGender(selectedGender);
                  Navigator.pushNamed(context, '/register/email');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("يرجى اختيار الجنس للمتابعة")),
                  );
                }
              },
            ),
            const SizedBox(height: 20),
            AuthFooterLink(
              question: 'هل لديك حساب بالفعل؟',
              actionText: 'تسجيل الدخول',
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ── كلاس البيانات المساعد ──
class _GenderOption {
  const _GenderOption({
    required this.index,
    required this.title,
    required this.image,
  });
  final int index;
  final String title;
  final String image;
}

// ── كلاس الكارد المساعد ──
class _GenderCard extends StatelessWidget {
  const _GenderCard({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });
  final _GenderOption option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.05) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.white12,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.white30,
                    width: 2,
                  ),
                ),
                child: isSelected ? Center(
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue,
                    ),
                  ),
                ) : null,
              ),
            ),
            const SizedBox(height: 10),
            Image.asset(option.image, height: 70),
            const SizedBox(height: 15),
            Text(
              option.title,
              style: TextStyle(
                color: isSelected ? Colors.blue : Colors.white70,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
