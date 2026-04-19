import 'package:flutter/material.dart';
import 'package:geobadge/services/storage_service.dart';
import 'package:geobadge/features/auth/auth_wrapper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  void _handleLogin() async {
    // SIMULATED AUTH: In production, this hits your Web Hub backend
    if (_idController.text.isNotEmpty && _passController.text.isNotEmpty) {
      // Save the fake token to "bond" the phone to the user
      await StorageService.saveAuthToken("TOKEN_XYZ_123");

      if (mounted) {
        // The AuthWrapper will detect the token and move to Enrollment!
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Login Successful!")));

        //ADD THIS: Tell the app to refresh the routing logic
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AuthWrapper()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.security, size: 80, color: Colors.green),
            const SizedBox(height: 20),
            const Text(
              "GeoBadge Login",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text(
              "Enter credentials provided by HR",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _idController,
              decoration: const InputDecoration(labelText: "Employee ID"),
            ),
            TextField(
              controller: _passController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.all(15),
                ),
                child: const Text(
                  "LOGIN",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
