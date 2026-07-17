class DeviceModel {
  final int id;
  final String clientName;
  final String deviceType;
  final String shelfNumber;
  final String paymentMethod;
  final double amount;

  const DeviceModel({
    required this.id,
    required this.clientName,
    required this.deviceType,
    required this.shelfNumber,
    required this.paymentMethod,
    required this.amount,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) => DeviceModel(
    id: json['id'],
    clientName: json['client_name'],
    deviceType: json['device_type'],
    shelfNumber: json['shelf_number'],
    paymentMethod: json['payment_method'],
    amount: (json['amount'] as num).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'client_name': clientName,
    'device_type': deviceType,
    'shelf_number': shelfNumber,
    'payment_method': paymentMethod,
    'amount': amount,
  };
}