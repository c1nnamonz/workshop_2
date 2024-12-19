// main.dart
import 'package:flutter/material.dart';
import 'package:projects/bookings.dart';
import 'package:projects/home_page.dart';
import 'package:projects/signup.dart';
import 'home.dart';
import 'signin.dart'; // Import your signup.dart file

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fixlt',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PageHome(), // Set CreateAccountScreen as the initial screen
    );
  }
}
