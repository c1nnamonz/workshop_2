import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projects/auth/auth_service.dart';
import 'package:projects/auth/signup_screen.dart';
import 'package:projects/home_page.dart';
import 'package:projects/widgets/button.dart';
import 'package:projects/widgets/textfield.dart';
import 'package:flutter/material.dart';

import '../mppage/mp_homepage.dart';
import '../normaluser/user_homepage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = AuthService();

  final _username = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/login_bg.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Login form content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              children: [
                const Spacer(),
                const Text(
                  "Hello!",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 50),
                CustomTextField(
                  hint: "Enter Username",
                  label: "Username",
                  controller: _username,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  hint: "Enter Password",
                  label: "Password",
                  isPassword: true,
                  controller: _password,
                ),
                const SizedBox(height: 30),
                CustomButton(
                  label: "Login",
                  textColor: Colors.white,
                  onPressed: _login,
                  color: Colors.green,
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Does not have an account? ",
                      style: TextStyle(color: Colors.black),
                    ),
                    InkWell(
                      onTap: () => goToSignup(context),
                      child: const Text(
                        "Signup",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  goToSignup(BuildContext context) => Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const SignupScreen()),
  );

  goToHome(BuildContext context) => Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const HomePage()),
  );

  _login() async {
    try {
      // Disable the login button temporarily
      setState(() {});
      final user = await _auth.loginUserWithUsernameAndPassword(
        _username.text.trim(),
        _password.text.trim(),
      );

      if (user != null) {
        // Fetch user details from Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          final role = userDoc.data()?['role'] ?? 'User';
          final status = userDoc.data()?['status'];

          // Handle login based on the status field
          if (status == 'Rejected') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Your registration request has been rejected.'),
              ),
            );
            return;
          } else if (status == 'Banned') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Your account has been banned.'),
              ),
            );
            return;
          } else if (status == 'Pending'|| status == 'pending') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Your registration request is still pending.'),
              ),
            );
            return;
          } else if (status == 'active' || status == null || status == 'Active') {
            // Navigate to the appropriate home page based on the role
            if (role == 'Maintenance Provider') {
              log("Maintenance Provider Logged In");
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const MaintenanceProviderHomePage(),
                ),
              );
            } else {
              log("Normal User Logged In");
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => UserHomepage(),
                ),
              );
            }
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User data not found. Please contact support.'),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid username or password.'),
          ),
        );
      }
    } catch (e) {
      log("Login error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed: $e'),
        ),
      );
    } finally {
      setState(() {});
    }
  }
}
