import 'package:flutter/material.dart';
import '../../../utils/app_theme.dart';
import '../../../widgets/common_widgets.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DarkScaffold(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 10),
              const Align(
                alignment: Alignment.centerRight,
                child: AppBackButton(),
              ),
              const SizedBox(height: 20),
              const BorderedImageBox(imagePath: 'assets/icons/towfactor.png'),
              const SizedBox(height: 30),
              const Text('أدخل رمز التحقق', style: AppTextStyles.screenTitle),
              const SizedBox(height: 10),
              const Text(
                'أدخل الرقم المكون من 4 أرقام الذي أرسلناه\nإلى البريد الإلكتروني',
                textAlign: TextAlign.center,
                style: AppTextStyles.screenSubtitle,
              ),
              const SizedBox(height: 30),
              const _OtpBoxes(),
              const SizedBox(height: 50),
              PrimaryButton(
                label: 'تحقق ←',
                onPressed: () {
                  Navigator.pushNamed(context, '/reset-password');
                },
              ),
              const SizedBox(height: 30),
              const Text(
                'لم تستلم شيئاً؟ أعد الإرسال (18)',
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _OtpBoxes extends StatelessWidget {
  const _OtpBoxes();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 264,
      height: 78,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFF1E5D7B),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          4,
              (index) => SizedBox(
            width: 35,
            child: TextField(
              autofocus: index == 0,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
              keyboardType: TextInputType.number,
              maxLength: 1,
              cursorColor: Colors.blue,
              decoration: const InputDecoration(
                counterText: '',
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white, width: 2),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white, width: 2.5),
                ),
              ),
              onChanged: (value) {
                if (value.length == 1 && index < 3) {
                  FocusScope.of(context).nextFocus();
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}