import 'package:flutter/material.dart';

class SplashUI extends StatelessWidget {
  const SplashUI({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Using a deep, professional green to match the security/geo theme
      backgroundColor: Colors.green.shade800,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🛡️ The App Icon/Logo Placeholder
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.badge_outlined, // A professional badge icon
                size: 80,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),

            // 📝 Brand Name
            const Text(
              "GeoBadge",
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 10),

            // 🎯 The Mission Tagline
            const Text(
              "Zero-Click Attendance",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white70,
                letterSpacing: 1.5,
              ),
            ),

            const SizedBox(height: 60),

            // ⏳ A subtle loading indicator for the background tasks
            const SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
