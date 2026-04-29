import 'package:flutter/material.dart';
import 'package:geobadge/services/api_service.dart';
import 'package:geobadge/features/scanner/scanner_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool _isLoading = false;

  /// --- 🔐 THE ACTIVATION LOGIC ---
  void _handleLogin() async {
    final id = _idController.text.trim();
    final pass = _passController.text.trim();

    if (id.isEmpty || pass.isEmpty) {
      _showSnackBar("Required: Employee ID & Password", Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    // This calls the API which internally saves the ID to the Android Keystore
    final bool success = await ApiService.login(id, pass);

    setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        _showSnackBar("DEVICE ACTIVATED", Colors.blueAccent);

        // Push to Scanner and remove Login from the navigation stack forever
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ScannerScreen()),
        );
      }
    } else {
      _showSnackBar("Invalid Credentials. Check with Admin.", Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // OLED Optimized
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Industrial Iconography
              const Icon(
                Icons.qr_code_2_rounded,
                size: 60,
                color: Colors.blueAccent,
              ),
              const SizedBox(height: 20),

              // 2. Branding
              const Text(
                "GEOBADGE\nACTIVATION",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Secure identity binding for site presence.",
                style: TextStyle(
                  color: Colors.white..withValues(alpha: 0.5),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 50),

              // 3. Input Fields (Dark Theme)
              _buildTextField(
                controller: _idController,
                label: "EMPLOYEE ID",
                icon: Icons.badge_outlined,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _passController,
                label: "ACCESS PASSWORD",
                icon: Icons.lock_outline,
                isPassword: true,
              ),

              const SizedBox(height: 50),

              // 4. Action Button
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "ACTIVATE DEVICE",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.white..withValues(alpha: 0.4),
          fontSize: 12,
        ),
        prefixIcon: Icon(icon, color: Colors.blueAccent, size: 20),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white..withValues(alpha: 0.1)),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.blueAccent),
        ),
      ),
    );
  }
}
