import 'package:dio/dio.dart';

class DeviceWebServices {
  final Dio _dio;

  DeviceWebServices(this._dio);

  // ← غيّر الـ baseUrl لما يكون API جاهز
  static const String _base = 'https://your-api.com/api';

  Future<Response> addDevice(Map<String, dynamic> data) async {
    return await _dio.post('$_base/devices', data: data);
  }

  Future<Response> getDevices() async {
    return await _dio.get('$_base/devices');
  }
}