import 'package:flutter/material.dart';
import 'package:projects/widgets/ChatPage.dart';

class BookingDetailsPage extends StatelessWidget {
  final Map<String, dynamic> booking;

  const BookingDetailsPage({super.key, required this.booking});

  // Method to navigate to the Chat page after accepting the booking
  void _acceptBooking(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(booking: booking), // Assuming ChatPage takes booking data
      ),
    );
  }

  // Method to handle Decline action (you can replace this with other logic)
  void _declineBooking(BuildContext context) {
    Navigator.pop(context); // Close the current page (you can modify this action)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Customer Details',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.blue,
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: Text(booking['customerName']),
              subtitle: Text('Service: ${booking['service']}'),
            ),
            const Divider(height: 40),
            const Text(
              'Booking Information',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('Date: ${booking['date']}'),
            const SizedBox(height: 10),
            Text('Time: ${booking['time']}'),
            const SizedBox(height: 20),
            const Text(
              'Additional Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(booking['details']),
            const SizedBox(height: 20),
            // Accept and Decline Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _acceptBooking(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Green color for Accept
                  ),
                  child: const Text('Accept'),
                ),
                ElevatedButton(
                  onPressed: () => _declineBooking(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Red color for Decline
                  ),
                  child: const Text('Decline'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
