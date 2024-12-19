import 'dart:async';
import 'package:flutter/material.dart';
import 'package:projects/auth/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projects/screen/onboard.dart';
import '../userpage/mp_homepage.dart';
import '../userpage/user_homepage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _redirectUser();
  }

  // Check if the user is logged in and navigate based on their role
  void _redirectUser() async {
    await Future.delayed(const Duration(seconds: 2)); // Optional delay for splash effect

    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // If the user is logged in, fetch their role
      String role = await AuthService().getUserRole(user.uid);

      if (role == 'Maintenance Provider') {
        // Redirect to MaintenanceProviderHomePage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MaintenanceProviderHomePage()),
        );
      } else {
        // Redirect to UserHomePage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const UserHomePage()),
        );
      }
    } else {
      // If no user is logged in, navigate to the Onboard screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Onboard()),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              "images/bg_image.png",
              fit: BoxFit.cover,
            ),
          ),
          // Logo Image
          Center(
            child: Image.asset("images/logoapp.png"),
          ),
        ],
      ),
    );
  }
}
