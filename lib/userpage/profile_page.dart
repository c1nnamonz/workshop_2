import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String _userId = "12345"; // Replace with dynamic user ID logic

  // Profile details
  String _name = "John Doe";
  int _age = 30;
  String _location = "Kuala Lumpur, Malaysia";
  String _availability = "Monday - Friday, 9:00 AM - 6:00 PM";
  double _rating = 4.5;
  String? _profileImageUrl;
  List<Map<String, String>> _services = [
    {
      "service": "Plumbing",
      "description": "Fixing pipes, leaks, and other plumbing issues.",
      "price": "RM150 - RM400"
    },
    {
      "service": "Electrical",
      "description": "Wiring, repairs, and electrical installations.",
      "price": "RM200 - RM500"
    },
  ];

  // Controllers for editing fields
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _locationController;
  late TextEditingController _availabilityController;

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _name);
    _ageController = TextEditingController(text: _age.toString());
    _locationController = TextEditingController(text: _location);
    _availabilityController = TextEditingController(text: _availability);

    // Load profile data from Firestore
    _loadProfile();
  }

  void _loadProfile() async {
    final DocumentSnapshot snapshot =
    await _firestore.collection("profiles").doc(_userId).get();

    if (snapshot.exists) {
      final data = snapshot.data() as Map<String, dynamic>;
      setState(() {
        _name = data["name"] ?? _name;
        _age = data["age"] ?? _age;
        _location = data["location"] ?? _location;
        _availability = data["availability"] ?? _availability;
        _rating = data["rating"]?.toDouble() ?? _rating;
        _profileImageUrl = data["profileImageUrl"];
        _services = List<Map<String, String>>.from(
            data["services"] ?? _services);
      });

      // Update controllers with the fetched data
      _nameController.text = _name;
      _ageController.text = _age.toString();
      _locationController.text = _location;
      _availabilityController.text = _availability;
    }
  }

  void _saveProfile() async {
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

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final fileName = "$_userId-profile-picture.jpg";
      try {
        final ref = _storage.ref().child("profile_images/$fileName");
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
              const Text("Services Offered",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ..._services.asMap().entries.map((entry) {
                final index = entry.key;
                final service = entry.value;
                return Card(
                  child: ListTile(
                    title: _isEditing
                        ? TextField(
                      decoration:
                      const InputDecoration(labelText: "Service"),
                      controller: TextEditingController(
                          text: service["service"]),
                      onChanged: (value) {
                        _services[index]["service"] = value;
                      },
                    )
                        : Text(service["service"] ?? ""),
                    subtitle: _isEditing
                        ? TextField(
                      decoration:
                      const InputDecoration(labelText: "Description"),
                      controller: TextEditingController(
                          text: service["description"]),
                      onChanged: (value) {
                        _services[index]["description"] = value;
                      },
                    )
                        : Text(service["description"] ?? ""),
                  ),
                );
              }).toList(),
              const Divider(),
            ],
          ),
        ),
      ),
    );
  }
}

class _storage {
  static ref() {}
}
