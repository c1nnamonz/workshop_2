import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projects/auth/login_screen.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<Map<String, dynamic>> _getUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Fetch additional user details from Firestore if available
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      return {
        'name': doc['name'] ?? 'User Name',
        'email': user.email ?? 'No Email',
        'profileImage': doc['profileImage'] ?? 'assets/profile_placeholder.png',
      };
    }
    return {};
  }

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getUserInfo(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Text('Error loading profile information.'));
        }

        final userInfo = snapshot.data!;
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Profile',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: CircleAvatar(
                  radius: 30,
                  backgroundImage: userInfo['profileImage'].toString().startsWith('http')
                      ? NetworkImage(userInfo['profileImage'])
                      : AssetImage(userInfo['profileImage']) as ImageProvider,
                ),
                title: Text(
                  userInfo['name'],
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(userInfo['email']),
              ),
              const SizedBox(height: 20),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.settings, color: Colors.blue),
                title: const Text('Account Settings'),
                onTap: () {
                  // Navigate to Account Settings Page
                },
              ),
              ListTile(
                leading: const Icon(Icons.help_outline, color: Colors.green),
                title: const Text('Help & Support'),
                onTap: () {
                  // Navigate to Help & Support Page
                },
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip, color: Colors.orange),
                title: const Text('Privacy Policy'),
                onTap: () {
                  // Navigate to Privacy Policy Page
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Logout'),
                onTap: () {
                  _logout(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
