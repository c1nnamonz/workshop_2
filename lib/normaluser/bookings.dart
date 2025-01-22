import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projects/normaluser/payment.dart';
import 'package:projects/normaluser/ratingForm.dart';

import '../auth/firebase_utils.dart';

class BookingCard extends StatelessWidget {
  final String companyName;
  final String problemDescription;
  final String scheduleOrCompletion;
  final String? rating;
  final String? price;
  final String? finalPrice;
  final String? customerPriceRequest;
  final String? providerPriceRequest;
  final String bookingId;
  final String userId;
  final String providerId;
  final IconData icon;
  final Color? iconColor;
  final bool showPaymentButton;
  final bool showRatingButton; // NEW: Added this line
  final VoidCallback? onEditPrice;
  final VoidCallback? onAcceptProviderRequest;

  BookingCard({
    required this.companyName,
    required this.problemDescription,
    required this.scheduleOrCompletion,
    required this.bookingId,
    required this.userId,
    required this.providerId,
    this.rating,
    this.price,
    this.finalPrice,
    this.customerPriceRequest,
    this.providerPriceRequest,
    required this.icon,
    this.iconColor,
    this.showPaymentButton = false,
    this.showRatingButton = false, // NEW: Added this line
    this.onEditPrice,
    this.onAcceptProviderRequest,
  });

  // Define the method to show the rating form
  void showRatingForm(BuildContext context, String bookingId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RatingForm(bookingId: bookingId),
      ),
    );
  }

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
                  'Customer Price Request: RM$customerPriceRequest',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange),
                ),
              ),
            ],
            if (providerPriceRequest != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'Provider Price Request: RM$providerPriceRequest',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
              ),
            ],
            const SizedBox(height: 10),
            if (onEditPrice != null || onAcceptProviderRequest != null) ...[
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (onAcceptProviderRequest != null)
                    ElevatedButton(
                      onPressed: onAcceptProviderRequest,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                      child: const Text('Accept Provider Request', style: TextStyle(color: Colors.white),),
                    ),
                  if (onEditPrice != null)
                    ElevatedButton(
                      onPressed: onEditPrice,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                      child: const Text('Edit Price', style: TextStyle(color: Colors.white),),
                    ),
                ],
              ),
            ],
            if (showPaymentButton) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymentScreen(
                          bookingId: bookingId,
                          userId: userId,
                          providerId: providerId,
                          finalPrice: finalPrice ?? '0',
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text('Make Payment', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
            if (showRatingButton) ...[ // NEW: Added this block
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  onPressed: () {
                    showRatingForm(context, bookingId); // NEW: Call to show the rating form
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: const Text('Rate this Service', style: TextStyle(color: Colors.white)),
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

  Future<void> _acceptProviderPriceRequest(BuildContext context, String bookingId, String providerPriceRequest) async {
    await FirebaseFirestore.instance
        .collection('bookings')
        .doc(bookingId)
        .update({'Final Price': providerPriceRequest});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Provider price request accepted.')),
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
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('bookings')
                        .where('status', isEqualTo: 'Ongoing')
                        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
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

                          final providerPriceRequest = data['Provider price request'];
                          final finalPrice = data['Final Price'];

                          return BookingCard(
                            companyName: data['companyName'],
                            problemDescription: data['problemDescription'],
                            scheduleOrCompletion: 'Ongoing since: ${data['bookingDate']} at ${data['bookingTime']}',
                            icon: Icons.access_time,
                            finalPrice: data['Final Price']?.toString(),
                            customerPriceRequest: data['Customer price request'],
                            providerPriceRequest: data['Provider price request'],
                            bookingId: service.id,
                            userId: data['userId'],
                            providerId: data['providerId'],
                            showPaymentButton: true,
                            onEditPrice: () => _editPrice(context, service.id),
                            onAcceptProviderRequest: (data['Provider price request'] != null && data['Provider price request'] != data['Final Price'])
                                ? () => _acceptProviderPriceRequest(context, service.id, data['Provider price request'])
                                : null,
                          );

                        },
                      );
                    },
                  ),
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
                            scheduleOrCompletion: 'Pending since: ${data['bookingDate']} at ${data['bookingTime']}',
                            icon: Icons.hourglass_empty,
                            iconColor: Colors.orange,
                            bookingId: service.id,
                            userId: data['userId'],
                            providerId: data['providerId'],
                            price: data['price'],
                          );
                        },
                      );
                    },
                  ),

                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('bookings')
                        .where('status', isEqualTo: 'Completed')
                        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
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

                          return FutureBuilder<QuerySnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('payments')
                                .where('bookingId', isEqualTo: service.id)
                                .get(),
                            builder: (context, paymentSnapshot) {
                              if (paymentSnapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              }

                              String completionDate = 'N/A';
                              if (paymentSnapshot.hasData && paymentSnapshot.data!.docs.isNotEmpty) {
                                final paymentData = paymentSnapshot.data!.docs.first.data() as Map<String, dynamic>;
                                final createdAt = paymentData['createdAt'] as Timestamp;
                                completionDate = '${createdAt.toDate()}';
                              }

                              return BookingCard(
                                companyName: data['companyName'],
                                problemDescription: data['problemDescription'],
                                scheduleOrCompletion: 'Completed on: $completionDate',
                                icon: Icons.check_circle,
                                iconColor: Colors.green,
                                bookingId: service.id,
                                userId: data['userId'],
                                providerId: data['providerId'],
                                price: data['price'],
                                finalPrice: data['Final Price'],
                                rating: data['rating'],
                                showRatingButton: true, // Show the "Rate this Service" button
                              );
                            },
                          );
                        },
                      );
                    },
                  ),


                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('bookings')
                        .where('status', isEqualTo: 'Cancelled')
                        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
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

                          return FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('bookings')
                                .doc(service.id)
                                .get(),
                            builder: (context, cancellationSnapshot) {
                              if (cancellationSnapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              }

                              String cancelledDate = 'N/A';
                              if (cancellationSnapshot.hasData && cancellationSnapshot.data != null) {
                                final cancelledAt = cancellationSnapshot.data!['cancelledAt'] as Timestamp?;
                                if (cancelledAt != null) {
                                  cancelledDate = '${cancelledAt.toDate()}';
                                }
                              }

                              return BookingCard(
                                companyName: data['companyName'],
                                problemDescription: data['problemDescription'],
                                scheduleOrCompletion: 'Cancelled on: $cancelledDate',
                                icon: Icons.cancel,
                                iconColor: Colors.red,
                                bookingId: service.id,
                                userId: data['userId'],
                                providerId: data['providerId'],
                                price: data['price'],
                                finalPrice: data['Final Price'],
                              );
                            },
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
