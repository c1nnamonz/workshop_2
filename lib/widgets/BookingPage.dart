import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'BookingDetailsPage.dart';
import 'package:projects/mppage/OngoingBookings.dart';


class BookingPage extends StatelessWidget {
  const BookingPage({Key? key}) : super(key: key);

  Future<String?> _getProviderId() async {
    final user = FirebaseAuth.instance.currentUser;
    return user?.uid; // Get the current user's ID
  }

  Future<List<Map<String, dynamic>>> _fetchBookings(String providerId) async {
    final bookingsSnapshot = await FirebaseFirestore.instance
        .collection('bookings')
        .where('providerId', isEqualTo: providerId) // Filter bookings by providerId
        .get();

    List<Map<String, dynamic>> bookingsList = [];

    for (var doc in bookingsSnapshot.docs) {
      final bookingData = doc.data();
      final userId = bookingData['userId'];
      final userSnapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();

      if (userSnapshot.exists) {
        final userData = userSnapshot.data()!;
        bookingsList.add({
          'bookingId': doc.id,
          'customerName': '${userData['firstName']} ${userData['lastName']}',
          'service': bookingData['serviceName'],
          'date': bookingData['bookingDate'],
          'details': bookingData['problemDescription'],
          'status': bookingData['status'] ?? 'Pending', // Include booking status
          'userDetails': userData, // Pass user details for later use
        });
      }
    }
    return bookingsList;
  }

  Tooltip _getStatusIcon(String status) {
    switch (status) {
      case 'Pending':
        return const Tooltip(
          message: 'Pending: Booking request not yet accepted or declined.',
          child: Icon(Icons.access_time, color: Colors.orange),
        ); // Clock icon
      case 'Completed':
        return const Tooltip(
          message: 'Completed: Service has been completed.',
          child: Icon(Icons.check_circle, color: Colors.green),
        ); // Green checkmark icon
      case 'Cancelled':
      case 'Rejected':
        return const Tooltip(
          message: 'Canceled/Declined: Booking canceled by client/provider or declined.',
          child: Icon(Icons.cancel, color: Colors.red),
        ); // Red X icon
      case 'Ongoing':
        return const Tooltip(
          message: 'Ongoing: Booking is accepted but service not yet completed.',
          child: Icon(Icons.calendar_today, color: Colors.blue),
        ); // Calendar icon
      default:
        return const Tooltip(
          message: 'Unknown status.',
          child: Icon(Icons.help_outline, color: Colors.grey),
        ); // Default help icon
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getProviderId(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || snapshot.data == null) {
          return const Center(child: Text('Error fetching provider ID.'));
        }
        final providerId = snapshot.data!;

        return FutureBuilder<List<Map<String, dynamic>>>(
          future: _fetchBookings(providerId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Error fetching bookings.'));
            }
            final bookings = snapshot.data ?? [];
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];
                final status = booking['status'];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: _getStatusIcon(status), // Status icon with Tooltip
                    title: Text(booking['customerName']),
                    subtitle: Text('${booking['service']} - ${booking['date']}'),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingDetailsPage(booking: booking),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

}