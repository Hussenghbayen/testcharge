import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

import 'Shelves_State.dart';

// ===== States =====


// ===== Cubit =====
class ShelvesCubit extends Cubit<ShelvesState> {
  ShelvesCubit() : super(ShelvesInitial());

  static const String _baseUrl = 'https://charging-api-tkne.onrender.com/api';

  Future<String> _getToken() async {
    return await FirebaseAuth.instance.currentUser?.getIdToken() ?? '';
  }

  Future<void> addShelvesBulk(int count) async {
    emit(ShelvesLoading());
    try {
      final token = await _getToken();
      if (token.isEmpty) {
        emit(ShelvesError(errorMsg: 'غير مصرح'));
        return;
      }
      final response = await http.post(
        Uri.parse('$_baseUrl/shelves/bulk'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({"count": count}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(ShelvesSuccess());
      } else {
        final data = jsonDecode(response.body);
        emit(ShelvesError(errorMsg: data['message'] ?? 'فشل إضافة الرفوف'));
      }
    } catch (e) {
      emit(ShelvesError(errorMsg: e.toString()));
    }
  }
}