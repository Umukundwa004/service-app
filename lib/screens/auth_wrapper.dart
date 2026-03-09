import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';
import 'email_verification_screen.dart';
import 'login_screen.dart';
import 'main_shell.dart';

// Top-level gate that routes users based on authentication state.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        switch (state.status) {
          case AuthStatus.initial:
          case AuthStatus.loading:
            return const Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading...'),
                  ],
                ),
              ),
            );
          case AuthStatus.authenticated:
            // Authenticated users enter the main tabbed shell.
            return MainShell(
              userId: state.user!.id,
              userEmail: state.user!.email,
              userName: state.user!.displayName,
            );
          case AuthStatus.emailNotVerified:
            return EmailVerificationScreen(email: state.user!.email);
          case AuthStatus.unauthenticated:
          case AuthStatus.error:
            return const LoginScreen();
        }
      },
    );
  }
}


