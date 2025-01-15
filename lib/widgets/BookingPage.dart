import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projects/widgets/BookingDetailsPage.dart';

class BookingPage extends StatelessWidget {
  // Function to fetch bookings from Firestore
  Future<List<Map<String, dynamic>>> _fetchBookings() async {
    try {
      // Get the bookings collection from Firestore
      final snapshot = await FirebaseFirestore.instance.collection('bookings').get();
      if (snapshot.docs.isEmpty) {
        // Return dummy data if no bookings are found in Firestore
        return [
          {
            'customerName': 'John Doe',
            'service': 'Overflowing Sink',
            'date': '2025-01-03',
            'time': '10:00 AM',
            'details': 'Looking for a someone to fix it.',
          }
        ];
      }
      // Parse the bookings into a list of maps
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'customerName': data['customerName'] ?? 'Unknown',
          'service': data['service'] ?? 'No Service',
          'date': data['date'] ?? 'No Date',
          'time': data['time'] ?? 'No Time',
          'details': data['details'] ?? 'No Details',
        };
      }).toList();
    } catch (e) {
      print("Error fetching bookings: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchBookings(), // Fetch the bookings from Firestore
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading bookings.'));
        } else if (snapshot.data == null || snapshot.data!.isEmpty) {
          // If there are no bookings
          return const Center(child: Text('No bookings yet.'));
        } else {
          // If bookings are available
          final bookings = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.calendar_today, color: Colors.white),
                  ),
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
        }
      },
    );
  }
}
