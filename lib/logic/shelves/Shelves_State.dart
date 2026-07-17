abstract class ShelvesState {}

class ShelvesInitial extends ShelvesState {}

class ShelvesLoading extends ShelvesState {}

class ShelvesSuccess extends ShelvesState {}

class ShelvesLoaded extends ShelvesState {
  final List<dynamic> shelves;
  ShelvesLoaded({required this.shelves});
}
class ShelvesError extends ShelvesState {
  final String errorMsg;
  ShelvesError({required this.errorMsg});

}