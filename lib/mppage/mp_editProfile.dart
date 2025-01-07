import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditMaintenanceProfilePage extends StatefulWidget {
  final String companyName;
  final String ownerName;
  final String operatingHours;
  final String location;
  final String profileImageUrl;  // Accept the profile image URL as well
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

  @override
  void initState() {
    super.initState();
    _companyNameController = TextEditingController(text: widget.companyName);
    _ownerNameController = TextEditingController(text: widget.ownerName);
    _operatingHoursController =
        TextEditingController(text: widget.operatingHours);
    _locationController = TextEditingController(text: widget.location);
  }

  // Save the profile to Firestore in the "users" collection
  Future<void> _saveToFirestore() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    User? user = _auth.currentUser;
    if (user != null) {
      // Prepare the updated profile data
      final profileData = {
        'companyName': _companyNameController.text,
        'ownerName': _ownerNameController.text,
        'operatingHours': _operatingHoursController.text,
        'location': _locationController.text,
        'profileImageUrl': widget.profileImageUrl, // Pass profile image URL as well
      };

      try {
        // Update the user document in the "users" collection
        await _firestore.collection('users').doc(user.uid).set(profileData, SetOptions(merge: true));
        print("Profile successfully updated in Firestore.");
      } catch (e) {
        print("Error updating profile: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Maintenance Provider Profile'),
        backgroundColor: Colors.orangeAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Company Name TextField
                      TextField(
                        controller: _companyNameController,
                        decoration: InputDecoration(
                          labelText: 'Company Name',
                          prefixIcon: const Icon(Icons.business),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      // Owner Name TextField
                      TextField(
                        controller: _ownerNameController,
                        decoration: InputDecoration(
                          labelText: 'Owner Name',
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      // Operating Hours TextField
                      TextField(
                        controller: _operatingHoursController,
                        decoration: InputDecoration(
                          labelText: 'Operating Hours',
                          prefixIcon: const Icon(Icons.schedule),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      // Location TextField
                      TextField(
                        controller: _locationController,
                        decoration: InputDecoration(
                          labelText: 'Location',
                          prefixIcon: const Icon(Icons.location_on),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Save Button
              ElevatedButton(
                onPressed: () {
                  widget.onSave(
                    _companyNameController.text,
                    _ownerNameController.text,
                    _operatingHoursController.text,
                    _locationController.text,
                    widget.profileImageUrl, // Pass the current profile image URL
                  );
                  _saveToFirestore();  // Save to Firestore after editing
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.orangeAccent,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Save",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
