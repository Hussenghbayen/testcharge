import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // ======================================================
  // الـ Firebase API Key — موجود في الـ OpenAPI Spec
  // ======================================================
  static const String _firebaseApiKey = 'AIzaSyC1P5igV1WLjN6GopAu9cEY3oXcHm4QrwI';

  static const String _baseUrl =
      'https://identitytoolkit.googleapis.com';

  // ======================================================
  // Login — POST /v1/accounts:signInWithPassword
  // ======================================================
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/v1/accounts:signInWithPassword?key=$_firebaseApiKey',
    );

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'returnSecureToken': true,
      }),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    // Firebase بترجع error جوا الـ body حتى لو status مش 200
    if (response.statusCode != 200 || data.containsKey('error')) {
      final errorData = data['error'] as Map<String, dynamic>?;
      final message = errorData?['message'] ?? 'حدث خطأ غير معروف';
      throw _mapFirebaseError(message.toString());
    }

    return data;
    // data هيحتوي على:
    // idToken, refreshToken, localId, email, expiresIn ...
  }

  // ======================================================
  // ترجمة رسائل Firebase الإنجليزية لرسائل عربية واضحة
  // ======================================================
  String _mapFirebaseError(String code) {
    switch (code) {
      case 'EMAIL_NOT_FOUND':
        return 'البريد الإلكتروني غير مسجل';
      case 'INVALID_PASSWORD':
        return 'كلمة المرور غير صحيحة';
      case 'USER_DISABLED':
        return 'تم تعطيل هذا الحساب';
      case 'INVALID_LOGIN_CREDENTIALS':
        return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
      case 'TOO_MANY_ATTEMPTS_TRY_LATER':
        return 'محاولات كثيرة، يرجى المحاولة لاحقاً';
      default:
        return 'خطأ: $code';
    }
  }
}