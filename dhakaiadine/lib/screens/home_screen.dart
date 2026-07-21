import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../widgets/primary_button.dart';
import 'auth/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService.instance;

  late final Future<Map<String, dynamic>?> _profileFuture;
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfile();
  }

  Future<Map<String, dynamic>?> _loadProfile() async {
    final uid = _authService.currentUserId;
    if (uid == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _navigateToLogin();
      });
      return null;
    }

    return _authService.getUserProfile(uid);
  }

  Future<void> _logout() async {
    setState(() => _isLoggingOut = true);
    try {
      await _authService.signOut();
      if (!mounted) return;
      _navigateToLogin();
    } on AuthFailure catch (error) {
      _showError(error.message);
    } catch (_) {
      _showError('Something went wrong. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isLoggingOut = false);
      }
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
      );
  }

  @override
  Widget build(BuildContext context) {
    // user variable kept for backward compatibility in the build tree
    final userEmail = _authService.currentUserEmail;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            onPressed: _isLoggingOut ? null : _logout,
            icon: const Icon(Icons.logout_rounded, color: Color(0xFFFFC107)),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Unable to load profile right now.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            );
          }

          final profile = snapshot.data;
          final name = (profile?['name'] as String?)?.trim();
          final email =
              (profile?['email'] as String?)?.trim() ?? userEmail ?? '-';
          final phone = (profile?['phone'] as String?)?.trim();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, ${name?.isNotEmpty == true ? name : 'User'}! 👋',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 18),
                Material(
                  color: Colors.white,
                  elevation: 2,
                  borderRadius: BorderRadius.circular(24),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Profile',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),
                        _ProfileRow(label: 'Email', value: email),
                        const SizedBox(height: 10),
                        _ProfileRow(
                          label: 'Phone',
                          value: (phone != null && phone.isNotEmpty)
                              ? phone
                              : '-',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: 'Logout',
                  isLoading: _isLoggingOut,
                  onPressed: _isLoggingOut ? null : _logout,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72,
          child: Text(
            '$label:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.black54,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w400),
          ),
        ),
      ],
    );
  }
}
