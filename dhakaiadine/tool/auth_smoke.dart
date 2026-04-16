import 'dart:io';
import 'dart:math';

import 'package:supabase/supabase.dart';

Future<void> main() async {
  const url = 'https://olrcszjhhnitlepiqvvb.supabase.co';
  const anonKey = 'sb_publishable_UcuB61Dn5jNns6Vxpuz_KQ_zlXjKimQ';

  final client = SupabaseClient(url, anonKey);
  final suffix = Random().nextInt(1000000000);
  final email = 'smoke_$suffix@example.com';
  const password = 'Pass@12345';
  const name = 'Smoke Test User';
  const phone = '01700000000';

  try {
    stdout.writeln('Step 1/4: Sign up...');
    final signUpRes = await client.auth.signUp(
      email: email,
      password: password,
    );
    final user = signUpRes.user;
    if (user == null) {
      throw Exception('Sign up returned no user.');
    }

    stdout.writeln('Step 2/4: Insert profile into users table...');
    await client.from('users').insert({
      'id': user.id,
      'name': name,
      'email': email,
      'phone': phone,
    });

    stdout.writeln('Step 3/4: Sign out then sign in...');
    await client.auth.signOut();
    await client.auth.signInWithPassword(email: email, password: password);

    stdout.writeln('Step 4/4: Fetch profile and validate...');
    final current = client.auth.currentUser;
    if (current == null) {
      throw Exception('No current user after login.');
    }

    final profile = await client
        .from('users')
        .select()
        .eq('id', current.id)
        .maybeSingle();
    if (profile == null) {
      throw Exception('Profile row not found.');
    }

    stdout.writeln('SUCCESS');
    stdout.writeln('email: ${profile['email']}');
    stdout.writeln('name: ${profile['name']}');
    stdout.writeln('phone: ${profile['phone']}');

    await client.auth.signOut();
    stdout.writeln('Logout successful.');
  } on AuthException catch (e) {
    stderr.writeln('AUTH ERROR: ${e.message}');
    exitCode = 1;
  } on PostgrestException catch (e) {
    stderr.writeln('DB ERROR: ${e.message}');
    exitCode = 1;
  } catch (e) {
    stderr.writeln('UNEXPECTED ERROR: $e');
    exitCode = 1;
  }
}
