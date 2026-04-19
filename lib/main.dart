import 'package:flutter/material.dart';
import 'package:geobadge/features/auth/auth_wrapper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GeoBadgeApp());
}

class GeoBadgeApp extends StatelessWidget {
  const GeoBadgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GeoBadge',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const AuthWrapper(), //The logic starts here
    );
  }
}
