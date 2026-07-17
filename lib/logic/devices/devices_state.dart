abstract class DevicesState {}

class DevicesInitial extends DevicesState {}
class DevicesLoading extends DevicesState {}
class DevicesError extends DevicesState {
  final String errorMsg;
  DevicesError({required this.errorMsg});
}

class DevicesLoaded extends DevicesState {
  final List<dynamic> occupiedShelves;
  DevicesLoaded({required this.occupiedShelves});
}

class DeviceDelivered extends DevicesState {}
class DeviceAdded extends DevicesState {}
