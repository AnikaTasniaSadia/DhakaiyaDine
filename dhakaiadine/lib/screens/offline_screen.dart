import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../providers/connectivity_provider.dart';

class OfflineScreen extends StatefulWidget {
  const OfflineScreen({super.key});

  @override
  State<OfflineScreen> createState() => _OfflineScreenState();
}

class _OfflineScreenState extends State<OfflineScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final connectivityProvider = context.read<ConnectivityProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFFAF6EA), // Cream Background
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Center(
                    child: SizedBox(
                      height: 280,
                      width: 280,
                      child: Lottie.asset(
                        'assets/newanimation/Nointernet.json',
                        repeat: true,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: [
                      const Text(
                        'No Internet Connection',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1F2937), // Dark Navy
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'It looks like you\'re currently offline.\nPlease check your Wi-Fi or Mobile Data connection.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF4B5563),
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          await connectivityProvider.checkConnection();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF4B400), // Primary Gold
                          foregroundColor: const Color(0xFF1F2937), // Dark Navy
                          minimumSize: const Size(double.infinity, 54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          'Retry',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () {
                          connectivityProvider.setContinueOffline(true);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF1F2937),
                          minimumSize: const Size(double.infinity, 54),
                          side: const BorderSide(color: Color(0xFF1F2937), width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Continue Offline',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
