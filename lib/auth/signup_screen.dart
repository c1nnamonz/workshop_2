import 'dart:developer';

import 'package:projects/auth/auth_service.dart';
import 'package:projects/auth/login_screen.dart';
import 'package:projects/home_page.dart';
import 'package:projects/widgets/button.dart';
import 'package:projects/widgets/textfield.dart';
import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // TextEditingControllers for various input fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _certificateController = TextEditingController();

  // New Controllers for Full Name, Last Name, Phone
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // Variables for City and State (Strings instead of TextEditingController)
  String? _selectedCity;
  String? _selectedState;

  bool isMaintenanceProvider = false; // Toggle state

  // Updated map of states and their respective cities, including 'Cheng'
  Map<String, List<String>> stateCityMap = {
    'Melaka': ['Ayer Keroh', 'Melaka Town', 'Cheng'], // Added 'Cheng' here
    'Selangor': ['Shah Alam', 'Petaling Jaya', 'Cheng'], // Added 'Cheng' to another state for demonstration
    'Kuala Lumpur': ['KL City Center', 'Cheras'],
  };

  // List of states
  List<String> states = ['Melaka', 'Selangor', 'Kuala Lumpur'];

  @override
  void dispose() {
    // Dispose controllers to free up resources
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: SingleChildScrollView( // Added to prevent overflow when keyboard appears
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Role Toggle
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

            // Common Fields
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

            // Full Name and Last Name Side by Side
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

            // Phone Number
            CustomTextField(
              controller: _phoneController,
              hint: 'Enter your phone number',
              label: 'Phone Number',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 10),

            // State Dropdown
            DropdownButtonFormField<String>(
              value: _selectedState,
              decoration: const InputDecoration(
                labelText: 'Select State',
                border: OutlineInputBorder(),
              ),
              hint: const Text('Select State'),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedState = newValue;
                  _selectedCity = null; // Reset city when state changes
                });
              },
              items: states.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              validator: (value) => value == null ? 'Please select a state' : null,
            ),
            const SizedBox(height: 10),

            // City Dropdown (depends on selected state)
            DropdownButtonFormField<String>(
              value: _selectedCity,
              decoration: const InputDecoration(
                labelText: 'Select City',
                border: OutlineInputBorder(),
              ),
              hint: const Text('Select City'),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCity = newValue;
                });
              },
              items: _selectedState == null
                  ? []
                  : stateCityMap[_selectedState]!.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              // Disable the dropdown if no state is selected
              disabledHint: const Text('Select a state first'),
              validator: (value) {
                if (_selectedState != null && value == null) {
                  return 'Please select a city';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),

            // Maintenance Provider-Specific Field
            if (isMaintenanceProvider)
              CustomTextField(
                controller: _certificateController,
                hint: 'Enter your certification details',
                label: 'Certificate',
              ),
            if (isMaintenanceProvider) const SizedBox(height: 20),

            // Sign-Up Button
            CustomButton(
              label: 'Sign Up',
              onPressed: _signUp,
            ),
            const SizedBox(height: 10),

            // Login Redirect
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Already have an account?'), // Static text
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero, // Removes extra padding around the button
                  ),
                  child: const Text('Login', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _signUp() async {
    final email = _emailController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final phoneNumber = _phoneController.text.trim();
    final city = _selectedCity ?? ''; // Use the city input or dropdown value
    final state = _selectedState ?? ''; // Use the state input or dropdown value
    final certificate = isMaintenanceProvider ? _certificateController.text.trim() : null;

    // Basic validation
    if (email.isEmpty ||
        username.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        firstName.isEmpty ||
        lastName.isEmpty ||
        phoneNumber.isEmpty ||
        state.isEmpty ||
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

    // Additional validations can be added here (e.g., email format, password strength)

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
        address: city, // You can use city as the address for simplicity or modify it
        state: state,
        zipCode: '', // Handle zip code as needed
      );
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else {
        throw "Failed to sign up";
      }
    } catch (e) {
      log('Sign-up error: $e'); // Log the error for debugging
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign-up failed: $e')),
      );
    }
  }
}
