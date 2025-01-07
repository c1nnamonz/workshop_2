import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:projects/auth/firebase_utils.dart'; // Import FirebaseUtils

class ServiceCard extends StatelessWidget {
  final String providerName;
  final String serviceType;
  final String serviceName;
  final String rangePrice;
  final double rating;
  final String location;
  final String imagePath;
  final String providerId; // Add provider ID

  ServiceCard({
    required this.providerName,
    required this.serviceType,
    required this.serviceName,
    required this.rangePrice,
    required this.rating,
    required this.location,
    required this.imagePath,
    required this.providerId, // Accept provider ID
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Displaying image at the top
            Image.asset(
              imagePath,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 10),
            Text(
              providerName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              serviceType,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Service: $serviceName',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 5),
            Text(
              'Price: $rangePrice',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 5),
            Text(
              'Location: $location',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 5),
            // Displaying provider ID
            Text(
              'Provider ID: $providerId', // Showing the provider ID
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(
                  Icons.star,
                  color: Colors.orange,
                  size: 18,
                ),
                const SizedBox(width: 5),
                Text(
                  rating.toString(),
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class YourPage extends StatefulWidget {
  @override
  _YourPageState createState() => _YourPageState();
}

class _YourPageState extends State<YourPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _providerId; // Variable to store provider ID

  @override
  void initState() {
    super.initState();
    _getCurrentUserData();
  }

  // Get current user's ID using FirebaseUtils
  Future<void> _getCurrentUserData() async {
    final userDoc = await FirebaseUtils.getCurrentUserDocument();
    if (userDoc != null) {
      setState(() {
        _providerId = userDoc.id; // Set the provider ID from the document ID
      });
    } else {
      // Handle case where user is not logged in or document doesn't exist
      print("User document not found.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Service Provider Page")),
      body: Center(
        child: _providerId == null
            ? CircularProgressIndicator() // Show loading until providerId is retrieved
            : ServiceCard(
          providerName: "John Doe", // Example provider name, replace with real data
          serviceType: "Plumbing", // Example service type
          serviceName: "Leak Repair", // Example service name
          rangePrice: "\$50 - \$100", // Example price range
          rating: 4.5, // Example rating
          location: "Kuala Lumpur, Malaysia", // Example location
          imagePath: "assets/plumber_icon.png", // Example image path
          providerId: _providerId!, // Pass the retrieved provider ID
        ),
      ),
    );
  }
}
