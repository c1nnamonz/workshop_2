import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingForm extends StatefulWidget {
  final String providerId; // Unique ID
  final String providerName; // For display purposes
  final String serviceType;
  final String serviceName;
  final String rangePrice;
  final String location;

  BookingForm({
    required this.providerId,
    required this.providerName,
    required this.serviceType,
    required this.serviceName,
    required this.rangePrice,
    required this.location,
  });

  @override
  _BookingFormState createState() => _BookingFormState();
}

class _BookingFormState extends State<BookingForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _userPhoneController = TextEditingController();

  // Function to handle form submission and save data to Firebase
  void _submitBooking() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Get the current user's ID
        String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

        // Add booking data to Firestore, including userId and providerId
        await FirebaseFirestore.instance.collection('bookings').add({
          'providerId': widget.providerId, // Use providerId directly
          'providerName': widget.providerName, // Optional, for display
          'serviceType': widget.serviceType,
          'serviceName': widget.serviceName,
          'price': widget.rangePrice,
          'location': widget.location,
          'bookingDate': _dateController.text,
          'bookingTime': _timeController.text,
          'userName': _userNameController.text,
          'userPhone': _userPhoneController.text,
          'status': 'Pending', // Default booking status
          'userId': userId, // Store the userId in the booking
        });

        // Show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Booking Successful!')),
        );
        Navigator.pop(context); // Return to the homepage after submission
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to book service: $e')),
        );
      }
    }
  }

  // Function to fetch the provider ID from Firestore based on the provider's name
  Future<String> getProviderId(String providerName) async {
    print('Searching for provider with name: ${providerName.trim()}');
    QuerySnapshot providerSnapshot = await FirebaseFirestore.instance
        .collection('providers')
        .where('providerName', isEqualTo: providerName.trim()) // Trim to avoid space issues
        .get();

    if (providerSnapshot.docs.isNotEmpty) {
      print('Found provider: ${providerSnapshot.docs.first.data()}');
      return providerSnapshot.docs.first.id;
    } else {
      print('Provider not found');
      throw Exception('Provider not found');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Book Service')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _userNameController,
                decoration: InputDecoration(labelText: 'Your Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _userPhoneController,
                decoration: InputDecoration(labelText: 'Your Phone Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _dateController,
                decoration: InputDecoration(labelText: 'Booking Date'),
                onTap: () async {
                  FocusScope.of(context).requestFocus(FocusNode()); // Close the keyboard
                  DateTime? selectedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2101),
                  );
                  if (selectedDate != null) {
                    _dateController.text = selectedDate.toLocal().toString().split(' ')[0];
                  }
                },
              ),
              TextFormField(
                controller: _timeController,
                decoration: InputDecoration(labelText: 'Booking Time'),
                onTap: () async {
                  FocusScope.of(context).requestFocus(FocusNode()); // Close the keyboard
                  TimeOfDay? selectedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (selectedTime != null) {
                    _timeController.text = selectedTime.format(context);
                  }
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitBooking,
                child: Text('Book Now'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
