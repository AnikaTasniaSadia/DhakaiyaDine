import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'routes/app_router.dart';
import 'services/cart_service.dart';
import 'services/order_service.dart';
import 'services/favorite_service.dart';
import 'services/search_service.dart';
import 'services/order_tracking_service.dart';
import 'providers/connectivity_provider.dart';
import 'screens/offline_screen.dart';

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
        ChangeNotifierProvider(create: (_) => CartService()),
        Provider(create: (_) => OrderService()),
        ChangeNotifierProvider(create: (_) => FavoriteService.instance),
        ChangeNotifierProvider(create: (_) => SearchService.instance),
        ChangeNotifierProvider(create: (_) => OrderTrackingService.instance),
      ],
      child: Builder(
        builder: (context) {
          final connectivity = Provider.of<ConnectivityProvider>(context, listen: false);
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'DhakaiyaDine',
            scaffoldMessengerKey: connectivity.scaffoldMessengerKey,
            theme: AppTheme.lightTheme,
            initialRoute: AppRouter.splash,
            onGenerateRoute: AppRouter.onGenerateRoute,
            builder: (context, child) {
              return Consumer<ConnectivityProvider>(
                builder: (context, provider, _) {
                  return Stack(
                    children: [
                      child ?? const SizedBox.shrink(),
                      if (!provider.isConnected && !provider.continueOffline)
                        const Positioned.fill(
                          child: OfflineScreen(),
                        ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

