import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../auth/firebase_utils.dart';

class BookingCard extends StatelessWidget {
  final String companyName;
  final String problemDescription;
  final String scheduleOrCompletion;
  final String? rating;
  final String? price;
  final IconData icon;
  final Color? iconColor;

  BookingCard({
    required this.companyName,
    required this.problemDescription,
    required this.scheduleOrCompletion,
    this.rating,
    this.price,
    required this.icon,
    this.iconColor,
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
            Row(
              children: [
                Icon(icon, size: 30, color: iconColor ?? Colors.blue),
                const SizedBox(width: 10),
                Text(
                  companyName,
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
    return DefaultTabController(
      length: 4,
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
                  Tab(text: 'Cancelled'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // 'Booked' tab (Including Ongoing services)
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('bookings')
                        .where('status', isEqualTo: 'Ongoing')
                        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid) // This might be incorrect, check if it should be 'providerId'
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text('No Ongoing Services'));
                      }
                      final ongoingServices = snapshot.data!.docs;

                      return ListView.builder(
                        itemCount: ongoingServices.length,
                        itemBuilder: (context, index) {
                          final service = ongoingServices[index];
                          final data = service.data() as Map<String, dynamic>;

                          return BookingCard(
                            companyName: data['companyName'],
                            problemDescription: data['problemDescription'],
                            scheduleOrCompletion: 'Ongoing since: ${data['bookingDate']} at ${data['bookingTime']}',
                            icon: Icons.access_time, // Ongoing icon for Booked tab
                          );
                        },
                      );
                    },
                  ),


                  // 'Pending' tab (Fetching from Firestore)
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('bookings')
                        .where('status', isEqualTo: 'Pending')
                        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
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
                          final data = service.data() as Map<String, dynamic>;

                          return BookingCard(
                            companyName: data['companyName'],
                            problemDescription: data['problemDescription'],
                            scheduleOrCompletion: 'Scheduled on: ${data['bookingDate']} at ${data['bookingTime']}',
                            icon: Icons.build, // Icon for Pending tab
                          );
                        },
                      );
                    },
                  ),

                  // 'Completed' tab
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('bookings')
                        .where('status', isEqualTo: 'Completed')
                        .where('providerId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text('No Completed Services'));
                      }
                      final completedServices = snapshot.data!.docs;

                      return ListView.builder(
                        itemCount: completedServices.length,
                        itemBuilder: (context, index) {
                          final service = completedServices[index];
                          final data = service.data() as Map<String, dynamic>;

                          return BookingCard(
                            companyName: data['companyName'],
                            problemDescription: data['problemDescription'],
                            scheduleOrCompletion: 'Completed on: ${data['completionDate']}',
                            icon: Icons.check_circle, // Checked icon for Completed tab
                          );
                        },
                      );
                    },
                  ),

                  // 'Cancelled' tab
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('bookings')
                        .where('status', isEqualTo: 'Cancelled')
                        .where('providerId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text('No Cancelled Services'));
                      }
                      final cancelledServices = snapshot.data!.docs;

                      return ListView.builder(
                        itemCount: cancelledServices.length,
                        itemBuilder: (context, index) {
                          final service = cancelledServices[index];
                          final data = service.data() as Map<String, dynamic>;

                          return BookingCard(
                            companyName: data['companyName'],
                            problemDescription: data['problemDescription'],
                            scheduleOrCompletion: 'Cancelled on: ${data['cancelledDate']}',
                            icon: Icons.error, // Error icon for Cancelled tab
                            iconColor: Colors.red,
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
