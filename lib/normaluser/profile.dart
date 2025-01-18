import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:projects/auth/login_screen.dart';
import '../normaluser/editProfile.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: const Center(
        child: Text('Settings Page'),
      ),
    );
  }
}

class VouchersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vouchers'),
      ),
      body: const Center(
        child: Text('Vouchers Page'),
      ),
    );
  }
}

class AddressesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Addresses'),
      ),
      body: const Center(
        child: Text('Addresses Page'),
      ),
    );
  }
}

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _userEmail = "johndoe@example.com";
  String _firstName = "";
  String _lastName = "";
  String? _profileImage;
  String _userBirthday = "1990-01-01";
  String _userPhone = "1234567890";
  String _userGender = "Male";
  String? _userId;  // Store the logged-in user's ID

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _getUserProfile();
  }

  Future<void> _getUserProfile() async {
    // Get the current user from Firebase Authentication
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userId = user.uid;  // Automatically set the user ID
      });
      // Now fetch data from Firestore using the user ID
      _fetchUserData(_userId!);
    } else {
      print('User is not logged in');
    }
  }

  Future<void> _fetchUserData(String userId) async {
    try {
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)  // Fetch data based on the logged-in user ID
          .get();

      if (userDoc.exists) {
        setState(() {
          _firstName = userDoc['firstName'] ?? "";
          _lastName = userDoc['lastName'] ?? "";
          _userEmail = userDoc['email'] ?? "";
          _userPhone = userDoc['phoneNumber'] ?? "";
          _userBirthday = userDoc['birthday'] ?? "1990-01-01";
          _userGender = userDoc['gender'] ?? "Male";
        });
      } else {
        print('User not found');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImage = image.path;
      });
    }
  }

  Future<void> _updateUserProfile() async {
    if (_userId != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(_userId).update({
          'firstName': _firstName,
          'lastName': _lastName,
          'phoneNumber': _userPhone,
          'birthday': _userBirthday,
          'gender': _userGender,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully!')),
        );
      } catch (e) {
        print('Error updating profile: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile.')),
        );
      }
    }
  }

  void _navigateToEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EditProfilePage(
              firstName: _firstName, // Passing first name instead of username
              lastName: _lastName, // Passing last name
              birthday: _userBirthday,
              phone: _userPhone,
              gender: _userGender,
              onSave: (String firstName, String lastName, String birthday, String phone,
                  String gender) {
                setState(() {
                  _firstName = firstName;
                  _lastName = lastName;
                  _userBirthday = birthday;
                  _userPhone = phone;
                  _userGender = gender;
                });
                // Call the update function to save the changes
                _updateUserProfile();
              },
            ),
      ),
    );
  }

  void _logout() {
    FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true, // Keeps the AppBar layout centered
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 70,
                        backgroundImage: _profileImage == null
                            ? const AssetImage(
                            'images/profile-img.png') as ImageProvider
                            : FileImage(File(_profileImage!)),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt, color: Colors.white),
                          onPressed: _pickImage,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '$_firstName $_lastName',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _userEmail,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _navigateToEditProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                    ),
                    child: const Text(
                        'Edit Profile', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
