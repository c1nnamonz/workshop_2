import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookingForm extends StatefulWidget {
  final String providerId;
  final String providerName;
  final String serviceType;
  final String serviceName;
  final String rangePrice;
  final String location;

  const BookingForm({
    Key? key,
    required this.providerId,
    required this.providerName,
    required this.serviceType,
    required this.serviceName,
    required this.rangePrice,
    required this.location,
  }) : super(key: key);

  @override
  _BookingFormState createState() => _BookingFormState();
}

class _BookingFormState extends State<BookingForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _userPhoneController = TextEditingController();

  void _submitBooking() async {
    if (_formKey.currentState!.validate()) {
      try {
        String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
        await FirebaseFirestore.instance.collection('bookings').add({
          'providerId': widget.providerId,
          'providerName': widget.providerName,
          'serviceType': widget.serviceType,
          'serviceName': widget.serviceName,
          'price': widget.rangePrice,
          'location': widget.location,
          'bookingDate': _dateController.text,
          'bookingTime': _timeController.text,
          'userName': _userNameController.text,
          'userPhone': _userPhoneController.text,
          'status': 'Pending',
          'userId': userId,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking Successful!')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to book service: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Book ${widget.serviceName}')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _userNameController,
                decoration: const InputDecoration(labelText: 'Your Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _userPhoneController,
                decoration: const InputDecoration(labelText: 'Your Phone Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(labelText: 'Booking Date'),
                onTap: () async {
                  FocusScope.of(context).requestFocus(FocusNode());
                  DateTime? selectedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2101),
                  );
                  if (selectedDate != null) {
                    _dateController.text = selectedDate.toLocal().toString().split(' ')[0];
                  }
                },
              ),
              TextFormField(
                controller: _timeController,
                decoration: const InputDecoration(labelText: 'Booking Time'),
                onTap: () async {
                  FocusScope.of(context).requestFocus(FocusNode());
                  TimeOfDay? selectedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (selectedTime != null) {
                    _timeController.text = selectedTime.format(context);
                  }
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitBooking,
                child: const Text('Book Now'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
