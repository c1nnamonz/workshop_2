import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fixlt'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Welcome [User] to',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Go Easy with Fixlt!',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Home Services at Your Fingertips!',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 32),
            Image.asset('images/logo1.png', width: 250,
              height:250,
              fit: BoxFit.cover,),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // Navigate to the next screen

              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                textStyle: TextStyle(fontSize: 18),
              ),
              child: Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}

