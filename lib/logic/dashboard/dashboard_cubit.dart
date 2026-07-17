import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit() : super(DashboardInitial());

  static const String _baseUrl = 'https://charging-api-tkne.onrender.com/api';

  Future<String> _getToken() async {
    return await FirebaseAuth.instance.currentUser?.getIdToken() ?? '';
  }

  Future<void> getDashboard() async {
    emit(DashboardLoading());
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('$_baseUrl/dashboard'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        emit(DashboardSuccess(
          todayIncome: double.tryParse(data['today']['income'].toString()) ?? 0,
          totalIncome: double.tryParse(data['total']['income'].toString()) ?? 0,
          totalDebts: double.tryParse(data['total']['debts'].toString()) ?? 0,
          customerBalances: double.tryParse(
              data['total']['customer_balances'].toString()) ??
              0,
          occupiedShelves:
          int.tryParse(data['shelves']['occupied_count'].toString()) ?? 0,
          freeShelves:
          int.tryParse(data['shelves']['free_count'].toString()) ?? 0,
        ));
      } else {
        emit(DashboardError(errorMsg: 'فشل تحميل البيانات'));
      }
    } catch (e) {
      emit(DashboardError(errorMsg: e.toString()));
    }
  }
}