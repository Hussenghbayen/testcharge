abstract class DashboardState {}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardSuccess extends DashboardState {
  final double todayIncome;
  final double totalIncome;
  final double totalDebts;
  final double customerBalances;
  final int occupiedShelves;
  final int freeShelves;

  DashboardSuccess({
    required this.todayIncome,
    required this.totalIncome,
    required this.totalDebts,
    required this.customerBalances,
    required this.occupiedShelves,
    required this.freeShelves,
  });
}

class DashboardError extends DashboardState {
  final String errorMsg;
  DashboardError({required this.errorMsg});
}