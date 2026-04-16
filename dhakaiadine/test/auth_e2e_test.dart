import 'dart:math';

import 'package:dhakaiadine/services/auth_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await Supabase.initialize(
      url: 'https://olrcszjhhnitlepiqvvb.supabase.co',
      anonKey: 'sb_publishable_UcuB61Dn5jNns6Vxpuz_KQ_zlXjKimQ',
    );
  });

  test('register, login, profile fetch, logout', () async {
    final auth = AuthService.instance;
    final randomSuffix = Random().nextInt(1000000000);
    final email = 'autotest_$randomSuffix@example.com';
    const name = 'E2E Test User';
    const phone = '01700000000';
    const password = 'Pass@12345';

    await auth.signUp(
      name: name,
      email: email,
      phone: phone,
      password: password,
    );

    final currentUserAfterSignup = Supabase.instance.client.auth.currentUser;
    expect(currentUserAfterSignup, isNotNull);

    await auth.signOut();

    await auth.signIn(email: email, password: password);

    final currentUser = Supabase.instance.client.auth.currentUser;
    expect(currentUser, isNotNull);

    final profile = await auth.getUserProfile(currentUser!.id);
    expect(profile, isNotNull);
    expect(profile!['email'], email);
    expect(profile['name'], name);

    await auth.signOut();
    expect(Supabase.instance.client.auth.currentUser, isNull);
  });
}
