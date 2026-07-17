import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/auth_cubit/auth_cubit.dart';
import '../../../logic/auth_cubit/auth_state.dart';
import '../../../utils/app_theme.dart';
import '../../../widgets/common_widgets.dart';
import '../../../widgets/login_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DarkScaffold(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              const Align(alignment: Alignment.centerRight, child: AppBackButton()),
              const SizedBox(height: 30),
              const BorderedImageBox(imagePath: 'assets/icons/towfactor.png'),
              const SizedBox(height: 30),
              const Text(
                'هل نسيت كلمة السر؟',
                style: AppTextStyles.screenTitle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'لا تقلق، سنرسل رمز التحقق\nلبريدك الإلكتروني',
                textAlign: TextAlign.center,
                style: AppTextStyles.screenSubtitle,
              ),
              const SizedBox(height: 40),
              CustomLoginField(
                controller: emailController,
                label: 'البريد الإلكتروني',
                hint: 'example@gmail.com',
                suffixIcon: Icons.email_outlined,
              ),
              const SizedBox(height: 60),
              BlocConsumer<AuthCubit, AuthState>(
                listener: (context, state) {
                  if (state is AuthSuccess) {
                    Navigator.pushNamed(context, '/otp');
                  } else if (state is AuthError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.errorMsg), backgroundColor: Colors.red),
                    );
                  }
                },
                builder: (context, state) {
                  return PrimaryButton(
                    label: 'إرسال',
                    isLoading: state is AuthLoading,
                    onPressed: () {
                      if (emailController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("يرجى إدخال البريد الإلكتروني")),
                        );
                        return;
                      }
                      context.read<AuthCubit>().sendOtp(emailController.text.trim());
                    },
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}