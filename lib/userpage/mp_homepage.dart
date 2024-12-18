import 'package:flutter/material.dart';

class MaintenanceProviderHomePage extends StatelessWidget {
  const MaintenanceProviderHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Maintenance Provider Home')),
      body: const Center(
        child: Text('Welcome, Maintenance Provider!'),
      ),
    );
  }
}
