import 'package:flutter/material.dart';

class ViewServicePage extends StatelessWidget {
  final String providerName;
  final String serviceName;
  final String serviceType;
  final String location;
  final String rangePrice;
  final double rating;
  final String image;
  final List<String> feedback;

  ViewServicePage({
    required this.providerName,
    required this.serviceName,
    required this.serviceType,
    required this.location,
    required this.rangePrice,
    required this.rating,
    required this.image,
    required this.feedback,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Service Details'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous page
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Image and Details
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                image,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 10),
            Text(
              providerName,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              serviceType,
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 10),
            Text(
              serviceName,
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 10),
            Text(
              'Price Range: $rangePrice',
              style: TextStyle(fontSize: 16, color: Colors.green),
            ),
            SizedBox(height: 5),
            Text(
              'Location: $location',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 5),
            Row(
              children: [
                Icon(Icons.star, size: 16, color: Colors.orange),
                SizedBox(width: 5),
                Text(
                  '$rating',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Feedback Section
            Text(
              'Customer Feedback',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: feedback.map((feedbackText) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Icon(Icons.person, size: 16, color: Colors.blue),
                      SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          feedbackText,
                          style: TextStyle(fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 20),

            // Booking Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Handle booking logic
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50), // Full width button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text('Book Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
