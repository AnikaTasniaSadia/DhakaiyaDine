import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/theme/app_theme.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://olrcszjhhnitlepiqvvb.supabase.co',
    anonKey: 'sb_publishable_UcuB61Dn5jNns6Vxpuz_KQ_zlXjKimQ',
  );

  runApp(const DhakaiyaDineApp());
}

class DhakaiyaDineApp extends StatelessWidget {
  const DhakaiyaDineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DhakaiyaDine',
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
