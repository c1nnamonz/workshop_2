import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Add Firebase Storage
import 'dart:io';

class EditMaintenanceProfilePage extends StatefulWidget {
  final String companyName;
  final String ownerName;
  final String operatingHours;
  final String location;
  final String profileImageUrl;
  final Function(String, String, String, String, String) onSave;

  EditMaintenanceProfilePage({
    required this.companyName,
    required this.ownerName,
    required this.operatingHours,
    required this.location,
    required this.profileImageUrl,
    required this.onSave,
  });

  @override
  _EditMaintenanceProfilePageState createState() =>
      _EditMaintenanceProfilePageState();
}

class _EditMaintenanceProfilePageState
    extends State<EditMaintenanceProfilePage> {
  late TextEditingController _companyNameController;
  late TextEditingController _ownerNameController;
  late TextEditingController _operatingHoursController;
  late TextEditingController _locationController;

  String? _profileImageUrl;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _companyNameController = TextEditingController(text: widget.companyName);
    _ownerNameController = TextEditingController(text: widget.ownerName);
    _operatingHoursController =
        TextEditingController(text: widget.operatingHours);
    _locationController = TextEditingController(text: widget.location);
    _profileImageUrl = widget.profileImageUrl;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _profileImageUrl = null; // Clear the previous image URL
      });
    }
  }

  Future<String?> _uploadImageToFirebase(File imageFile) async {
    try {
      // Create a unique file name
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageRef =
      FirebaseStorage.instance.ref().child('profile_images/$fileName');

      // Upload the file
      await storageRef.putFile(imageFile);

      // Get the download URL
      return await storageRef.getDownloadURL();
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: _imageFile != null
                          ? FileImage(_imageFile!)
                          : (_profileImageUrl != null
                          ? NetworkImage(_profileImageUrl!)
                          : null) as ImageProvider<Object>?,
                      child: _profileImageUrl == null && _imageFile == null
                          ? const Icon(Icons.camera_alt, size: 40)
                          : null,
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.4),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _companyNameController,
                decoration: const InputDecoration(labelText: 'Company Name'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _ownerNameController,
                decoration: const InputDecoration(labelText: 'Owner Name'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _operatingHoursController,
                decoration:
                const InputDecoration(labelText: 'Operating Hours'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  String? imageUrl;
                  if (_imageFile != null) {
                    imageUrl = await _uploadImageToFirebase(_imageFile!);
                  }

                  widget.onSave(
                    _companyNameController.text,
                    _ownerNameController.text,
                    _operatingHoursController.text,
                    _locationController.text,
                    imageUrl ?? _profileImageUrl ?? widget.profileImageUrl,
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightGreen, // Light green background
                  foregroundColor: Colors.white, // White text color
                ),
                child: const Text("Save"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
