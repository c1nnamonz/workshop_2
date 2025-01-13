import 'package:flutter/material.dart';

class AcceptedBookingsPage extends StatelessWidget {
  const AcceptedBookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample data for demonstration
    final List<Map<String, String>> acceptedBookings = [
      {'Service': 'Plumbing', 'Customer': 'John Doe', 'Date': 'Jan 10, 2025'},
      {'Service': 'Electrical Repair', 'Customer': 'Jane Smith', 'Date': 'Jan 12, 2025'},
      {'Service': 'Carpentry', 'Customer': 'Alice Brown', 'Date': 'Jan 15, 2025'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accepted Bookings'),
      ),
      body: ListView.builder(
        itemCount: acceptedBookings.length,
        itemBuilder: (context, index) {
          final booking = acceptedBookings[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text('Service: ${booking['Service']}'),
              subtitle: Text('Customer: ${booking['Customer']} \nDate: ${booking['Date']}'),
            ),
          );
        },
      ),
    );
  }
}
