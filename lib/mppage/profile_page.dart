import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:projects/mppage/services_manager.dart';
import 'package:projects/mppage/mp_editProfile.dart'; // Import your new mp_editProfile.dart

class MaintenanceProviderProfilePage extends StatefulWidget {
  @override
  _MaintenanceProviderProfilePageState createState() =>
      _MaintenanceProviderProfilePageState();
}

class _MaintenanceProviderProfilePageState
    extends State<MaintenanceProviderProfilePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _userId; // Dynamically set user ID from FirebaseAuth

  // Profile details
  String _companyName = "ABC Maintenance";
  String _ownerName = "John Doe";
  String _operatingHours = "Mon - Fri: 9 AM - 6 PM";
  String _location = "Kuala Lumpur, Malaysia";
  double _rating = 4.5;
  String? _profileImageUrl;

  // Controllers for editing fields
  late TextEditingController _companyNameController;
  late TextEditingController _ownerNameController;
  late TextEditingController _operatingHoursController;
  late TextEditingController _locationController;

  bool _isEditing = false;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _companyNameController = TextEditingController(text: _companyName);
    _ownerNameController = TextEditingController(text: _ownerName);
    _operatingHoursController = TextEditingController(text: _operatingHours);
    _locationController = TextEditingController(text: _location);

    // Initialize and load user data
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      // Prompt user to log in
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in! Please log in.")),
      );
      return;
    }

    setState(() {
      _userId = currentUser.uid;
    });

    // Load profile data from Firestore
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (_userId == null) return;

    final snapshot = await _firestore.collection("profiles").doc(_userId).get();
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

      _companyNameController.text = _companyName;
      _ownerNameController.text = _ownerName;
      _operatingHoursController.text = _operatingHours;
      _locationController.text = _location;
    }
  }

  Future<void> _saveProfile() async {
    if (_userId == null) return;

    final profileData = {
      "companyName": _companyNameController.text,
      "ownerName": _ownerNameController.text,
      "operatingHours": _operatingHoursController.text,
      "location": _locationController.text,
      "rating": _rating,
      "profileImageUrl": _profileImageUrl,
    };

    try {
      await _firestore.collection("profiles").doc(_userId).set(profileData, SetOptions(merge: true));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save profile: $e")),
      );
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile =
    await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      // Upload logic here if needed
    }
  }

  void _navigateToEditProfile() {
    // Navigate to EditMaintenanceProfilePage for editing the profile
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EditMaintenanceProfilePage(
              companyName: _companyName,
              ownerName: _ownerName,
              operatingHours: _operatingHours,
              location: _location,
              profileImageUrl: "",  // Pass an empty string for profileImageUrl
              onSave: (companyName, ownerName, operatingHours, location, profileImageUrl) {
                setState(() {
                  _companyName = companyName;
                  _ownerName = ownerName;
                  _operatingHours = operatingHours;
                  _location = location;
                  _profileImageUrl = profileImageUrl; // Update the profile image URL if provided
                });
                _saveProfile();  // Save to Firestore after editing
              },
            )

        ,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove back button
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: _isEditing ? () {} : null,
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
              TextField(
                controller: _companyNameController,
                enabled: _isEditing,
                decoration: const InputDecoration(labelText: "Company Name"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _ownerNameController,
                enabled: _isEditing,
                decoration: const InputDecoration(labelText: "Owner Name"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _operatingHoursController,
                enabled: _isEditing,
                decoration: const InputDecoration(labelText: "Operating Hours"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _locationController,
                enabled: _isEditing,
                decoration: const InputDecoration(labelText: "Location"),
              ),
              const SizedBox(height: 20),
              const Divider(),
              // BUTTONS
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch, // Make buttons stretch across
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to ServicesManager
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ServicesManager(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 14, // Increase vertical padding for better spacing
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Text("Manage Services"),
                  ),
                  const SizedBox(height: 16), // Add space between buttons

                  ElevatedButton(
                    onPressed: _navigateToEditProfile, // Navigate to Edit Profile page
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.orangeAccent,
                      padding: const EdgeInsets.symmetric(
                        vertical: 14, // Increase vertical padding
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Edit Profile",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
