import 'package:flutter/material.dart';
import 'package:music_player/presentation/screens/home_screen.dart';
import 'package:music_player/services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _authenticate();
  }

  Future<void> _authenticate() async {
    final canAuth = await _authService.canAuthenticate();
    if (canAuth) {
      final didAuthenticate = await _authService.authenticate();
      if (didAuthenticate) {
        _navigateToHome();
      } else {
        // Handle failed authentication
      }
    } else {
      // No biometrics available, navigate directly
      _navigateToHome();
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fingerprint, color: Colors.white, size: 80),
            SizedBox(height: 20),
            Text(
              'Kimlik Doğrulama Gerekiyor',
              style: TextStyle(color: Colors.white, fontSize: 22),
            ),
          ],
        ),
      ),
    );
  }
}