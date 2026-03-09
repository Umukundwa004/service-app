import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get user profile from Firestore
  Future<UserModel?> getUserProfile(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  // Create user profile in Firestore
  Future<void> createUserProfile(UserModel user) async {
    await _firestore.collection('users').doc(user.id).set(user.toMap());
  }

  // Update user profile
  Future<void> updateUserProfile(UserModel user) async {
    await _firestore.collection('users').doc(user.id).update(user.toMap());
  }

  // Update current user's basic profile details
  Future<void> updateCurrentUserProfile({
    required String displayName,
    required String photoUrl,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user found.');
    }

    await user.updateDisplayName(displayName.trim());
    await user.updatePhotoURL(photoUrl.trim().isEmpty ? null : photoUrl.trim());

    await _firestore.collection('users').doc(user.uid).set({
      'displayName': displayName.trim(),
      'photoUrl': photoUrl.trim(),
    }, SetOptions(merge: true));
  }

  // Change password after re-authenticating with current password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'No authenticated user found.',
      );
    }

    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );

    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Sign up with email and password
  Future<UserCredential> signUpWithEmail(
    String email,
    String password,
    String displayName,
  ) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Create user profile in Firestore
    if (credential.user != null) {
      final userModel = UserModel(
        id: credential.user!.uid,
        email: email,
        displayName: displayName,
        createdAt: DateTime.now(),
      );
      await createUserProfile(userModel);
    }

    return credential;
  }

  // Check if email is verified
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  // Send verification email
  Future<void> sendVerificationEmail() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  // Reload user to check verification status
  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Update notification preferences
  Future<void> updateNotificationPreference(String userId, bool enabled) async {
    await _firestore.collection('users').doc(userId).update({
      'notificationsEnabled': enabled,
    });
  }
}
