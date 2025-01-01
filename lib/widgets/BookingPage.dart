import 'package:flutter/material.dart';
import 'package:projects/widgets/BookingDetailsPage.dart';

class BookingPage extends StatelessWidget {
  final List<Map<String, dynamic>> bookings = [
    {
      'customerName': 'Alice Johnson',
      'service': 'Plumbing Repair',
      'date': '2024-12-29',
      'time': '10:00 AM',
      'details': 'Fixing a leaking pipe in the kitchen.',
    },
    {
      'customerName': 'Bob Smith',
      'service': 'Electrical Wiring',
      'date': '2024-12-30',
      'time': '02:00 PM',
      'details': 'Installing new wiring in the living room.',
    },
    {
      'customerName': 'Carol Williams',
      'service': 'Air Conditioner Repair',
      'date': '2024-12-31',
      'time': '09:30 AM',
      'details': 'Repairing the AC unit in the bedroom.',
    },
  ];

  @override
  Widget build(BuildContext context) {
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
}
