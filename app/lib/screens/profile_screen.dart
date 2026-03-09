import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/auth_service.dart';
import '../utils/validators.dart';

class ProfileScreen extends StatefulWidget {
  final String userEmail;
  final String displayName;
  final String photoUrl;

  const ProfileScreen({
    super.key,
    required this.userEmail,
    required this.displayName,
    required this.photoUrl,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _profileFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  late final TextEditingController _displayNameController;
  late final TextEditingController _photoUrlController;
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isSavingProfile = false;
  bool _isChangingPassword = false;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController(text: widget.displayName);
    _photoUrlController = TextEditingController(text: widget.photoUrl);
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _photoUrlController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileFormCard(),
            const SizedBox(height: 12),
            _buildPasswordCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileFormCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _profileFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Edit Profile',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.deepPurple.shade50,
                  backgroundImage: _photoUrlController.text.trim().isNotEmpty
                      ? NetworkImage(_photoUrlController.text.trim())
                      : null,
                  child: _photoUrlController.text.trim().isEmpty
                      ? Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.deepPurple.shade300,
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: widget.userEmail,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _displayNameController,
                validator: Validators.validateDisplayName,
                decoration: const InputDecoration(
                  labelText: 'Display Name',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _photoUrlController,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'Photo URL (optional)',
                  prefixIcon: Icon(Icons.link_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSavingProfile ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                  ),
                  child: _isSavingProfile
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save Profile'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _passwordFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Change Password',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _currentPasswordController,
                obscureText: true,
                validator: Validators.validatePassword,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _newPasswordController,
                obscureText: true,
                validator: Validators.validatePassword,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  prefixIcon: Icon(Icons.password_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your new password';
                  }
                  if (value != _newPasswordController.text.trim()) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
                  prefixIcon: Icon(Icons.password),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isChangingPassword ? null : _changePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                  ),
                  child: _isChangingPassword
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Update Password'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_profileFormKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSavingProfile = true;
    });

    try {
      await context.read<AuthService>().updateCurrentUserProfile(
        displayName: _displayNameController.text.trim(),
        photoUrl: _photoUrlController.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully.')),
      );

      Navigator.pop(context, {
        'displayName': _displayNameController.text.trim(),
        'photoUrl': _photoUrlController.text.trim(),
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update profile: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isSavingProfile = false;
        });
      }
    }
  }

  Future<void> _changePassword() async {
    if (!_passwordFormKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isChangingPassword = true;
    });

    try {
      await context.read<AuthService>().changePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );

      if (!mounted) return;
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password changed successfully.')),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final message = e.code == 'wrong-password'
          ? 'Current password is incorrect.'
          : e.message ?? 'Failed to change password.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to change password: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isChangingPassword = false;
        });
      }
    }
  }
}
