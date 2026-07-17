import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final String token;
  AuthSuccess({required this.token});

  @override
  List<Object?> get props => [token];
}

class AuthError extends AuthState {
  final String errorMsg;
  AuthError({required this.errorMsg});

  @override
  List<Object?> get props => [errorMsg];
}