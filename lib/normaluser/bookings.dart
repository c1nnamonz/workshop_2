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
  final String? finalPrice;
  final String? customerPriceRequest;
  final IconData icon;
  final Color? iconColor;
  final bool showPaymentButton;
  final VoidCallback? onEditPrice;

  BookingCard({
    required this.companyName,
    required this.problemDescription,
    required this.scheduleOrCompletion,
    this.rating,
    this.price,
    this.finalPrice,
    this.customerPriceRequest,
    required this.icon,
    this.iconColor,
    this.showPaymentButton = false,
    this.onEditPrice,
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
                alignment: Alignment.bottomLeft,
                child: Text(
                  price!,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
            if (finalPrice != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'Final Price: RM$finalPrice',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ),
            ],
            if (customerPriceRequest != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'Price Request Submitted: RM$customerPriceRequest',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange),
                ),
              ),
            ],
            if (showPaymentButton) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.bottomRight, // Align the button to the bottom right
                child: ElevatedButton(
                  onPressed: () {}, // Dummy payment button action
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: const Text('Make Payment'),
                ),
              ),
            ],
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.bottomLeft,
              child: ElevatedButton(
                onPressed: onEditPrice,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text('Edit Price'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BookingsPage extends StatelessWidget {
  void _editPrice(BuildContext context, String bookingId) {
    final TextEditingController priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Price'),
          content: TextField(
            controller: priceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'Enter new price'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final newPrice = priceController.text;
                if (newPrice.isNotEmpty) {
                  await FirebaseFirestore.instance
                      .collection('bookings')
                      .doc(bookingId)
                      .update({'Customer price request': newPrice});

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Price updated successfully.')),
                  );
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid price.')),
                  );
                }
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

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
                            finalPrice: data['Final Price'],
                            customerPriceRequest: data['Customer price request'],
                            showPaymentButton: true, // Payment button only in Booked section
                            onEditPrice: () => _editPrice(context, service.id),
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
