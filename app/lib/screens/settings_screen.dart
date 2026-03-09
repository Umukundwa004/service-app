import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/settings/settings_bloc.dart';
import '../bloc/settings/settings_event.dart';
import '../bloc/settings/settings_state.dart';
import 'profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  final String? userEmail;
  final String? userName;
  final String? userPhotoUrl;

  const SettingsScreen({
    super.key,
    this.userEmail,
    this.userName,
    this.userPhotoUrl,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? _overrideDisplayName;
  String? _overridePhotoUrl;

  @override
  void initState() {
    super.initState();
    context.read<SettingsBloc>().add(const LoadSettings());
  }

  ({String displayName, String email, String photoUrl}) _profileFromAuthState(
    AuthState authState,
  ) {
    if (authState.status == AuthStatus.authenticated &&
        authState.user != null) {
      return (
        displayName: _overrideDisplayName ?? authState.user!.displayName,
        email: authState.user!.email,
        photoUrl: _overridePhotoUrl ?? authState.user!.photoUrl,
      );
    }

    return (
      displayName: _overrideDisplayName ?? widget.userName ?? 'User',
      email: widget.userEmail ?? 'Not signed in',
      photoUrl: _overridePhotoUrl ?? widget.userPhotoUrl ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocConsumer<SettingsBloc, SettingsState>(
        listener: (context, state) {
          if (state.status == SettingsStatus.error &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == SettingsStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileSection(),
                const SizedBox(height: 8),
                _buildNotificationsSection(state),
                const SizedBox(height: 8),
                _buildPreferencesSection(state),
                const SizedBox(height: 8),
                _buildAboutSection(),
                const SizedBox(height: 8),
                _buildAccountSection(),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileSection() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final profile = _profileFromAuthState(authState);
        final isAuthenticated = authState.status == AuthStatus.authenticated;

        return Container(
          color: Colors.deepPurple,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white,
                backgroundImage: profile.photoUrl.isNotEmpty
                    ? NetworkImage(profile.photoUrl)
                    : null,
                child: profile.photoUrl.isEmpty
                    ? Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.deepPurple.shade300,
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.displayName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile.email,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: isAuthenticated
                    ? () => _openProfileScreen(profile)
                    : null,
                icon: const Icon(Icons.edit, color: Colors.white),
                tooltip: isAuthenticated
                    ? 'Edit profile'
                    : 'Sign in to edit profile',
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openProfileScreen(
    ({String displayName, String email, String photoUrl}) profile,
  ) async {
    final updatedProfile = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileScreen(
          userEmail: profile.email,
          displayName: profile.displayName,
          photoUrl: profile.photoUrl,
        ),
      ),
    );

    if (!mounted || updatedProfile == null) {
      return;
    }

    setState(() {
      _overrideDisplayName =
          updatedProfile['displayName'] ?? _overrideDisplayName;
      _overridePhotoUrl = updatedProfile['photoUrl'] ?? _overridePhotoUrl;
    });

    context.read<AuthBloc>().add(const AuthCheckRequested());
  }

  Widget _buildNotificationsSection(SettingsState state) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              'Notifications',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ),
          _buildSwitchTile(
            icon: Icons.notifications_outlined,
            title: 'Push Notifications',
            subtitle: 'Receive push notifications',
            value: state.notificationsEnabled,
            onChanged: (value) {
              context.read<SettingsBloc>().add(ToggleNotifications(value));
            },
          ),
          const Divider(height: 1, indent: 72),
          _buildSwitchTile(
            icon: Icons.location_on_outlined,
            title: 'Location-Based Notifications',
            subtitle: 'Get notified about nearby services',
            value: state.locationNotificationsEnabled,
            onChanged: (value) {
              context.read<SettingsBloc>().add(
                ToggleLocationNotifications(value),
              );

              _showLocationNotificationSnackbar(value);
            },
          ),
        ],
      ),
    );
  }

  void _showLocationNotificationSnackbar(bool enabled) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.location_on, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                enabled
                    ? 'Location notifications enabled'
                    : 'Location notifications disabled',
              ),
            ),
          ],
        ),
        backgroundColor: enabled ? Colors.green : Colors.grey[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildPreferencesSection(SettingsState state) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              'Preferences',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ),
          _buildSwitchTile(
            icon: Icons.dark_mode_outlined,
            title: 'Dark Mode',
            subtitle: 'Enable dark theme',
            value: state.darkModeEnabled,
            onChanged: (value) {
              context.read<SettingsBloc>().add(ToggleDarkMode(value));
            },
          ),
          const Divider(height: 1, indent: 72),
          _buildListTile(
            icon: Icons.language_outlined,
            title: 'Language',
            subtitle: 'English',
            onTap: () {
              // Language selection
            },
          ),
          const Divider(height: 1, indent: 72),
          _buildListTile(
            icon: Icons.straighten_outlined,
            title: 'Distance Unit',
            subtitle: 'Kilometers',
            onTap: () {
              // Distance unit selection
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              'About',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ),
          _buildListTile(
            icon: Icons.info_outline,
            title: 'About App',
            subtitle: 'Version 1.0.0',
            onTap: () {
              _showAboutDialog();
            },
          ),
          const Divider(height: 1, indent: 72),
          _buildListTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: () {
              // Open privacy policy
            },
          ),
          const Divider(height: 1, indent: 72),
          _buildListTile(
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            onTap: () {
              // Open terms of service
            },
          ),
          const Divider(height: 1, indent: 72),
          _buildListTile(
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () {
              // Open help center
            },
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Service Directory',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.deepPurple,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.apps, color: Colors.white),
      ),
      children: [
        const Text(
          'A comprehensive service directory app that helps you discover and connect with local businesses and services.',
        ),
      ],
    );
  }

  Widget _buildAccountSection() {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              'Account',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ),
          _buildListTile(
            icon: Icons.logout,
            title: 'Sign Out',
            iconColor: Colors.red,
            titleColor: Colors.red,
            onTap: () {
              _showSignOutDialog();
            },
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              // Perform sign out using AuthBloc
              context.read<AuthBloc>().add(const AuthSignOutRequested());
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.deepPurple.shade50,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.deepPurple),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            )
          : null,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.deepPurple,
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? iconColor,
    Color? titleColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: (iconColor ?? Colors.deepPurple).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor ?? Colors.deepPurple),
      ),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w500, color: titleColor),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            )
          : null,
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}
