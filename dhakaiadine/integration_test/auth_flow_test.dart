import 'dart:math';

import 'package:dhakaiadine/services/auth_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await Supabase.initialize(
      url: 'https://olrcszjhhnitlepiqvvb.supabase.co',
      anonKey: 'sb_publishable_UcuB61Dn5jNns6Vxpuz_KQ_zlXjKimQ',
    );
  });

  testWidgets('register, login, profile fetch, logout', (tester) async {
    final auth = AuthService.instance;
    final randomSuffix = Random().nextInt(1000000000);
    final email = 'integration_$randomSuffix@example.com';
    const name = 'Integration Test User';
    const phone = '01700000001';
    const password = 'Pass@12345';

    await auth.signUp(
      name: name,
      email: email,
      phone: phone,
      password: password,
    );

    expect(Supabase.instance.client.auth.currentUser, isNotNull);

    await auth.signOut();
    expect(Supabase.instance.client.auth.currentUser, isNull);

    await auth.signIn(email: email, password: password);
    final user = Supabase.instance.client.auth.currentUser;
    expect(user, isNotNull);

    final profile = await auth.getUserProfile(user!.id);
    expect(profile, isNotNull);
    expect(profile!['email'], email);
    expect(profile['name'], name);

    await auth.signOut();
    expect(Supabase.instance.client.auth.currentUser, isNull);
  });
}
