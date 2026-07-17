abstract class CustomersState {}

class CustomersInitial extends CustomersState {}

class CustomersLoading extends CustomersState {}
class CustomerDeleteSuccess extends CustomersState {}

class CustomersSuccess extends CustomersState {
  final List<dynamic> customers;
  CustomersSuccess({required this.customers});
}

class CustomersError extends CustomersState {
  final String errorMsg;
  CustomersError({required this.errorMsg});
}

// حالات تفاصيل زبون واحد
class CustomerDetailSuccess extends CustomersState {
  final Map<String, dynamic> customer;
  CustomerDetailSuccess({required this.customer});
}

// حالة دفع الدين
class PayDebtSuccess extends CustomersState {}