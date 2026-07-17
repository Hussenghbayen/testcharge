import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:testcharge/presentation/screens/debt/DebtsScreen.dart';
import 'package:testcharge/presentation/screens/debt/customer_details_screen.dart';
import 'package:testcharge/presentation/screens/history/HistoryReportScreen.dart';
import 'package:testcharge/presentation/screens/product/Product%20management%20screen.dart';
import 'logic/auth_cubit/auth_cubit.dart';
import 'logic/auth_cubit/auth_state.dart';
import 'logic/customers/customers_cubit.dart';
import 'logic/devices/devices_cubit.dart';
import 'logic/products/products_cubit.dart';
import 'logic/transactions/transactions_cubit.dart';
import 'presentation/screens/auth/forgot_password_screen.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/auth/otp_screen.dart';
import 'presentation/screens/auth/register_email_screen.dart';
import 'presentation/screens/auth/register_gender_screen.dart';
import 'presentation/screens/auth/register_name_screen.dart';
import 'presentation/screens/auth/reset_password_screen.dart';
import 'presentation/screens/payment/customer_accounts_screen.dart';
import 'presentation/screens/orders/delivery_method_screen.dart';
import 'presentation/screens/devices/active_devices_screen.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/transactions/transaction_history_screen.dart';

class AppRouter {
  final AuthCubit authCubit;

  AppRouter({required this.authCubit});

  Route? generateRoute(RouteSettings settings) {
    switch (settings.name) {

    // ✅ هنا التعديل الوحيد — بدل SplashScreen، نتحقق من الـ state مباشرة
      case '/':
        if (authCubit.state is AuthSuccess) {
          return MaterialPageRoute(
            builder: (_) => const HomeScreen(),
          );
        } else {
          return MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: authCubit,
              child: const SplashScreen(),
            ),
          );
        }

      case '/login':
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: authCubit,
            child: const LoginScreen(),
          ),
        );

      case '/otp':
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: authCubit,
            child: const OtpScreen(),
          ),
        );

      case '/register/name':
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: authCubit,
            child: const RegisterNameScreen(),
          ),
        );

      case '/register/gender':
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: authCubit,
            child: const RegisterGenderScreen(),
          ),
        );

      case '/register/email':
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: authCubit,
            child: const RegisterEmailScreen(),
          ),
        );

      case '/forgot-password':
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());

      case '/reset-password':
        return MaterialPageRoute(builder: (_) => const ResetPasswordScreen());

      case '/home':
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case '/active-devices':
        return MaterialPageRoute(
          builder: (context) => BlocProvider.value(
            value: context.read<DevicesCubit>(),
            child: const ActiveDevicesScreen(),
          ),
        );

      case '/customer-accounts':
        return MaterialPageRoute(builder: (_) => const CustomerAccountsScreen());

      case '/transaction-history':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (context) => BlocProvider.value(
            value: context.read<CustomersCubit>(),
            child: TransactionHistoryScreen(
              customerId: args['customerId'],
              customerName: args['customerName'],
            ),
          ),
        );

      case '/delivery-method':
        return MaterialPageRoute(builder: (_) => const DeliveryMethodScreen());

      case '/products':
        return MaterialPageRoute(
          builder: (ctx) => BlocProvider.value(
            value: ctx.read<ProductsCubit>(),
            child: const ProductManagementScreen(),
          ),
        );

      case '/debts':
        return MaterialPageRoute(builder: (_) => const DebtsScreen());

      case '/transaction-debt':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: authCubit,
            child: CustomerDetailsScreen(
              customerId: args['customerId'],
              customerName: args['customerName'],
            ),
          ),
        );

      default:
        return null;
    }
  }
}