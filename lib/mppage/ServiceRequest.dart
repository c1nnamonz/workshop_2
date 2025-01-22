import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceRequest extends StatefulWidget {
  @override
  _ServiceRequestState createState() => _ServiceRequestState();
}

class _ServiceRequestState extends State<ServiceRequest> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String? _selectedCategory;
  File? _selectedCertificate;
  bool _isLoading = false;
  List<String> _serviceCategories = [
    'Plumbing',
    'Electrical',
    'Air-cond',
    'Cleaning',
    'Renovation',
    'Security',
    'Landscaping',
    'Pest Control',
    'Appliance Repair',
    'Furniture Assembly',
    'Smart Home Installation',
    'Pool Maintenance',
  ]; // Example categories

  final TextEditingController _requestDescriptionController = TextEditingController();

  Future<void> _pickCertificate() async {
    // Use FilePicker to select a PDF file
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'], // Only allow PDF files
    );

    if (result != null) {
      setState(() {
        _selectedCertificate = File(result.files.single.path!);
      });
    }
  }

  Future<void> _submitRequest() async {
    if (_selectedCategory == null || _selectedCertificate == null || _requestDescriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all the fields and upload a certificate.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Upload the certificate to Firebase Storage
      String fileName = DateTime.now().millisecondsSinceEpoch.toString() + '.pdf';
      Reference storageRef = _storage.ref().child('certificates/$fileName');
      UploadTask uploadTask = storageRef.putFile(_selectedCertificate!);
      TaskSnapshot snapshot = await uploadTask;

      String downloadUrl = await snapshot.ref.getDownloadURL();

      // Save request to Firestore
      await _firestore.collection('serviceRequests').add({
        'category': _selectedCategory,
        'certificateUrl': downloadUrl,
        'description': _requestDescriptionController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Service request submitted successfully!')),
      );

      Navigator.pop(context); // Go back to the previous screen after successful submission
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit request: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Request New Service')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dropdown for service categories
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                hint: Text('Select Service Category'),
                items: _serviceCategories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                decoration: InputDecoration(labelText: 'Service Category'),
              ),
              const SizedBox(height: 20),

              // Request description text field
              TextField(
                controller: _requestDescriptionController,
                decoration: InputDecoration(
                  labelText: 'Description of the Request',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),

              // Button to pick the certificate file
              _selectedCertificate == null
                  ? ElevatedButton(
                onPressed: _pickCertificate,
                child: Text('Upload Certificate (PDF)'),
              )
                  : Column(
                children: [
                  Text('Certificate uploaded: ${_selectedCertificate!.path.split('/').last}'),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _pickCertificate,
                    child: Text('Change Certificate'),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Submit button
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _submitRequest,
                child: Text('Submit Request'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
