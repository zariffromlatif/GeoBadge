import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geobadge/features/scanner/scanner_screen.dart';
import 'package:geobadge/features/auth/login_screen.dart';
import 'package:geobadge/features/auth/splash_screen.dart';
import 'package:geobadge/services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const GeoBadgeApp());
}

class GeoBadgeApp extends StatefulWidget {
  const GeoBadgeApp({super.key});

  @override
  State<GeoBadgeApp> createState() => _GeoBadgeAppState();
}

class _GeoBadgeAppState extends State<GeoBadgeApp> {
  bool? _isSetup;

  @override
  void initState() {
    super.initState();
    ApiService.isUserSetup().then((v) {
      if (mounted) setState(() => _isSetup = v);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GeoBadge',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.blueAccent,
        fontFamily: 'Roboto',
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
      home: _isSetup == null
          ? const SplashUI()
          : _isSetup!
          ? const ScannerScreen()
          : const LoginScreen(),
    );
  }
}
