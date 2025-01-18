import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:projects/mppage/services_manager.dart';
import 'package:projects/mppage/mp_editProfile.dart';

class MaintenanceProviderProfilePage extends StatefulWidget {
  @override
  _MaintenanceProviderProfilePageState createState() =>
      _MaintenanceProviderProfilePageState();
}

class _MaintenanceProviderProfilePageState
    extends State<MaintenanceProviderProfilePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String? _userId;
  String _companyName = "ABC Maintenance";
  String _ownerName = "John Doe";
  String _operatingHours = "Mon - Fri: 9 AM - 6 PM";
  String _location = "Kuala Lumpur, Malaysia";
  double _rating = 4.5;
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      setState(() {
        _userId = currentUser.uid;
      });
      _loadProfile();
    }
  }

  Future<void> _loadProfile() async {
    if (_userId == null) return;

    final snapshot = await _firestore.collection("users").doc(_userId).get();
    if (snapshot.exists) {
      final data = snapshot.data() as Map<String, dynamic>;
      setState(() {
        _companyName = data["companyName"] ?? _companyName;
        _ownerName = data["ownerName"] ?? _ownerName;
        _operatingHours = data["operatingHours"] ?? _operatingHours;
        _location = data["location"] ?? _location;
        _rating = data["rating"]?.toDouble() ?? _rating;
        _profileImageUrl = data["profileImageUrl"];
      });
    }
  }

  Future<String?> _uploadProfileImage(File image) async {
    if (_userId == null) return null;

    try {
      final ref = _storage.ref().child("profile_images/$_userId.jpg");
      await ref.putFile(image);
      return await ref.getDownloadURL();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to upload image: $e")),
      );
      return null;
    }
  }

  Future<void> _saveProfile(String companyName, String ownerName,
      String operatingHours, String location, String profileImageUrl) async {
    if (_userId == null) return;

    final profileData = {
      "companyName": companyName,
      "ownerName": ownerName,
      "operatingHours": operatingHours,
      "location": location,
      "rating": _rating,
      "profileImageUrl": profileImageUrl,
    };

    try {
      await _firestore
          .collection("users")
          .doc(_userId)
          .set(profileData, SetOptions(merge: true));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save profile: $e")),
      );
    }
  }

  void _navigateToManageServices() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ServicesManager()),
    );
  }

  void _navigateToEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditMaintenanceProfilePage(
          companyName: _companyName,
          ownerName: _ownerName,
          operatingHours: _operatingHours,
          location: _location,
          profileImageUrl: _profileImageUrl ?? "",
          onSave: (companyName, ownerName, operatingHours, location,
              profileImageUrl) async {
            String finalProfileImageUrl = profileImageUrl;

            // Check if a new image was uploaded
            if (profileImageUrl.isEmpty && _profileImageUrl != null) {
              final imageUrl =
              await _uploadProfileImage(File(_profileImageUrl!));
              if (imageUrl != null) {
                finalProfileImageUrl = imageUrl;
              }
            }

            setState(() {
              _companyName = companyName;
              _ownerName = ownerName;
              _operatingHours = operatingHours;
              _location = location;
              _profileImageUrl = finalProfileImageUrl;
            });

            await _saveProfile(companyName, ownerName, operatingHours,
                location, finalProfileImageUrl);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("images/mppage_bg4.png"), // Set background image
          fit: BoxFit.cover, // Ensure the image covers the entire container
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text("Profile Page")),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: _navigateToEditProfile,
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: _profileImageUrl != null
                      ? NetworkImage(_profileImageUrl!)
                      : null,
                  child: _profileImageUrl == null
                      ? const Icon(Icons.camera_alt, size: 40)
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  _companyName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.person, color: Colors.blueGrey),
                          SizedBox(width: 8),
                          Text(
                            "Owner Name",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        _ownerName,
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const Divider(),
                      Row(
                        children: const [
                          Icon(Icons.access_time, color: Colors.blueGrey),
                          SizedBox(width: 8),
                          Text(
                            "Operating Hours",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        _operatingHours,
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const Divider(),
                      Row(
                        children: const [
                          Icon(Icons.location_on, color: Colors.blueGrey),
                          SizedBox(width: 8),
                          Text(
                            "Location",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        _location,
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const Divider(),
                      Row(
                        children: const [
                          Icon(Icons.star, color: Colors.blueGrey),
                          SizedBox(width: 8),
                          Text(
                            "Rating",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        _rating.toString(),
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _navigateToManageServices,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Manage Services"),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _navigateToEditProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Edit Profile"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}