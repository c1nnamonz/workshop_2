import 'dart:developer';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:projects/auth/auth_service.dart';
import 'package:projects/auth/login_screen.dart';
import 'package:projects/widgets/button.dart';
import 'package:projects/widgets/textfield.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool isMaintenanceProvider = false;
  Position? _currentPosition;
  LatLng? _selectedLocation;
  List<File>? _selectedCertificates = [];
  String? _uploadedCertificateUrl;

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _companyNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location services are disabled')),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied')),
        );
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = position;
    });
  }

  Future<void> _selectCertificates() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true,  // Allow multiple file selection
    );

    if (result != null) {
      setState(() {
        _selectedCertificates = result.files.map((file) => File(file.path!)).toList();  // Store selected files as a list
      });
    }
  }

  Future<List<String>> _uploadCertificates(List<File> files, String userId) async {
    List<String> uploadedUrls = [];

    try {
      for (var file in files) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('certificates/$userId/${DateTime.now().millisecondsSinceEpoch}_${file.uri.pathSegments.last}');

        log('Uploading file: ${file.path}');

        final uploadTask = await storageRef.putFile(file);
        log('Upload completed: ${uploadTask.ref.name}');

        final fileUrl = await uploadTask.ref.getDownloadURL();
        uploadedUrls.add(fileUrl);
      }

      return uploadedUrls;
    } catch (e) {
      log('Certificate upload error: $e');
      throw 'Failed to upload certificates: $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/login_bg.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 120),
                const Center(
                  child: Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4F4B4B),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => setState(() {
                        isMaintenanceProvider = false;
                      }),
                      style: TextButton.styleFrom(
                        backgroundColor: !isMaintenanceProvider ? Colors.green : Colors.grey[300],
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      ),
                      child: const Text('User', style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () => setState(() {
                        isMaintenanceProvider = true;
                      }),
                      style: TextButton.styleFrom(
                        backgroundColor: isMaintenanceProvider ? Colors.green : Colors.grey[300],
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      ),
                      child: const Text('Maintenance Provider', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: _emailController,
                  hint: 'Enter your email',
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: _usernameController,
                  hint: 'Enter your username',
                  label: 'Username',
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: _passwordController,
                  hint: 'Enter your password',
                  label: 'Password',
                  isPassword: true,
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: _confirmPasswordController,
                  hint: 'Re-enter your password',
                  label: 'Confirm Password',
                  isPassword: true,
                ),
                // Show company name field for maintenance providers only
                if (isMaintenanceProvider) ...[
                  const SizedBox(height: 10),
                  CustomTextField(
                    controller: _companyNameController,
                    hint: 'Enter your company name',
                    label: 'Company Name',
                  ),
                ],
                const SizedBox(height: 10),
                CustomTextField(
                  controller: _phoneController,
                  hint: 'Enter your phone number',
                  label: 'Phone Number',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 10),
                if (isMaintenanceProvider) ...[
                  ElevatedButton(
                    onPressed: _selectCertificates,
                    child: Text(_selectedCertificates == null || _selectedCertificates!.isEmpty
                        ? 'Upload Certificates (PDF)'
                        : 'Certificates Selected'),
                  ),
                  if (_selectedCertificates != null && _selectedCertificates!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _selectedCertificates!
                            .map((file) => Text(
                          'Selected File: ${file.path.split('/').last}',
                          style: const TextStyle(color: Colors.black87),
                        ))
                            .toList(),
                      ),
                    ),
                ],
                const SizedBox(height: 20),
                CustomButton(
                  textColor: Colors.white,
                  color: Colors.green,
                  label: 'Sign Up',
                  onPressed: _signUp,
                  width: 140,
                  height: 42,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account? ",
                      style: TextStyle(color: Colors.black),
                    ),
                    InkWell(
                      onTap: () => goToLogin(context),
                      child: const Text(
                        "Login",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  goToLogin(BuildContext context) => Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const LoginScreen()),
  );

  void _signUp() async {
    final email = _emailController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final companyName = _companyNameController.text.trim();
    final phoneNumber = _phoneController.text.trim();

    final location = _selectedLocation != null
        ? GeoPoint(_selectedLocation!.latitude, _selectedLocation!.longitude)
        : null;

    if (email.isEmpty ||
        username.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        (isMaintenanceProvider ? companyName.isEmpty : false) ||
        phoneNumber.isEmpty ||
        (isMaintenanceProvider && (_selectedCertificates == null || _selectedCertificates!.isEmpty))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    try {
      final user = await AuthService().createUserWithUsernameAndEmail(
        username,
        email,
        password,
        role: isMaintenanceProvider ? 'Maintenance Provider' : 'User',
        companyName: isMaintenanceProvider ? companyName : null,
        phoneNumber: phoneNumber,
        location: location,
      );

      if (user != null) {
        List<String>? uploadedCertificateUrls;
        if (isMaintenanceProvider && _selectedCertificates != null && _selectedCertificates!.isNotEmpty) {
          uploadedCertificateUrls = await _uploadCertificates(_selectedCertificates!, user.uid);
        }

        final userData = {
          'username': username,
          'email': email,
          'phoneNumber': phoneNumber,
          'role': isMaintenanceProvider ? 'Maintenance Provider' : 'User',
          'companyName': isMaintenanceProvider ? companyName : null,
          'location': location,
          'status': isMaintenanceProvider ? 'pending' : 'active', // Default value
          'certificates': uploadedCertificateUrls,  // Store URLs of uploaded certificates
          'serviceArea': isMaintenanceProvider ? 'General Area' : null,  // Default value
          'category': isMaintenanceProvider ? [] : null, // Initialize 'category' as an empty array
        };

        // Save to Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set(userData);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign-up successful!')),
        );

        goToLogin(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User creation failed.')),
        );
      }
    } catch (e) {
      log('Sign-up error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign-up failed: $e')),
      );
    }
  }
}
