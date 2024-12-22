import 'package:flutter/material.dart';
import 'package:projects/auth/auth_service.dart';
import 'package:projects/auth/login_screen.dart';

class UserHomePage extends StatelessWidget {
  const UserHomePage({super.key});

  void _logout(BuildContext context) async {
    await AuthService().signout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: const Center(
        child: Text('Welcome, Normal User!'),
      ),
    );
  }
}

//skfnsjfnsjnfjsnfjsnfjsf