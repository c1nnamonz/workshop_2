import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projects/widgets/BookingDetailsPage.dart';

class OngoingBookingsPage extends StatelessWidget {
  const OngoingBookingsPage({Key? key, required List<Map<String, dynamic>> bookings}) : super(key: key);

  Future<String?> _getProviderId() async {
    final user = FirebaseAuth.instance.currentUser;
    return user?.uid; // Get the current user's ID
  }

  Future<List<Map<String, dynamic>>> _fetchOngoingBookings(String providerId) async {
    final bookingsSnapshot = await FirebaseFirestore.instance
        .collection('bookings')
        .where('providerId', isEqualTo: providerId)
        .where('status', isEqualTo: 'Ongoing') // Filter for ongoing bookings
        .get();

    List<Map<String, dynamic>> ongoingBookings = [];

    for (var doc in bookingsSnapshot.docs) {
      final bookingData = doc.data();
      final userId = bookingData['userId'];
      final userSnapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();

      if (userSnapshot.exists) {
        final userData = userSnapshot.data()!;
        ongoingBookings.add({
          'bookingId': doc.id,
          'customerName': '${userData['firstName']} ${userData['lastName']}',
          'service': bookingData['serviceName'],
          'date': bookingData['bookingDate'],
          'details': bookingData['problemDescription'],
          'status': bookingData['status'], // Include booking status
          'userDetails': userData, // Pass user details for later use
        });
      }
    }
    return ongoingBookings;
  }

  Tooltip _getStatusIcon(String status) {
    switch (status) {
      case 'Ongoing':
        return Tooltip(
          message: 'Ongoing: Booking is accepted but not yet completed.',
          child: const Icon(Icons.calendar_today, color: Colors.blue),
        );
      default:
        return Tooltip(
          message: 'Unknown status.',
          child: const Icon(Icons.help_outline, color: Colors.grey),
        );
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
          future: _fetchOngoingBookings(providerId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Error fetching ongoing bookings.'));
            }
            final ongoingBookings = snapshot.data ?? [];
            return Scaffold(
              appBar: AppBar(
                title: const Text('Ongoing Bookings'),
              ),
              body: ongoingBookings.isEmpty
                  ? const Center(
                child: Text('No ongoing bookings available.'),
              )
                  : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: ongoingBookings.length,
                itemBuilder: (context, index) {
                  final booking = ongoingBookings[index];
                  final status = booking['status'];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: _getStatusIcon(status),
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
              ),
            );
          },
        );
      },
    );
  }
}
