abstract class ProductsState {}

class ProductsInitial extends ProductsState {}

class ProductsLoading extends ProductsState {}

class ProductsAddSuccess extends ProductsState {}

class ProductsSuccess extends ProductsState {
  final List<dynamic> products;
  ProductsSuccess({required this.products});
}

class ProductsError extends ProductsState {
  final String errorMsg;
  ProductsError({required this.errorMsg});
}