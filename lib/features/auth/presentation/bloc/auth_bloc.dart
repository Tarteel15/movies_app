import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/forgot_password_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginSubmittedEvent extends AuthEvent {
  final String email;
  final String password;

  const LoginSubmittedEvent({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class RegisterSubmittedEvent extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String? avatarPath;

  const RegisterSubmittedEvent({
    required this.name,
    required this.email,
    required this.password,
    this.avatarPath,
  });

  @override
  List<Object?> get props => [name, email, password, avatarPath];
}

class ForgotPasswordSubmittedEvent extends AuthEvent {
  final String email;

  const ForgotPasswordSubmittedEvent({required this.email});

  @override
  List<Object?> get props => [email];
}

enum AuthStatus { initial, loading, authenticated, resetEmailSent, failure }

class AuthState extends Equatable {
  final AuthStatus status;
  final UserEntity? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserEntity? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage];
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final ForgotPasswordUseCase forgotPasswordUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.forgotPasswordUseCase,
  }) : super(const AuthState()) {
    on<LoginSubmittedEvent>(_onLoginSubmitted);
    on<RegisterSubmittedEvent>(_onRegisterSubmitted);
    on<ForgotPasswordSubmittedEvent>(_onForgotPasswordSubmitted);
  }

  Future<void> _onLoginSubmitted(
    LoginSubmittedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));
    final result = await loginUseCase(
      email: event.email,
      password: event.password,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(status: AuthStatus.failure, errorMessage: failure.message),
      ),
      (user) => emit(
        state.copyWith(status: AuthStatus.authenticated, user: user),
      ),
    );
  }

  Future<void> _onRegisterSubmitted(
    RegisterSubmittedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));
    final result = await registerUseCase(
      name: event.name,
      email: event.email,
      password: event.password,
      avatarPath: event.avatarPath,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(status: AuthStatus.failure, errorMessage: failure.message),
      ),
      (user) => emit(
        state.copyWith(status: AuthStatus.authenticated, user: user),
      ),
    );
  }

  Future<void> _onForgotPasswordSubmitted(
    ForgotPasswordSubmittedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));
    final result = await forgotPasswordUseCase(email: event.email);
    result.fold(
      (failure) => emit(
        state.copyWith(status: AuthStatus.failure, errorMessage: failure.message),
      ),
      (_) => emit(
        state.copyWith(status: AuthStatus.resetEmailSent),
      ),
    );
  }
}