import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/auth_cubit/auth_cubit.dart';
import '../../../logic/auth_cubit/auth_state.dart';
import '../../../utils/app_theme.dart';
import '../../../widgets/common_widgets.dart';
import '../../../widgets/login_field.dart';
import '../home/home_screen.dart';
import 'register_email_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppGradients.darkBackground),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              children: [
               
                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset("assets/icons/logo.png", width: 35, height: 35),
                    const SizedBox(width: 10),
                    const Text(
                      'charging hub',
                      style: TextStyle(
                        color: Color(0xFF138FD5),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),
                const Text(
                  'مرحباً بك مجدداً!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('في charging hub', style: TextStyle(color: Colors.white70, fontSize: 16)),
                const SizedBox(height: 5),
                const Text('مرحباً، سجل الدخول للمتابعة!', style: TextStyle(color: Colors.white38, fontSize: 12)),

                const SizedBox(height: 40),

                // 3. حقول الإدخال
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 264),
                  child: Column(
                    children: [
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
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // 4. زر تسجيل الدخول مرتبط بالـ Cubit
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
                      label: 'تسجيل الدخول',
                      isLoading: state is AuthLoading,
                      onPressed: () {
                        context.read<AuthCubit>().login(
                          emailController.text,
                          passwordController.text,
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 30),
                const Text(
                  'أو استمر عن طريق وسائل التواصل الاجتماعي',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white38, fontSize: 11),
                ),
                const SizedBox(height: 20),

                // 5. زر جوجل
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
                    return GestureDetector(
                      onTap: state is AuthLoading
                          ? null
                          : () => context.read<AuthCubit>().loginWithGoogle(), // ✅
                      child: Container(
                        width: 264,
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white24),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: state is AuthLoading
                            ? const Center(child: CircularProgressIndicator(color: Colors.white))
                            : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/icons/google.png', height: 20),
                            const SizedBox(width: 8),
                            const Text(
                              'تسجيل الدخول باستخدام جوجل',
                              style: TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),

                // 6. فوتر الصفحة
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'لا تمتلك أي حساب؟ ',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/register/name');
                      },
                      child: const Text(
                        'سجل',
                        style: TextStyle(
                          color: Color(0xFF0EA5E9),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}