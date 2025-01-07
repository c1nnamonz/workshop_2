import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String? _userId;
  String? _profileImageUrl;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  double _rating = 0.0;
  List<Map<String, String>> _services = [];

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    final User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      setState(() {
        _userId = currentUser.uid;
      });
      _loadProfile();
    }
  }

  Future<void> _loadProfile() async {
    if (_userId == null) return;

    try {
      final DocumentSnapshot snapshot =
      await _firestore.collection("profiles").doc(_userId).get();
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        setState(() {
          _nameController.text = data["name"] ?? "";
          _ageController.text = data["age"]?.toString() ?? "";
          _locationController.text = data["location"] ?? "";
          _rating = (data["rating"] ?? 0.0).toDouble();
          _profileImageUrl = data["profileImageUrl"];
          _services = List<Map<String, String>>.from(
              (data["services"] as List?)?.map((item) => Map<String, String>.from(item)) ?? []);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading profile: $e")),
      );
    }
  }

  Future<void> _uploadProfilePicture() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      try {
        final ref = _storage.ref().child('profile_images/$_userId.jpg');
        await ref.putFile(File(image.path));
        final url = await ref.getDownloadURL();
        setState(() {
          _profileImageUrl = url;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error uploading profile picture: $e")),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_userId == null) return;

    final profileData = {
      "name": _nameController.text,
      "age": int.tryParse(_ageController.text) ?? 0,
      "location": _locationController.text,
      "rating": _rating,
      "profileImageUrl": _profileImageUrl,
      "services": _services,
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

  void _toggleEditing() {
    setState(() {
      if (_isEditing) _saveProfile();
      _isEditing = !_isEditing;
    });
  }

  void _addService() {
    setState(() {
      _services.add({"service": "", "description": "", "price": "", "availability": ""});
    });
  }

  void _removeService(int index) {
    setState(() {
      _services.removeAt(index);
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
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: _isEditing ? _uploadProfilePicture : null,
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
              const SizedBox(height: 20),
              const Divider(),
              const Text("Services Offered",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ..._services.asMap().entries.map((entry) {
                final index = entry.key;
                final service = entry.value;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Service: ${service["service"] ?? ""}",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        text: "Description: ",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black),
                        children: [
                          TextSpan(
                            text: service["description"] ?? "",
                            style: const TextStyle(fontWeight: FontWeight.normal),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        text: "Price: ",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black),
                        children: [
                          TextSpan(
                            text: service["price"] ?? "",
                            style: const TextStyle(fontWeight: FontWeight.normal),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        text: "Availability: ",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black),
                        children: [
                          TextSpan(
                            text: service["availability"] ?? "",
                            style: const TextStyle(fontWeight: FontWeight.normal),
                          ),
                        ],
                      ),
                    ),
                    const Divider(), // Line gap between each service
                    if (_isEditing)
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeService(index),
                      ),
                  ],
                );
              }).toList(),
              if (_isEditing)
                ElevatedButton.icon(
                  onPressed: _addService,
                  icon: const Icon(Icons.add),
                  label: const Text("Add Service"),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
