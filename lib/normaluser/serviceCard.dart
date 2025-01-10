import 'package:flutter/material.dart';

class ServiceCard extends StatelessWidget {
  final String serviceType;
  final String serviceName;
  final String rangePrice;
  final double rating;
  final String location;
  final String companyName;
  final String providerId;
  final String imagePath; // Add imagePath field

  ServiceCard({
    required this.serviceType,
    required this.serviceName,
    required this.rangePrice,
    required this.rating,
    required this.location,
    required this.companyName,
    required this.providerId,
    required this.imagePath, // Include the image path in constructor
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Image section - Display service icon/image
            Image.asset(
              imagePath,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
            const SizedBox(width: 15),
            // Service Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    serviceName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Company: $companyName',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Location: $location',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Price Range: $rangePrice',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            // Rating Section
            Column(
              children: [
                const Icon(Icons.star, color: Colors.orange, size: 20),
                Text(
                  rating.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
