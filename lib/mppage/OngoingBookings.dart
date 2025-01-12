import 'package:flutter/material.dart';
import '../widgets/BookingDetailsPage.dart';


class OngoingBookingsPage extends StatelessWidget {
  final List<Map<String, dynamic>> bookings;

  const OngoingBookingsPage({Key? key, required this.bookings}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Filter bookings with the status 'Ongoing'
    final ongoingBookings =
    bookings.where((booking) => booking['status'] == 'Ongoing').toList();

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
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              leading: const Icon(Icons.calendar_today, color: Colors.blue),
              title: Text('Service: ${booking['service']}'),
              subtitle: Text(
                'Customer: ${booking['customerName']}\nDate: ${booking['date']}',
              ),
              onTap: () {
                // Navigate to Booking Details Page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        BookingDetailsPage(booking: booking),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
