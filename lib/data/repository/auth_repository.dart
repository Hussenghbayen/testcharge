import '../WebServices/auth_web_services.dart';

class AuthRepository {
  final AuthWebServices authWebServices;

  AuthRepository(this.authWebServices);

  // 1. عملية تسجيل الدخول
  Future<dynamic> login(String email, String password) async {
    final response = await authWebServices.login(email, password);
    return response;
  }

  // 2. عملية إنشاء حساب جديد (التي كانت تسبب الخطأ)
  Future<dynamic> register({
    required String name,
    required String gender,
    required String email,
    required String password,
  }) async {
    final response = await authWebServices.register(
      name,
      gender,
      email,
      password,
    );
    return response;
  }
// داخل كلاس AuthRepository
  Future<dynamic> verifyOtp(String otpCode) async {
    // بننادي الميثود اللي عملناها في الـ WebServices
    final response = await authWebServices.verifyOtp(otpCode);
    return response;
  }
  // داخل كلاس AuthRepository
  Future<dynamic> sendOtpToEmail(String email) async {
    // ننادي الـ WebServices لترسل الإيميل للسيرفر
    return await authWebServices.sendOtpToEmail(email);
  }

  Future<dynamic> resetPassword(String newPassword) async {
    return await authWebServices.resetPassword(newPassword);
  }


// 3. مستقبلاً يمكنك إضافة ميثود الـ OTP هنا
// Future<dynamic> verifyOtp(String code) async { ... }
}
