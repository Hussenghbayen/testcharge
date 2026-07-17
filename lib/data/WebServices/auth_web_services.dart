import 'package:dio/dio.dart';

class AuthWebServices {
  late Dio dio;

  AuthWebServices() {
    BaseOptions options = BaseOptions(
      baseUrl: 'https://your-api-url.com', // استبدله برابط السيرفر الحقيقي
      receiveDataWhenStatusError: true,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
    );
    dio = Dio(options);
  }

  // 1. ميثود تسجيل الدخول
  Future<dynamic> login(String email, String password) async {
    try {
      Response response = await dio.post('login', data: {
        'email': email,
        'password': password,
      });
      return response.data;
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  // 2. ميثود إنشاء حساب جديد
  Future<dynamic> register(String name, String gender, String email, String password) async {
    try {
      Response response = await dio.post('register', data: {
        'name': name,
        'gender': gender,
        'email': email,
        'password': password,
      });
      return response.data;
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  // 3. ميثود التحقق من الـ OTP (تم تصحيحها هنا لاستخدام dio)
  Future<dynamic> verifyOtp(String otpCode) async {
    try {
      Response response = await dio.post('verify-otp', data: {
        'otp': otpCode,
      });
      return response.data;
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }
  // داخل كلاس AuthWebServices
  Future<dynamic> sendOtpToEmail(String email) async {
    try {
      Response response = await dio.post('forgot-password', data: {
        'email': email,
      });
      return response.data;
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }
  Future<dynamic> resetPassword(String newPassword) async {
    try {
      // نفترض أن السيرفر يحتاج كلمة المرور الجديدة
      // (غالباً يتم إرسال التوكن أو الإيميل معها، لكن للتبسيط حالياً:)
      Response response = await dio.post('reset-password', data: {
        'password': newPassword,
      });
      return response.data;
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

}
