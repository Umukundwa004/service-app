import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  StreamSubscription<User?>? _authSubscription;

  AuthBloc({required AuthService authService})
    : _authService = authService,
      super(const AuthState.initial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthSendVerificationEmail>(_onSendVerificationEmail);
    on<AuthCheckEmailVerified>(_onCheckEmailVerified);

    // Listen to auth state changes
    _authSubscription = _authService.authStateChanges.listen((user) {
      add(const AuthCheckRequested());
    });
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final firebaseUser = _authService.currentUser;

    if (firebaseUser == null) {
      emit(const AuthState.unauthenticated());
      return;
    }

    try {
      // Get user profile from Firestore
      UserModel? userModel = await _authService.getUserProfile(
        firebaseUser.uid,
      );

      if (userModel == null) {
        userModel = UserModel(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          displayName: firebaseUser.displayName ?? 'User',
          createdAt: DateTime.now(),
        );
        await _authService.createUserProfile(userModel);
      }

      if (_authService.isEmailVerified) {
        emit(AuthState.authenticated(userModel));
      } else {
        emit(AuthState.emailNotVerified(userModel));
      }
    } catch (e) {
      emit(AuthState.error('Failed to load user profile: ${e.toString()}'));
    }
  }

  Future<void> _onSendVerificationEmail(
    AuthSendVerificationEmail event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authService.sendVerificationEmail();
    } catch (e) {
      emit(
        AuthState.error('Failed to send verification email: ${e.toString()}'),
      );
    }
  }

  Future<void> _onCheckEmailVerified(
    AuthCheckEmailVerified event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authService.reloadUser();
      add(const AuthCheckRequested());
    } catch (e) {
      emit(AuthState.error('Failed to check verification: ${e.toString()}'));
    }
  }

  Future<void> _onSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());

    try {
      final credential = await _authService.signInWithEmail(
        event.email,
        event.password,
      );
      final firebaseUser = credential.user;

      if (firebaseUser == null) {
        emit(const AuthState.unauthenticated());
        return;
      }

      // Get or create user profile
      UserModel? userModel = await _authService.getUserProfile(
        firebaseUser.uid,
      );
      if (userModel == null) {
        userModel = UserModel(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          displayName: firebaseUser.displayName ?? 'User',
          createdAt: DateTime.now(),
        );
        await _authService.createUserProfile(userModel);
      }

      if (_authService.isEmailVerified) {
        emit(AuthState.authenticated(userModel));
      } else {
        emit(AuthState.emailNotVerified(userModel));
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthState.error(_getAuthErrorMessage(e.code)));
    } on FirebaseException catch (e) {
      emit(AuthState.error(_getAuthErrorMessage(e.code)));
    } catch (e) {
      // Print error for debugging
      print('Sign in error: $e');
      emit(AuthState.error(e.toString()));
    }
  }

  Future<void> _onSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());

    try {
      final credential = await _authService.signUpWithEmail(
        event.email,
        event.password,
        event.displayName,
      );
      final firebaseUser = credential.user;

      if (firebaseUser == null) {
        emit(const AuthState.unauthenticated());
        return;
      }

      // Create user model and emit emailNotVerified state
      final userModel = UserModel(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: event.displayName,
        createdAt: DateTime.now(),
      );

      await _authService.sendVerificationEmail();
      emit(AuthState.emailNotVerified(userModel));
    } on FirebaseAuthException catch (e) {
      emit(AuthState.error(_getAuthErrorMessage(e.code)));
    } on FirebaseException catch (e) {
      emit(AuthState.error(_getAuthErrorMessage(e.code)));
    } catch (e) {
      // Print error for debugging
      print('Sign up error: $e');
      emit(AuthState.error(e.toString()));
    }
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());

    try {
      await _authService.signOut();
      emit(const AuthState.unauthenticated());
    } catch (e) {
      emit(AuthState.error('Sign out failed: ${e.toString()}'));
    }
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'INVALID_LOGIN_CREDENTIALS':
        return 'Invalid email or password.';
      case 'channel-error':
        return 'Please fill in all required fields.';
      default:
        print('Unhandled auth error code: $code');
        return 'Authentication error: $code';
    }
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
