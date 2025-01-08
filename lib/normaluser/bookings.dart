import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../auth/firebase_utils.dart';

class BookingCard extends StatelessWidget {
  final String companyName; // Changed from serviceName to companyName
  final String problemDescription;
  final String scheduleOrCompletion;
  final String? rating; // Optional for "Completed" tab
  final String? price; // Optional for "Completed" tab
  final IconData icon; // New parameter for the icon
  final Color? iconColor; // Optional for custom icon color

  BookingCard({
    required this.companyName, // Changed here
    required this.problemDescription,
    required this.scheduleOrCompletion,
    this.rating,
    this.price,
    required this.icon, // Required for the icon
    this.iconColor, // Optional for custom icon color
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row for icon and company name
            Row(
              children: [
                Icon(icon, size: 30, color: iconColor ?? Colors.blue),
                const SizedBox(width: 10), // Space between icon and text
                Text(
                  companyName, // Updated here
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              problemDescription,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            const SizedBox(height: 5),
            Text(
              scheduleOrCompletion,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            if (rating != null) ...[
              const SizedBox(height: 8),
              Text(
                rating!,
                style: TextStyle(fontSize: 14, color: Colors.orange[700]),
              ),
            ],
            if (price != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  price!,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class BookingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Dummy data for the "Booked" tab
    final bookedServices = [
      {
        'companyName': "HomeFix Repairs", // Changed here
        'problemDescription': "Air-conditioner servicing",
        'schedule': "Scheduled on: 2024-12-22, 11:00 AM",
      },
      {
        'companyName': "Sparkle Cleaners", // Changed here
        'problemDescription': "Kitchen deep cleaning",
        'schedule': "Scheduled on: 2024-12-23, 9:00 AM",
      },
    ];

    // Dummy data for the "Completed" tab
    final completedServices = [
      {
        'companyName': "John's Plumbing", // Changed here
        'problemDescription': "Pipe leaking",
        'rating': "⭐⭐⭐⭐",
        'completionDate': "Completed on: 2024-12-20, 3:00 PM",
        'price': "RM57",
      },
      {
        'companyName': "CleanPro Cleaning", // Changed here
        'problemDescription': "Full home cleaning",
        'rating': "⭐⭐⭐⭐⭐",
        'completionDate': "Completed on: 2024-12-18, 10:00 AM",
        'price': "RM120",
      },
    ];

    // Dummy data for canceled services
    final canceledServices = [
      {
        'companyName': "QuickFix Electrical", // Changed here
        'problemDescription': "Wiring installation canceled",
        'completionDate': "Canceled on: 2024-12-19, 12:00 PM",
      },
    ];

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          flexibleSpace: SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 16.0),
                  Text(
                    'Booked Services',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            // TabBar wrapped in a styled container
            Container(
              color: Colors.grey[200],
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: const TabBar(
                labelColor: Colors.black87,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.black26,
                indicatorWeight: 3.0,
                tabs: [
                  Tab(text: 'Booked'),
                  Tab(text: 'Pending'),
                  Tab(text: 'Completed'),
                ],
              ),
            ),
            // TabBarView for the content
            Expanded(
              child: TabBarView(
                children: [
                  // 'Booked' tab
                  bookedServices.isNotEmpty
                      ? ListView.builder(
                    itemCount: bookedServices.length,
                    itemBuilder: (context, index) {
                      final service = bookedServices[index];
                      return BookingCard(
                        companyName: service['companyName']!, // Changed here
                        problemDescription: service['problemDescription']!,
                        scheduleOrCompletion: service['schedule']!,
                        icon: Icons.calendar_today, // Scheduled icon for Booked tab
                      );
                    },
                  )
                      : const Center(child: Text('No Booked Services')),

                  // 'Pending' tab (Fetching from Firestore)
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('bookings')
                        .where('status', isEqualTo: 'Pending') // Filter for pending bookings
                        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid) // Using FirebaseAuth to get the current user's UID
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text('No Pending Services'));
                      }
                      final pendingServices = snapshot.data!.docs;

                      return ListView.builder(
                        itemCount: pendingServices.length,
                        itemBuilder: (context, index) {
                          final service = pendingServices[index];
                          return BookingCard(
                            companyName: service['companyName'], // Display company name
                            problemDescription: service['description'], // Display the service description
                            scheduleOrCompletion: 'Created on: ${service['createdAt'].toDate()}', // Show creation date
                            icon: Icons.build, // Icon for Pending tab
                          );
                        },
                      );
                    },
                  ),



                  // 'Completed' tab
                  completedServices.isNotEmpty || canceledServices.isNotEmpty
                      ? ListView(
                    children: [
                      ...completedServices.map((service) => BookingCard(
                        companyName: service['companyName']!, // Changed here
                        problemDescription: service['problemDescription']!,
                        scheduleOrCompletion: service['completionDate']!,
                        rating: service['rating'],
                        price: service['price'],
                        icon: Icons.check_circle, // Checked icon for Completed tab
                      )),
                      ...canceledServices.map((service) => BookingCard(
                        companyName: service['companyName']!, // Changed here
                        problemDescription: service['problemDescription']!,
                        scheduleOrCompletion: service['completionDate']!,
                        icon: Icons.error, // Exclamation icon for canceled services
                        iconColor: Colors.red,
                      )),
                    ],
                  )
                      : const Center(child: Text('No Completed Services')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
