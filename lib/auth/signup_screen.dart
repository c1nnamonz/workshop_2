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
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _certificateController = TextEditingController();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool isMaintenanceProvider = false;

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
            const SizedBox(height: 10),

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

            CustomTextField(
              controller: _phoneController,
              hint: 'Enter your phone number',
              label: 'Phone Number',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 10),

            if (isMaintenanceProvider)
              CustomTextField(
                controller: _certificateController,
                hint: 'Certification Number',
                label: 'Certificate',
              ),
            if (isMaintenanceProvider) const SizedBox(height: 20),
            const SizedBox(height: 20),
            CustomButton(
              label: 'Sign Up',
              onPressed: _signUp,
            ),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Already have an account?'),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
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
    final certificate = isMaintenanceProvider ? _certificateController.text.trim() : null;

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
