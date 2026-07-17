import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'transactions_state.dart';
import 'package:firebase_auth/firebase_auth.dart';


class TransactionsCubit extends Cubit<TransactionsState> {
  TransactionsCubit() : super(TransactionsInitial());

  static const String _baseUrl = 'https://charging-api-tkne.onrender.com/api';

  Future<String> _getToken() async {
    return await FirebaseAuth.instance.currentUser?.getIdToken() ?? '';
  }
  Future<void> addTransaction({
    required String customerName,
    required String productName,
    required String shelfNumber,
    required double amountPaid,
    required String paymentStatus,
    required String type,
  }) async {
    emit(TransactionsLoading());
    try {
      final token = await _getToken();

      if (token.isEmpty) {
        emit(TransactionsError(errorMsg: 'غير مصرح - يرجى تسجيل الدخول مجدداً'));
        return;
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/transactions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "customer_name": customerName,
          "product_name": productName,
          "shelf_number": shelfNumber,
          "quantity": 1,
          "amount_paid": amountPaid,
          "payment_status": paymentStatus,
          "type": type,
        }),
      );

      // ⬇️ هاد بيطلع الخطأ على الشاشة مباشرة
      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(TransactionsSuccess());
      } else {
        emit(TransactionsError(errorMsg: '${response.statusCode}: ${response.body}'));
      }
    } catch (e) {
      emit(TransactionsError(errorMsg: e.toString()));
    }
  }

  Future<void> getTransactions(String filter, {String? from, String? to}) async {
    emit(TransactionsLoading());
    try {
      final token = await _getToken();

      String endpoint;
      switch (filter) {
        case 'اسبوعي':
          endpoint = '$_baseUrl/transactions/week';
          break;
        case 'شهري':
          endpoint = '$_baseUrl/transactions/month';
          break;
        case 'مخصص':
          endpoint = '$_baseUrl/transactions/range?from=$from&to=$to';
          break;
        default:
          endpoint = '$_baseUrl/transactions/today';
      }

      final response = await http.get(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final List transactions = data is List ? data : [];
        double income = 0;
        double out = 0;
        for (var t in transactions) {
          final amount = double.tryParse(t['amount_paid']?.toString() ?? '0') ?? 0;
          if (amount >= 0) income += amount;
          else out += amount.abs();
        }
        emit(TransactionsLoaded(
          transactions: transactions,
          totalIncome: income,
          totalOut: out,
        ));
      } else {
        emit(TransactionsError(errorMsg: 'فشل تحميل العمليات'));
      }
    } catch (e) {
      emit(TransactionsError(errorMsg: e.toString()));
    }
  }
}