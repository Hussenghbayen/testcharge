import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'products_state.dart';

class ProductsCubit extends Cubit<ProductsState> {
  ProductsCubit() : super(ProductsInitial());

  static const String _baseUrl = 'https://charging-api-tkne.onrender.com/api';

  Future<String> _getToken() async {
    return await FirebaseAuth.instance.currentUser?.getIdToken() ?? '';
  }

  Future<void> getProducts() async {
    emit(ProductsLoading());
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('$_baseUrl/products'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        emit(ProductsSuccess(products: data));
      } else {
        emit(ProductsError(errorMsg: 'فشل تحميل المنتجات'));
      }
    } catch (e) {
      emit(ProductsError(errorMsg: 'تحقق من اتصالك بالإنترنت'));
    }
  }

  Future<void> addProduct(String name, String type, double costPrice, double sellingPrice) async {
    emit(ProductsLoading());
    try {
      final token = await _getToken();
      final response = await http.post(
        Uri.parse('$_baseUrl/products'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "name": name,
          "type": type,
          "cost_price": costPrice,
          "selling_price": sellingPrice,
        }),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        emit(ProductsAddSuccess());
        await getProducts();
      } else {
        final data = jsonDecode(response.body);
        emit(ProductsError(errorMsg: data['message'] ?? 'فشل إضافة المنتج'));
      }
    } catch (e) {
      emit(ProductsError(errorMsg: e.toString()));
    }
  }

  Future<void> deleteProduct(String id) async {
    emit(ProductsLoading());
    try {
      final token = await _getToken();
      final response = await http.delete(
        Uri.parse('$_baseUrl/products/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        await getProducts();
      } else {
        emit(ProductsError(errorMsg: 'فشل حذف المنتج'));
      }
    } catch (e) {
      emit(ProductsError(errorMsg: 'تحقق من اتصالك بالإنترنت'));
    }
  }

  Future<void> updateProduct(String id, String name, String type, double costPrice, double sellingPrice) async {
    emit(ProductsLoading());
    try {
      final token = await _getToken();
      final response = await http.put(
        Uri.parse('$_baseUrl/products/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "name": name,
          "type": type,
          "cost_price": costPrice,
          "selling_price": sellingPrice,
        }),
      );
      if (response.statusCode == 200) {
        await getProducts();
      } else {
        emit(ProductsError(errorMsg: 'فشل تعديل المنتج'));
      }
    } catch (e) {
      emit(ProductsError(errorMsg: 'تحقق من اتصالك بالإنترنت'));
    }
  }
}