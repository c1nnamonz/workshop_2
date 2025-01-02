import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projects/auth/login_screen.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<Map<String, dynamic>> _getUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        // Attempt to fetch user data from Firestore
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          return {
            'name': doc.data()?['name'] ?? 'User Name',
            'email': user.email ?? 'No Email',
            'profileImage': doc.data()?['profileImage'] ?? 'assets/profile_placeholder.png',
          };
        } else {
          // Return fallback data if document does not exist
          return {
            'name': 'User Name',
            'email': user.email ?? 'No Email',
            'profileImage': 'assets/profile_placeholder.png',
          };
        }
      } catch (e) {
        // Handle Firestore or other errors
        return {
          'name': 'Error fetching name',
          'email': user.email ?? 'No Email',
          'profileImage': 'assets/profile_placeholder.png',
        };
      }
    }

    // Return an empty map if no user is signed in
    return {
      'name': 'Guest',
      'email': 'No Email',
      'profileImage': 'assets/profile_placeholder.png',
    };
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
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading profile information.'));
        }

        final userInfo = snapshot.data ?? {
          'name': 'User Name',
          'email': 'No Email',
          'profileImage': 'assets/profile_placeholder.png',
        };

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
