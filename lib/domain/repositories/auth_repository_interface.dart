import 'package:firebase_auth/firebase_auth.dart';

/// Interface for authentication repository operations.
/// Defines the contract for authentication-related data operations.
abstract class AuthRepositoryInterface {
  /// Signs in a user with email and password.
  /// Returns the [User] if successful, null otherwise.
  Future<User?> signInWithEmailAndPassword(String email, String password);

  /// Creates a new user account with email and password.
  /// Returns the [User] if successful, null otherwise.
  Future<User?> createUserWithEmailAndPassword(String email, String password);

  /// Signs out the current user.
  Future<void> signOut();

  /// Gets the currently signed-in user.
  /// Returns null if no user is signed in.
  User? getCurrentUser();

  /// Stream of authentication state changes.
  /// Emits the current user when auth state changes.
  Stream<User?> get authStateChanges;
}
