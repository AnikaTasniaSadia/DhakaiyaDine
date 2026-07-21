import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/connectivity_provider.dart';

class NetworkBanner extends StatelessWidget {
  const NetworkBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityProvider>(
      builder: (context, provider, child) {
        if (provider.isConnected) {
          return const SizedBox.shrink();
        }
        return Container(
          width: double.infinity,
          color: const Color(0xFFD32F2F), // M3 red
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          alignment: Alignment.center,
          child: const SafeArea(
            bottom: false,
            top: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.wifi_off_rounded,
                  color: Colors.white,
                  size: 16,
                ),
                SizedBox(width: 8),
                Text(
                  'Offline Mode • Some features may be restricted',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
