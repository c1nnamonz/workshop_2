import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingDetailsPage extends StatefulWidget {
  final Map<String, dynamic> booking;

  const BookingDetailsPage({Key? key, required this.booking}) : super(key: key);

  @override
  _BookingDetailsPageState createState() => _BookingDetailsPageState();
}

class _BookingDetailsPageState extends State<BookingDetailsPage> {
  late String status;

  @override
  void initState() {
    super.initState();
    status = widget.booking['status'] ?? 'Pending';  // Default to 'Pending' if 'status' is null
  }

  // Fetch the updated booking status from Firestore
  Future<void> _fetchBookingStatus() async {
    final bookingId = widget.booking['bookingId'];
    final bookingDoc = await FirebaseFirestore.instance.collection('bookings').doc(bookingId).get();
    final updatedStatus = bookingDoc.data()?['status'] ?? 'Pending';
    setState(() {
      status = updatedStatus;  // Update the status from Firestore
    });
  }

  Future<void> _updateBookingStatus(String newStatus) async {
    final bookingId = widget.booking['bookingId'];
    await FirebaseFirestore.instance.collection('bookings').doc(bookingId).update({
      'status': newStatus,
    });

    setState(() {
      status = newStatus;  // Update the status in the local state to reflect the change
    });
  }

  void _acceptBooking(BuildContext context) async {
    await _updateBookingStatus('Ongoing');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Booking accepted.')),
    );
  }

  void _declineBooking(BuildContext context) async {
    await _updateBookingStatus('Rejected');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Booking declined.')),
    );
  }

  void _cancelService(BuildContext context) async {
    await _updateBookingStatus('Cancelled');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Service cancelled.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userDetails = widget.booking['userDetails'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Details'),
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
              title: Text('${userDetails['firstName']} ${userDetails['lastName']}'),
              subtitle: Text(userDetails['email']),
            ),
            const Divider(height: 40),
            const Text(
              'Booking Information',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('Service: ${widget.booking['service']}'),
            const SizedBox(height: 10),
            Text('Date: ${widget.booking['date']}'),
            const SizedBox(height: 10),
            Text('Details: ${widget.booking['details']}'),
            const SizedBox(height: 20),
            if (status == 'Pending') ...[
              // Show Accept and Decline buttons only when the status is Pending
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => _acceptBooking(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('Accept'),
                  ),
                  ElevatedButton(
                    onPressed: () => _declineBooking(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Decline'),
                  ),
                ],
              ),
            ] else if (status == 'Ongoing') ...[
              // Show Cancel Service button if the booking is Ongoing
              ElevatedButton(
                onPressed: () => _cancelService(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
                child: const Text('Cancel Service'),
              ),
            ] else ...[
              // If the status is anything other than Pending or Ongoing, show nothing
              const SizedBox.shrink(),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchBookingStatus();  // Fetch status whenever the page is revisited
  }
}
