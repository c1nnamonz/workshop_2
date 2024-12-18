import 'package:flutter/material.dart';
import 'package:projects/auth/auth_service.dart';
import 'package:projects/auth/login_screen.dart';

class MaintenanceProviderHomePage extends StatelessWidget {
  const MaintenanceProviderHomePage({super.key});

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
        title: const Text('Maintenance Provider Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: const Center(
        child: Text('Welcome, Maintenance Provider!'),
      ),
    );
  }
}
