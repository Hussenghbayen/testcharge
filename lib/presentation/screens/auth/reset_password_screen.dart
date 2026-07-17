import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/auth_cubit/auth_cubit.dart';
import '../../../logic/auth_cubit/auth_state.dart';
import '../../../utils/app_theme.dart';
import '../../../widgets/common_widgets.dart';
import '../../../widgets/login_field.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DarkScaffold(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            const AppBackButton(),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: Image.asset('assets/icons/restpassword.png', fit: BoxFit.contain),
            ),
            const SizedBox(height: 25),
            const Text(
              'قم بتعيين كلمة المرور الجديدة الخاصة بك',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'حاول إنشاء كلمة مرور جديدة يمكنك تذكرها',
              style: AppTextStyles.screenSubtitle,
            ),
            const SizedBox(height: 30),
            CustomLoginField(
              controller: passwordController,
              label: 'كلمة المرور الجديدة',
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
            const SizedBox(height: 80),
            BlocConsumer<AuthCubit, AuthState>(
              listener: (context, state) {
                if (state is AuthSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("تم تغيير كلمة المرور بنجاح!"),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pushReplacementNamed(context, '/login');
                } else if (state is AuthError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.errorMsg), backgroundColor: Colors.red),
                  );
                }
              },
              builder: (context, state) {
                return PrimaryButton(
                  label: 'تغيير كلمة المرور',
                  isLoading: state is AuthLoading,
                  onPressed: () {
                    if (passwordController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("يرجى إدخال كلمة المرور")),
                      );
                      return;
                    }
                    if (passwordController.text != confirmPasswordController.text) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("كلمات المرور غير متطابقة")),
                      );
                      return;
                    }
                    context.read<AuthCubit>().resetPassword(passwordController.text);
                  },
                );
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}