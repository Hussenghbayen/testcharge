import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app_router.dart';
import 'logic/auth_cubit/auth_cubit.dart';
import 'logic/customers/customers_cubit.dart';
import 'logic/dashboard/dashboard_cubit.dart';
import 'logic/devices/devices_cubit.dart';
import 'logic/products/products_cubit.dart';
import 'logic/shelves/shelves_cubit.dart';
import 'logic/transactions/transactions_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
  } on FirebaseException catch (e) {
    if (e.code != 'duplicate-app') {
      rethrow; // لو خطأ تاني غير duplicate-app، ما نتجاهله
    }
    // لو duplicate-app، تجاهله وكمل عادي (Firebase أصلاً مهيأ)
  }

  final authCubit = AuthCubit();
  await authCubit.checkLogin();
  final appRouter = AppRouter(authCubit: authCubit);

  runApp(MultiBlocProvider(
    providers: [
      BlocProvider.value(value: authCubit),
      BlocProvider(create: (_) => ProductsCubit()),
      BlocProvider(create: (_) => CustomersCubit()),
      BlocProvider(create: (_) => TransactionsCubit()),
      BlocProvider(create: (_) => DashboardCubit()),
      BlocProvider(create: (_) => DevicesCubit()),
      BlocProvider(create: (_) => ShelvesCubit()),
    ],
    child: ChargingHubApp(
      appRouter: appRouter,
      authCubit: authCubit,
    ),
  ));
}
class ChargingHubApp extends StatelessWidget {
  final AppRouter appRouter;
  final AuthCubit authCubit;

  const ChargingHubApp({
    super.key,
    required this.appRouter,
    required this.authCubit,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Charging Hub',
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child!,
      ),
      theme: ThemeData(
        fontFamily: 'Tajawal',
        useMaterial3: true,
      ),
      onGenerateRoute: appRouter.generateRoute,
      initialRoute: '/', // AppRouter رح يقرر يروح لـ Home أو Login حسب الـ state
    );
  }
}