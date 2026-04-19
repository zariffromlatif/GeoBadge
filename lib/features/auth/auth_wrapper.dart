import 'package:flutter/material.dart';
import 'package:geobadge/services/storage_service.dart';
import 'package:geobadge/features/auth/login_screen.dart';
import 'package:geobadge/features/auth/enrollment_screen.dart';
import 'package:geobadge/features/scanner/scanner_screen.dart';
import 'package:geobadge/features/auth/splash_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, bool>>(
      future: _checkAuthState(),
      builder: (context, snapshot) {
        // Show our custom Splash Screen while waiting
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashUI();
        }

        final bool loggedIn = snapshot.data?['loggedIn'] ?? false;
        final bool enrolled = snapshot.data?['enrolled'] ?? false;

        if (!loggedIn) {
          return const LoginScreen();
        } else if (!enrolled) {
          return const EnrollmentScreen();
        } else {
          return const ScannerScreen();
        }
      },
    );
  }

  Future<Map<String, bool>> _checkAuthState() async {
    // Brand Timing: Add a 1.5-second delay so the user actually sees the logo
    // This gives the app a feeling of "booting up" a secure system.
    await Future.delayed(const Duration(milliseconds: 1500));

    final loggedIn = await StorageService.isLoggedIn();
    final enrolled = await StorageService.isEnrolled();
    return {'loggedIn': loggedIn, 'enrolled': enrolled};
  }
}
