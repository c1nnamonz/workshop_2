import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:projects/auth/signup_screen.dart';
import 'package:projects/constant/size.dart';
import 'package:projects/auth/login_screen.dart';
import '../constant/image_strings.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color(0xFFD3D3D3),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              "images/bg_image.png",
              fit: BoxFit.cover,
            ),
          ),
          // Foreground Content
          Padding(
            padding: const EdgeInsets.all(tDefaultSize),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start, // Align children at the top
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image(
                  image: const AssetImage(tWelcomeScreenImage),
                  height: height * 0.6,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0), // Add small space above this Text
                  child: Text(
                    "Trusted Home Services, Anytime, Anywhere!",
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontSize: 29,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 12.0), // Add small space above this Text
                  child: Text(
                    "Login or Sign Up to Access Reliable Home Services, at Your Fingertips!",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen()),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        shape: const RoundedRectangleBorder(),
                        foregroundColor: const Color(0xFF181919),
                        side: const BorderSide(color: Colors.black54),
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            vertical: 15.0, horizontal: 45),
                      ),
                      child: const Text("LOGIN"),
                    ),

                    const SizedBox(width: 15),
                    const Text("OR",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                    const SizedBox(width: 15),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignupScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const RoundedRectangleBorder(),
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white60),
                        backgroundColor: const Color(0xFF0A7C01),
                        padding: const EdgeInsets.symmetric(
                            vertical: 15.0, horizontal: 45),
                      ),
                      child: const Text("SIGNUP"),
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
}
