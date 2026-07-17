import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/auth_cubit/auth_cubit.dart';
import '../../../widgets/common_widgets.dart';
import '../../../widgets/login_field.dart';

class RegisterNameScreen extends StatefulWidget {
  const RegisterNameScreen({super.key});

  @override
  State<RegisterNameScreen> createState() => _RegisterNameScreenState();
}

class _RegisterNameScreenState extends State<RegisterNameScreen> {
  final TextEditingController nameController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DarkScaffold(
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      const Align(alignment: Alignment.centerRight, child: AppBackButton()),
                      const SizedBox(height: 10),
                      const StepIndicator(current: 1, total: 3),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 220,
                        child: Image.asset('assets/icons/idcard.png', fit: BoxFit.contain),
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        'ما هو اسمك؟',
                        style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 30),
                      CustomLoginField(
                        controller: nameController,
                        label: 'اسمك الكامل',
                        hint: 'حسين غباين',
                        suffixIcon: Icons.person_outline,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'يجب أن يحتوي اسمك على\nاسم واحد على الأقل',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                      const Spacer(),
                      const SizedBox(height: 20),
                      PrimaryButton(
                        label: 'الخطوة التالية ←',
                        onPressed: () {
                          if (nameController.text.trim().isNotEmpty) {
                            context.read<AuthCubit>().saveName(nameController.text.trim());
                            Navigator.pushNamed(context, '/register/gender');
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("يرجى إدخال اسمك أولاً")),
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
              ),
            );
          },
        ),
      ),
    );
  }
}
