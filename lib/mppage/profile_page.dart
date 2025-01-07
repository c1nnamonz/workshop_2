import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services_manager.dart'; // Import the ServicesManager file
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _userId; // Dynamically set user ID from FirebaseAuth

  // Profile details
  String _name = "John Doe";
  int _age = 30;
  String _location = "Kuala Lumpur, Malaysia";
  String _availability = "Monday - Friday, 9:00 AM - 6:00 PM";
  double _rating = 4.5;
  String? _profileImageUrl;

  // Controllers for editing fields
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _locationController;
  late TextEditingController _availabilityController;

  bool _isEditing = false;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _name);
    _ageController = TextEditingController(text: _age.toString());
    _locationController = TextEditingController(text: _location);
    _availabilityController = TextEditingController(text: _availability);

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
        _name = data["name"] ?? _name;
        _age = data["age"] ?? _age;
        _location = data["location"] ?? _location;
        _availability = data["availability"] ?? _availability;
        _rating = data["rating"]?.toDouble() ?? _rating;
        _profileImageUrl = data["profileImageUrl"];
      });

      _nameController.text = _name;
      _ageController.text = _age.toString();
      _locationController.text = _location;
      _availabilityController.text = _availability;
    }
  }

  Future<void> _saveProfile() async {
    if (_userId == null) return;

    final profileData = {
      "name": _nameController.text,
      "age": int.tryParse(_ageController.text) ?? _age,
      "location": _locationController.text,
      "availability": _availabilityController.text,
      "rating": _rating,
      "profileImageUrl": _profileImageUrl,
    };

    try {
      await _firestore.collection("profiles").doc(_userId).set(profileData);
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

  void _toggleEditing() {
    setState(() {
      if (_isEditing) {
        // Save profile when exiting edit mode
        _saveProfile();
      }
      _isEditing = !_isEditing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile Page"),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: _toggleEditing,
          )
        ],
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
                controller: _nameController,
                enabled: _isEditing,
                decoration: const InputDecoration(labelText: "Name"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _ageController,
                enabled: _isEditing,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Age"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _locationController,
                enabled: _isEditing,
                decoration: const InputDecoration(labelText: "Location"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _availabilityController,
                enabled: _isEditing,
                decoration: const InputDecoration(labelText: "Availability"),
              ),
              const SizedBox(height: 20),
              const Divider(),
              // BUTTON TO NAVIGATE TO SERVICES MANAGER
              ElevatedButton(
                onPressed: () {
                  // Navigate to ServicesManager when this button is pressed
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ServicesManager(), // Navigate to ServicesManager page
                    ),
                  );
                },
                child: const Text("Manage Services"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Set button color to blue
                  foregroundColor: Colors.white, // Set text color to white
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Adjust padding
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), // Text style
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
