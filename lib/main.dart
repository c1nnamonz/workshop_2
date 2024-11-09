import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:projects/splash_screen.dart';



void main() {
  WidgetsFlutterBinding.ensureInitialized();
   Firebase.initializeApp(
      options: const FirebaseOptions(apiKey: "AIzaSyBLIb6rC2qMc9Y1Pn2z79AxJuyq21WKoWA",
      authDomain: "workshop-2-5867f.firebaseapp.com",
      projectId: "workshop-2-5867f",
      storageBucket: "workshop-2-5867f.firebasestorage.app",
      messagingSenderId: "1087849438293",
      appId: "1:1087849438293:web:99eb5bee6a544227e8c8dc",
      measurementId: "G-9QEHEEZNF7"));

  runApp(const SplashScreenApp());
}

class SplashScreenApp extends StatelessWidget {
  const SplashScreenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
