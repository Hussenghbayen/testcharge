import '../Models/device_model.dart';
import '../WebServices/device_web_services.dart';

class DeviceRepository {
  final DeviceWebServices _webServices;

  DeviceRepository(this._webServices);

  Future<List<DeviceModel>> getDevices() async {
    final response = await _webServices.getDevices();
    return (response.data as List)
        .map((e) => DeviceModel.fromJson(e))
        .toList();
  }

  Future<void> addDevice(DeviceModel device) async {
    await _webServices.addDevice(device.toJson());
  }
}