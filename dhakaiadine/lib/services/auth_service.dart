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

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<void> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email.trim(),
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw const AuthFailure('Unable to create account. Please try again.');
      }

      await _client.from('users').insert({
        'id': user.id,
        'name': name.trim(),
        'email': email.trim(),
        'phone': phone.trim(),
      });
    } on AuthException catch (error, stackTrace) {
      debugPrint('signUp AuthException: ${error.message}\n$stackTrace');
      throw AuthFailure(_mapAuthException(error));
    } on PostgrestException catch (error, stackTrace) {
      debugPrint('signUp PostgrestException: ${error.message}\n$stackTrace');
      throw const AuthFailure('Unable to save your profile. Please try again.');
    } on SocketException catch (error, stackTrace) {
      debugPrint('signUp SocketException: $error\n$stackTrace');
      throw const AuthFailure('No internet connection. Please try again.');
    } on TimeoutException catch (error, stackTrace) {
      debugPrint('signUp TimeoutException: $error\n$stackTrace');
      throw const AuthFailure('Request timed out. Please try again.');
    } on AuthFailure {
      rethrow;
    } catch (error, stackTrace) {
      debugPrint('signUp UnknownException: $error\n$stackTrace');
      throw const AuthFailure('Something went wrong. Please try again.');
    }
  }

  Future<void> signIn({required String email, required String password}) async {
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
