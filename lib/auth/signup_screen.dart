import 'dart:developer';
import 'package:geolocator/geolocator.dart';
import 'package:projects/auth/auth_service.dart';
import 'package:projects/auth/login_screen.dart';
import 'package:projects/widgets/button.dart';
import 'package:projects/widgets/textfield.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Make sure to import this for GeoPoint

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
  final TextEditingController _certificateController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool isMaintenanceProvider = false;
  Position? _currentPosition;
  LatLng? _selectedLocation;

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _certificateController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  // Function to get user's current location
  Future<void> _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location services are disabled')),
      );
      return;
    }

    // Check and request location permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied')),
        );
        return;
      }
    }

    // Get current position
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = position;
    });
  }

  void _openMapDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentPosition != null
                    ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                    : const LatLng(3.1390, 101.6869), // Default to KL if location is not available
                zoom: 15,
              ),
              onTap: (LatLng location) {
                setState(() {
                  _selectedLocation = location;
                });
                Navigator.of(context).pop();
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/login_bg.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Form and other content
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

                // User / Maintenance Provider toggle buttons
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

                // Form Fields
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
                const SizedBox(height: 10),

                // Name Fields
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _firstNameController,
                        hint: 'Enter your first name',
                        label: 'First Name',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CustomTextField(
                        controller: _lastNameController,
                        hint: 'Enter your last name',
                        label: 'Last Name',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Phone number
                CustomTextField(
                  controller: _phoneController,
                  hint: 'Enter your phone number',
                  label: 'Phone Number',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 10),

                // Certificate field for Maintenance Provider
                if (isMaintenanceProvider) ...[
                  CustomTextField(
                    controller: _certificateController,
                    hint: 'Certification Number',
                    label: 'Certificate',
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _openMapDialog,
                    child: const Text('Set Location on Map'),
                  ),
                  if (_selectedLocation != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Selected Location: ${_selectedLocation!.latitude}, ${_selectedLocation!.longitude}',
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),
                ],
                const SizedBox(height: 20),

                // Sign Up button
                CustomButton(
                  textColor: Colors.white,
                  color: Colors.green,
                  label: 'Sign Up',
                  onPressed: _signUp,
                  width: 140,  // Set a smaller width
                  height: 42,  // Set a smaller height
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
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final phoneNumber = _phoneController.text.trim();
    final certificate = isMaintenanceProvider ? _certificateController.text.trim() : null;

    // Updated location logic
    final location = _selectedLocation != null
        ? GeoPoint(_selectedLocation!.latitude, _selectedLocation!.longitude)
        : null;

    if (email.isEmpty ||
        username.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        firstName.isEmpty ||
        lastName.isEmpty ||
        phoneNumber.isEmpty ||
        (isMaintenanceProvider && certificate!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
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
        certificate: certificate,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        location: location,
      );
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else {
        throw "Failed to sign up";
      }
    } catch (e) {
      log('Sign-up error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign-up failed: $e')),
      );
    }
  }
}
