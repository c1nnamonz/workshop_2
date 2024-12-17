import 'dart:async';
import 'package:flutter/material.dart';
import 'package:projects/home_page.dart';
import 'package:projects/auth/login_screen.dart';
import 'package:projects/screen/onboard.dart';
import 'package:projects/screen/welcome_screen.dart';


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
    _timer = Timer(const Duration(seconds: 3), () {
      // Navigate to HomePage after 3 seconds
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Onboard()),
      );
    });
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
      // Optional, if you want a fallback background color
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              "images/bg_image.png",
              // Replace with your background image path
              fit: BoxFit.cover, // Ensures the image covers the entire screen
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
