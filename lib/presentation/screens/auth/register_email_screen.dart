import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/auth_cubit/auth_cubit.dart';
import '../../../logic/auth_cubit/auth_state.dart';
import '../../../widgets/common_widgets.dart';
import '../../../widgets/login_field.dart';

class RegisterEmailScreen extends StatefulWidget {
  const RegisterEmailScreen({super.key});

  @override
  State<RegisterEmailScreen> createState() => _RegisterEmailScreenState();
}

class _RegisterEmailScreenState extends State<RegisterEmailScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DarkScaffold(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              const Align(alignment: Alignment.centerRight, child: AppBackButton()),
              const SizedBox(height: 10),
              const StepIndicator(current: 3, total: 3),
              const SizedBox(height: 15),
              Center(child: Image.asset('assets/icons/idcard.png')),
              const SizedBox(height: 20),
              const Text(
                'أدخل بريدك الإلكتروني',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              CustomLoginField(
                controller: emailController,
                label: 'البريد الإلكتروني',
                hint: 'example@gmail.com',
                suffixIcon: Icons.email_outlined,
              ),
              const SizedBox(height: 20),
              CustomLoginField(
                controller: passwordController,
                label: 'كلمة المرور',
                hint: '********',
                suffixIcon: Icons.lock_outline,
                isPassword: true,
              ),
              const SizedBox(height: 20),
              CustomLoginField(
                controller: confirmPasswordController,
                label: 'تأكيد كلمة المرور',
                hint: '********',
                suffixIcon: Icons.lock_outline,
                isPassword: true,
              ),
              const SizedBox(height: 40),

              BlocConsumer<AuthCubit, AuthState>(
                listener: (context, state) {
                  if (state is AuthSuccess) {
                    Navigator.pushReplacementNamed(context, '/home');
                  } else if (state is AuthError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.errorMsg), backgroundColor: Colors.red),
                    );
                  }
                },
                builder: (context, state) {
                  return PrimaryButton(
                    label: 'التسجيل ←',
                    isLoading: state is AuthLoading,
                    onPressed: () {
                      if (emailController.text.trim().isEmpty ||
                          passwordController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("يرجى تعبئة جميع الحقول")),
                        );
                        return;
                      }
                      if (passwordController.text != confirmPasswordController.text) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("كلمات المرور غير متطابقة")),
                        );
                        return;
                      }
                      // حفظ الإيميل وكلمة المرور ثم إرسال الطلب
                      final cubit = context.read<AuthCubit>();
                      cubit.saveEmail(emailController.text.trim());
                      cubit.savePassword(passwordController.text);
                      cubit.signup(cubit.tempName, cubit.tempEmail, cubit.tempPassword);
                    },
                  );
                },
              ),
              const SizedBox(height: 20),
              AuthFooterLink(
                question: 'هل لديك حساب بالفعل؟',
                actionText: 'تسجيل الدخول',
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}