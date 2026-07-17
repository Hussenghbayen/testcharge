import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'devices_state.dart';

class DevicesCubit extends Cubit<DevicesState> {
  DevicesCubit() : super(DevicesInitial());

  static const String _baseUrl = 'https://charging-api-tkne.onrender.com/api';

  Future<String> _getToken() async {
    return await FirebaseAuth.instance.currentUser?.getIdToken() ?? '';
  }

  Future<void> getOccupiedShelves() async {
    emit(DevicesLoading());
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
        final occupied = data['shelves']['occupied'] as List? ?? [];
        emit(DevicesLoaded(occupiedShelves: occupied));
      } else {
        emit(DevicesError(errorMsg: 'فشل تحميل الأجهزة'));
      }
    } catch (e) {
      emit(DevicesError(errorMsg: e.toString()));
    }
  }

  Future<void> deliverDevice(String transactionId) async {
    try {
      final token = await _getToken();
      final response = await http.put(
        Uri.parse('$_baseUrl/transactions/$transactionId/deliver'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        emit(DeviceDelivered());
        await getOccupiedShelves();
      } else {
        emit(DevicesError(errorMsg: 'فشل تسليم الجهاز'));
      }
    } catch (e) {
      emit(DevicesError(errorMsg: e.toString()));
    }
  }

  Future<void> addChargingTransaction({
    required String customerName,
    required String productName,
    required String shelfNumber,
    required double amountPaid,
    required String paymentStatus,
  }) async {
    try {
      final token = await _getToken();
      print("TOKEN>>> $token");
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
          "type": "charging",
        }),
      );
      if (response.statusCode == 201) {
        emit(DeviceAdded());
        await getOccupiedShelves();
      } else {
        final data = jsonDecode(response.body);
        emit(DevicesError(errorMsg: data['message'] ?? 'فشل إضافة الجهاز'));
      }
    } catch (e) {
      emit(DevicesError(errorMsg: e.toString()));
    }
  }
}