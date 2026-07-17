import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_state.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());
  String tempName = '';
  String tempEmail = '';
  String tempPassword = '';
  String tempGender = '';

  void saveName(String name) => tempName = name;
  void saveEmail(String email) => tempEmail = email;
  void savePassword(String password) => tempPassword = password;
  void saveGender(String gender) => tempGender = gender;

  // تسجيل الدخول بحساب Google (عبر Firebase SDK)
  Future<void> loginWithGoogle() async {
    emit(AuthLoading());
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        emit(AuthInitial()); // المستخدم ألغى
        return;
      }

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);
      final token = await userCredential.user?.getIdToken() ?? '';

      emit(AuthSuccess(token: token));
    } catch (e) {
      emit(AuthError(errorMsg: e.toString()));
    }
  }

  // إنشاء حساب جديد (عبر Firebase SDK)
  Future<void> signup(String name, String email, String password) async {
    emit(AuthLoading());
    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      await cred.user?.updateDisplayName(name.trim());
      final token = await cred.user?.getIdToken() ?? '';
      emit(AuthSuccess(token: token));
    } on FirebaseAuthException catch (e) {
      emit(AuthError(errorMsg: _parseError(e.code)));
    } catch (e) {
      emit(AuthError(errorMsg: 'تحقق من اتصالك بالإنترنت'));
    }
  }

  // تسجيل الدخول (عبر Firebase SDK)
  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      final token = await cred.user?.getIdToken() ?? '';
      emit(AuthSuccess(token: token));
    } on FirebaseAuthException catch (e) {
      emit(AuthError(errorMsg: _parseError(e.code)));
    } catch (e) {
      emit(AuthError(errorMsg: 'تحقق من اتصالك بالإنترنت'));
    }
  }

  // تسجيل الخروج
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
    emit(AuthInitial());
  }

  // فحص الجلسة عند فتح التطبيق (Firebase يحفظها تلقائياً)
  Future<void> checkLogin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final token = await user.getIdToken() ?? '';
      emit(AuthSuccess(token: token));
    } else {
      emit(AuthInitial());
    }
  }

  // تغيير كلمة المرور للمستخدم الحالي (عبر Firebase SDK)
  Future<void> resetPassword(String newPassword) async {
    emit(AuthLoading());
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        emit(AuthError(errorMsg: 'يجب تسجيل الدخول أولاً'));
        return;
      }
      await user.updatePassword(newPassword);
      final token = await user.getIdToken() ?? '';
      emit(AuthSuccess(token: token));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        emit(AuthError(
            errorMsg: 'لأمانك، سجّل الدخول من جديد ثم غيّر كلمة المرور'));
      } else {
        emit(AuthError(errorMsg: _parseError(e.code)));
      }
    } catch (e) {
      emit(AuthError(errorMsg: 'تحقق من اتصالك بالإنترنت'));
    }
  }

  // إرسال رابط إعادة تعيين كلمة المرور للإيميل (عبر Firebase SDK)
  Future<void> sendOtp(String email) async {
    emit(AuthLoading());
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
      tempEmail = email; // حفظ الإيميل للاستخدام لاحقاً
      emit(AuthSuccess(token: ''));
    } on FirebaseAuthException catch (e) {
      emit(AuthError(errorMsg: _parseError(e.code)));
    } catch (e) {
      emit(AuthError(errorMsg: 'تحقق من اتصالك بالإنترنت'));
    }
  }

  // الحصول على توكن طازج لإرساله للـ API (يتجدد تلقائياً)
  Future<String?> getFreshToken() async {
    return await FirebaseAuth.instance.currentUser?.getIdToken();
  }

  // تحويل رموز أخطاء Firebase SDK لعربي
  String _parseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'البريد الإلكتروني غير موجود';
      case 'wrong-password':
      case 'invalid-credential':
      case 'INVALID_LOGIN_CREDENTIALS':
        return 'البريد أو كلمة المرور غلط';
      case 'user-disabled':
        return 'الحساب موقوف';
      case 'email-already-in-use':
        return 'البريد الإلكتروني مستخدم مسبقاً';
      case 'weak-password':
        return 'كلمة المرور ضعيفة، 6 أحرف على الأقل';
      case 'invalid-email':
        return 'صيغة البريد الإلكتروني غير صحيحة';
      case 'too-many-requests':
        return 'محاولات كثيرة، انتظر قليلاً ثم حاول مجدداً';
      case 'network-request-failed':
        return 'تحقق من اتصالك بالإنترنت';
      default:
        return 'حدث خطأ، حاول مجدداً';
    }
  }
}