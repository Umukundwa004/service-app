import 'package:equatable/equatable.dart';
import '../../models/user_model.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  emailNotVerified,
  error,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;
  final bool isEmailVerified;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.isEmailVerified = false,
  });

  const AuthState.initial() : this(status: AuthStatus.initial);

  const AuthState.loading() : this(status: AuthStatus.loading);

  const AuthState.authenticated(UserModel user)
    : this(status: AuthStatus.authenticated, user: user, isEmailVerified: true);

  const AuthState.emailNotVerified(UserModel user)
    : this(
        status: AuthStatus.emailNotVerified,
        user: user,
        isEmailVerified: false,
      );

  const AuthState.unauthenticated() : this(status: AuthStatus.unauthenticated);

  const AuthState.error(String message)
    : this(status: AuthStatus.error, errorMessage: message);

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? errorMessage,
    bool? isEmailVerified,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage, isEmailVerified];
}
