
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final String _userId = "12345"; // Replace with dynamic user ID logic

  String _name = "";
  int _age = 0;
  String _location = "";
  String _availability = "";
  double _rating = 0.0;
  String? _profileImageUrl;
  List<Map<String, String>> _services = [];

  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _locationController;
  late TextEditingController _availabilityController;

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _ageController = TextEditingController();
    _locationController = TextEditingController();
    _availabilityController = TextEditingController();
    _loadProfile();
  }



  void _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in!")),
      );
      return;
    }

    final DocumentSnapshot snapshot =
    await _firestore.collection("profiles").doc(user.uid).get();

    if (snapshot.exists) {
      final data = snapshot.data() as Map<String, dynamic>;
      setState(() {
        _name = data["name"] ?? _name;
        _age = data["age"] ?? _age;
        _location = data["location"] ?? _location;
        _availability = data["availability"] ?? _availability;
        _rating = data["rating"]?.toDouble() ?? _rating;
        _profileImageUrl = data["profileImageUrl"];
        _services = List<Map<String, String>>.from(data["services"] ?? _services);
      });

      // Update controllers
      _nameController.text = _name;
      _ageController.text = _age.toString();
      _locationController.text = _location;
      _availabilityController.text = _availability;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No profile data found.")),
      );
    }
  }


  Future<void> _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in!")),
      );
      return;
    }

    final profileData = {
      "name": _nameController.text,
      "age": int.tryParse(_ageController.text) ?? _age,
      "location": _locationController.text,
      "availability": _availabilityController.text,
      "rating": _rating,
      "profileImageUrl": _profileImageUrl,
      "services": _services,
    };

    try {
      await _firestore.collection("profiles").doc(user.uid).set(profileData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save profile: $e")),
      );
    }
  }


  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final fileName = "$_userId-profile-picture.jpg";
      try {
        final ref = FirebaseStorage.instance.ref().child("profile_images/$fileName");
        await ref.putFile(file);
        final imageUrl = await ref.getDownloadURL();
        setState(() {
          _profileImageUrl = imageUrl;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile picture updated successfully!")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to upload image: $e")),
        );
      }
    }
  }


  void _toggleEditing() {
    setState(() {
      if (_isEditing) {
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
                onTap: _isEditing ? _pickAndUploadImage : null,
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
              TextField(controller: _nameController, enabled: _isEditing, decoration: const InputDecoration(labelText: "Name")),
              const SizedBox(height: 10),
              TextField(controller: _ageController, enabled: _isEditing, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Age")),
              const SizedBox(height: 10),
              TextField(controller: _locationController, enabled: _isEditing, decoration: const InputDecoration(labelText: "Location")),
              const SizedBox(height: 10),
              TextField(controller: _availabilityController, enabled: _isEditing, decoration: const InputDecoration(labelText: "Availability")),
              const SizedBox(height: 20),
              const Divider(),
              const Text("Services Offered", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ..._services.map((service) => ListTile(
                title: Text(service['service'] ?? ""),
                subtitle: Text(service['description'] ?? ""),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
