abstract class TransactionsState {}

class TransactionsInitial extends TransactionsState {}

class TransactionsLoading extends TransactionsState {}

class TransactionsSuccess extends TransactionsState {}

class TransactionsError extends TransactionsState {
  final String errorMsg;
  TransactionsError({required this.errorMsg});
}

class TransactionsLoaded extends TransactionsState {
  final List<dynamic> transactions;
  final double totalIncome;
  final double totalOut;
  TransactionsLoaded({
    required this.transactions,
    required this.totalIncome,
    required this.totalOut,
  });
}