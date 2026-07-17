import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'customers_state.dart';

class CustomersCubit extends Cubit<CustomersState> {
  CustomersCubit() : super(CustomersInitial());

  static const String _baseUrl = 'https://charging-api-tkne.onrender.com/api';

  Future<String> _getToken() async {
    return await FirebaseAuth.instance.currentUser?.getIdToken() ?? '';
  }

  Future<void> getCustomers() async {
    emit(CustomersLoading());
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('$_baseUrl/customers'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        emit(CustomersSuccess(customers: data));
      } else {
        emit(CustomersError(errorMsg: 'فشل تحميل الزبائن'));
      }
    } catch (e) {
      emit(CustomersError(errorMsg: e.toString()));
    }
  }

  Future<void> getCustomerDetails(String id) async {
    emit(CustomersLoading());
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('$_baseUrl/customers/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        emit(CustomerDetailSuccess(customer: data));
      } else {
        emit(CustomersError(errorMsg: 'فشل تحميل بيانات الزبون'));
      }
    } catch (e) {
      emit(CustomersError(errorMsg: e.toString()));
    }
  }
  Future<void> deleteCustomer(String id) async {
    try {
      final token = await _getToken();
      final response = await http.delete(
        Uri.parse('$_baseUrl/customers/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        emit(CustomerDeleteSuccess());
        await getCustomers();
      } else {
        emit(CustomersError(errorMsg: 'لا يمكن حذف زبون عليه ديون'));
      }
    } catch (e) {
      emit(CustomersError(errorMsg: e.toString()));
    }
  }

  Future<void> payDebt(String id, double amount, String note) async {
    emit(CustomersLoading());
    try {
      final token = await _getToken();
      final response = await http.put(
        Uri.parse('$_baseUrl/customers/$id/pay'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "amount": amount,
          "note": note,
        }),
      );
      if (response.statusCode == 200) {
        emit(PayDebtSuccess());
        await getCustomers(); // تحديث القائمة
      } else {
        emit(CustomersError(errorMsg: 'فشل تسجيل الدفعة'));
      }
    } catch (e) {
      emit(CustomersError(errorMsg: e.toString()));
    }

  }
}