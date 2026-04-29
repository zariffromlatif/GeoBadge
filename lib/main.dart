import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geobadge/features/scanner/scanner_screen.dart';
import 'package:geobadge/features/auth/login_screen.dart'; // We will build this next
import 'package:geobadge/services/api_service.dart';

void main() async {
  // Ensure Flutter engine is ready before checking secure storage
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI to match the industrial OLED look
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // 🔐 Check if the OnePlus 5 Keystore already has an identity
  final bool isSetup = await ApiService.isUserSetup();

  runApp(GeoBadgeApp(isSetup: isSetup));
}

class GeoBadgeApp extends StatelessWidget {
  final bool isSetup;
  const GeoBadgeApp({super.key, required this.isSetup});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GeoBadge',

      // 🎨 The "Industrial Beast Mode" Theme
      // Optimized for the OnePlus 5 OLED display to save battery and look sharp
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.blueAccent,
        fontFamily: 'Roboto', // Clean, industrial font
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),

      // 🚦 The Switchboard Logic
      // Direct-to-Scanner if registered, otherwise Onboarding.
      home: isSetup ? const ScannerScreen() : const LoginScreen(),
    );
  }
}
