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
  String? finalPrice;
  String? customerPriceRequest;
  String? providerPriceRequest;
  String? paymentStatus;
  bool isPriceRequestAccepted = false;

  @override
  void initState() {
    super.initState();
    status = widget.booking['status'] ?? 'Pending';
    paymentStatus = widget.booking['paymentStatus'];
    _fetchBookingDetails();
  }

  Future<void> _fetchBookingDetails() async {
    final bookingId = widget.booking['bookingId'];

    final bookingDoc = await FirebaseFirestore.instance.collection('bookings').doc(bookingId).get();
    final data = bookingDoc.data();

    final paymentSnapshot = await FirebaseFirestore.instance
        .collection('payments')
        .where('bookingId', isEqualTo: bookingId)
        .limit(1)
        .get();

    String? fetchedPaymentStatus;
    if (paymentSnapshot.docs.isNotEmpty) {
      final paymentData = paymentSnapshot.docs.first.data();
      fetchedPaymentStatus = paymentData['paymentStatus'];
    }

    setState(() {
      status = data?['status'] ?? 'Pending';
      finalPrice = data?['Final Price'];
      customerPriceRequest = data?['Customer price request'];
      providerPriceRequest = data?['Provider price request'];
      paymentStatus = fetchedPaymentStatus;
      isPriceRequestAccepted = finalPrice == customerPriceRequest;
    });
  }

  Future<void> _updateBookingStatus(String newStatus, {String? finalPrice, String? providerPriceRequest}) async {
    final bookingId = widget.booking['bookingId'];
    final dataToUpdate = {
      'status': newStatus,
    };

    if (finalPrice != null) {
      dataToUpdate['Final Price'] = finalPrice;
    }

    if (providerPriceRequest != null) {
      dataToUpdate['Provider price request'] = providerPriceRequest;
    }

    await FirebaseFirestore.instance.collection('bookings').doc(bookingId).update(dataToUpdate);

    setState(() {
      status = newStatus;
      this.finalPrice = finalPrice ?? this.finalPrice;
      this.providerPriceRequest = providerPriceRequest ?? this.providerPriceRequest;
    });
  }

  Future<void> _acceptPriceRequest() async {
    if (customerPriceRequest != null) {
      await _updateBookingStatus(status, finalPrice: customerPriceRequest);

      setState(() {
        isPriceRequestAccepted = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Price request accepted.')),
      );
    }
  }


  Future<void> _cancelService(BuildContext context) async {
    final bookingId = widget.booking['bookingId'];
    final dataToUpdate = {
      'status': 'Cancelled',
      'cancelledAt': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance.collection('bookings').doc(bookingId).update(dataToUpdate);

    setState(() {
      status = 'Cancelled';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Service cancelled.')),
    );
  }


  void _makeProviderPriceRequest(BuildContext context) {
    final TextEditingController priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Price Request'),
          content: TextField(
            controller: priceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'Enter proposed price'),
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
                final newPriceRequest = priceController.text;
                if (newPriceRequest.isNotEmpty) {
                  await _updateBookingStatus(status, providerPriceRequest: newPriceRequest);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Price request submitted.')),
                  );
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid price.')),
                  );
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  void _acceptBooking(BuildContext context) async {
    final TextEditingController priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Final Price'),
          content: TextField(
            controller: priceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'Enter the final price'),
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
                final finalPrice = priceController.text;
                if (finalPrice.isNotEmpty) {
                  await _updateBookingStatus('Ongoing', finalPrice: finalPrice);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Booking accepted.')),
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

  void _declineBooking(BuildContext context) async {
    await _updateBookingStatus('Rejected');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Booking declined.')),
    );
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchBookingDetails();
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
            if (finalPrice != null) ...[
              const SizedBox(height: 10),
              Text('Final Price: $finalPrice', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
            if (customerPriceRequest != null) ...[
              const SizedBox(height: 10),
              Text('Customer Price Request: $customerPriceRequest', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange)),
            ],
            if (providerPriceRequest != null) ...[
              const SizedBox(height: 10),
              Text('Provider Price Request: $providerPriceRequest', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
            ],
            if (customerPriceRequest != null && status != 'Cancelled' && !isPriceRequestAccepted) ...[
              ElevatedButton(
                onPressed: _acceptPriceRequest,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('Accept Customer Price Request'),
              ),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 10),

            if (paymentStatus == 'Paid') ...[
              // Green tick symbol to indicate payment
              const Icon(Icons.check_circle, color: Colors.green, size: 30),
              const SizedBox(height: 21),
              const Text(
                'Payment made successfully!', // Added payment confirmation message
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.green),
              ),
              const SizedBox(height: 20),
              const Text(
                'Service Completed!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
              ),
            ],


            if (paymentStatus != 'Paid' && status != 'Cancelled') ...[
              ElevatedButton(
                onPressed: () => _makeProviderPriceRequest(context),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text('Make Price Request'),
              ),
              const SizedBox(height: 20),
            ],
            if (status == 'Pending') ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => _acceptBooking(context),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('Accept'),
                  ),
                  ElevatedButton(
                    onPressed: () => _cancelService(context),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Decline'),
                  ),
                ],
              ),
            ] else if (status == 'Ongoing') ...[
              ElevatedButton(
                onPressed: () => _cancelService(context),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text('Cancel Service'),
              ),
            ],

            if (status == 'Cancelled') ...[
              const Divider(height: 40),
              const Text(
                'Booking Status: Cancelled',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
              ),
              const SizedBox(height: 10),
              const Text('This booking was cancelled by the user or provider.', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              Text('Cancellation Reason: ${widget.booking['cancellationReason'] ?? 'Not provided'}', style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}