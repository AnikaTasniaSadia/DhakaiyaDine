import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthFailure implements Exception {
  const AuthFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  final SupabaseClient _client = Supabase.instance.client;

  // ── Static test user credentials ──────────────────────────────────────
  static const String _staticEmail = 'test@gmail.com';
  static const String _staticPassword = 'test123';
  static const String _staticUserId = 'static-test-user-id';
  static const String _staticUserName = 'Test User';
  static const String _staticUserPhone = '01700000000';
  static const String _staticUserRole = 'customer';

  /// In-memory store for locally registered users.
  /// Key = lowercase email, Value = user profile map (with password).
  final Map<String, Map<String, dynamic>> _localUsers = {};

  /// Whether the current session is a static (offline) test user.
  bool _isStaticUser = false;
  bool get isStaticUser => _isStaticUser;

  /// The currently active local (registered) user profile, if any.
  Map<String, dynamic>? _activeLocalUser;
  bool get _isLocalUser => _activeLocalUser != null;

  /// Returns the current user ID – works for Supabase, static, and local users.
  String? get currentUserId {
    if (_isStaticUser) return _staticUserId;
    if (_activeLocalUser != null) return _activeLocalUser!['id'] as String?;
    return _client.auth.currentUser?.id;
  }

  /// Returns the current user email – works for Supabase, static, and local users.
  String? get currentUserEmail {
    if (_isStaticUser) return _staticEmail;
    if (_activeLocalUser != null) return _activeLocalUser!['email'] as String?;
    return _client.auth.currentUser?.email;
  }
  // ─────────────────────────────────────────────────────────────────────

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<void> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final key = email.trim().toLowerCase();

    // Prevent duplicate local registrations
    if (_localUsers.containsKey(key)) {
      throw const AuthFailure('Email already in use. Please login instead.');
    }

    // Store the user locally so they can log in with these credentials
    final userId = 'local-${DateTime.now().millisecondsSinceEpoch}';
    _localUsers[key] = {
      'id': userId,
      'name': name.trim(),
      'email': email.trim(),
      'phone': phone.trim(),
      'password': password,
      'role': 'customer',
    };

    debugPrint('✅ User registered locally: $key (id: $userId)');
  }

  Future<void> signIn({required String email, required String password}) async {
    final key = email.trim().toLowerCase();

    // ── Static test user bypass ─────────────────────────────────────────
    if (key == _staticEmail && password == _staticPassword) {
      _isStaticUser = true;
      _activeLocalUser = null;
      debugPrint('✅ Signed in as static test user ($_staticEmail)');
      return;
    }
    // ────────────────────────────────────────────────────────────────────

    // ── Locally registered user bypass ──────────────────────────────────
    final localUser = _localUsers[key];
    if (localUser != null) {
      if (localUser['password'] == password) {
        _isStaticUser = false;
        _activeLocalUser = localUser;
        debugPrint('✅ Signed in as locally registered user ($key)');
        return;
      } else {
        throw const AuthFailure('Invalid email or password.');
      }
    }
    // ────────────────────────────────────────────────────────────────────

    try {
      await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
    } on AuthException catch (error, stackTrace) {
      debugPrint('signIn AuthException: ${error.message}\n$stackTrace');
      throw AuthFailure(_mapAuthException(error));
    } on SocketException catch (error, stackTrace) {
      debugPrint('signIn SocketException: $error\n$stackTrace');
      throw const AuthFailure('No internet connection. Please try again.');
    } on TimeoutException catch (error, stackTrace) {
      debugPrint('signIn TimeoutException: $error\n$stackTrace');
      throw const AuthFailure('Request timed out. Please try again.');
    } catch (error, stackTrace) {
      debugPrint('signIn UnknownException: $error\n$stackTrace');
      throw const AuthFailure('Something went wrong. Please try again.');
    }
  }

  Future<void> signOut() async {
    // ── Static / local user sign-out ────────────────────────────────────
    if (_isStaticUser || _isLocalUser) {
      _isStaticUser = false;
      _activeLocalUser = null;
      debugPrint('✅ Local/static user signed out');
      return;
    }
    // ────────────────────────────────────────────────────────────────────

    try {
      await _client.auth.signOut();
    } on SocketException catch (error, stackTrace) {
      debugPrint('signOut SocketException: $error\n$stackTrace');
      throw const AuthFailure('No internet connection. Please try again.');
    } on TimeoutException catch (error, stackTrace) {
      debugPrint('signOut TimeoutException: $error\n$stackTrace');
      throw const AuthFailure('Request timed out. Please try again.');
    } catch (error, stackTrace) {
      debugPrint('signOut UnknownException: $error\n$stackTrace');
      throw const AuthFailure('Something went wrong. Please try again.');
    }
  }

  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    // ── Static test user profile ────────────────────────────────────────
    if (_isStaticUser && uid == _staticUserId) {
      return {
        'id': _staticUserId,
        'name': _staticUserName,
        'email': _staticEmail,
        'phone': _staticUserPhone,
        'role': _staticUserRole,
      };
    }
    // ────────────────────────────────────────────────────────────────────

    // ── Locally registered user profile ─────────────────────────────────
    if (_activeLocalUser != null && _activeLocalUser!['id'] == uid) {
      return Map<String, dynamic>.from(_activeLocalUser!)..remove('password');
    }
    // ────────────────────────────────────────────────────────────────────

    try {
      final data = await _client
          .from('users')
          .select()
          .eq('id', uid)
          .maybeSingle();
      return data;
    } on PostgrestException catch (error, stackTrace) {
      debugPrint(
        'getUserProfile PostgrestException: ${error.message}\n$stackTrace',
      );
      throw const AuthFailure('Unable to load profile. Please try again.');
    } on SocketException catch (error, stackTrace) {
      debugPrint('getUserProfile SocketException: $error\n$stackTrace');
      throw const AuthFailure('No internet connection. Please try again.');
    } on TimeoutException catch (error, stackTrace) {
      debugPrint('getUserProfile TimeoutException: $error\n$stackTrace');
      throw const AuthFailure('Request timed out. Please try again.');
    } catch (error, stackTrace) {
      debugPrint('getUserProfile UnknownException: $error\n$stackTrace');
      throw const AuthFailure('Something went wrong. Please try again.');
    }
  }

  String _mapAuthException(AuthException error) {
    final message = error.message.toLowerCase();

    if (message.contains('invalid login credentials')) {
      return 'Invalid email or password.';
    }
    if (message.contains('already registered') ||
        message.contains('already been registered')) {
      return 'Email already in use. Please login instead.';
    }
    if (message.contains('password should be at least')) {
      return 'Password is too weak. Use at least 6 characters.';
    }
    if (message.contains('email not confirmed')) {
      return 'Please verify your email before logging in.';
    }

    return 'Authentication failed. Please try again.';
  }
}
