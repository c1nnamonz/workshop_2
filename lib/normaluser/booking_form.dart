import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../auth/firebase_utils.dart';

class BookingForm extends StatefulWidget {
  final String providerId; // The service provider's document ID
  final String serviceName; // The service name
  final String price;
  final String description;
  final String companyName;
  final String location;

  BookingForm({
    required this.providerId,
    required this.serviceName,
    required this.price,
    required this.description,
    required this.companyName,
    required this.location,
  });

  @override
  _BookingFormState createState() => _BookingFormState();
}

class _BookingFormState extends State<BookingForm> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _problemDescriptionController = TextEditingController(); // New controller for Problem Description

  String selectedLocation = 'Select Location';
  LatLng? selectedCoordinates;
  late GoogleMapController _mapController;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _locationController.text = widget.location; // Pre-fill location
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enable location services')),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission is denied')),
          );
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        selectedCoordinates = LatLng(position.latitude, position.longitude);
        selectedLocation =
        'Lat: ${position.latitude}, Lng: ${position.longitude}';
        _locationController.text = selectedLocation;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get location: $e')),
      );
    }
  }

  Future<void> _submitBooking() async {
    String bookingDate = _dateController.text;
    String bookingTime = _timeController.text;
    String location = selectedLocation;
    String problemDescription = _problemDescriptionController.text; // Get Problem Description input

    if (bookingDate.isEmpty ||
        bookingTime.isEmpty ||
        location == 'Select Location' ||
        problemDescription.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    try {
      final userDoc = await FirebaseUtils.getCurrentUserDocument();
      if (userDoc == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to retrieve user information')),
        );
        return;
      }

      String userId = userDoc.id;

      await FirebaseFirestore.instance.collection('bookings').add({
        'userId': userId,
        'providerId': widget.providerId,
        'serviceName': widget.serviceName,
        'price': widget.price,
        'description': widget.description,
        'companyName': widget.companyName,
        'location': location,
        'coordinates': {
          'latitude': selectedCoordinates?.latitude,
          'longitude': selectedCoordinates?.longitude,
        },
        'bookingDate': bookingDate, // Add booking date
        'bookingTime': bookingTime, // Add booking time
        'problemDescription': problemDescription, // Add Problem Description
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'Pending', // Add the status field with value 'Pending'
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking successfully created!')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create booking: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking Form')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 5,
                margin: const EdgeInsets.only(bottom: 20),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.serviceName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.description,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Price: ${widget.price}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Company: ${widget.companyName}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Location: ${widget.location}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              TextField(
                controller: _dateController,
                decoration: const InputDecoration(labelText: 'Booking Date'),
                readOnly: true,
                onTap: () async {
                  DateTime? selectedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (selectedDate != null) {
                    _dateController.text =
                    '${selectedDate.year}-${selectedDate.month}-${selectedDate.day}';
                  }
                },
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _timeController,
                decoration: const InputDecoration(labelText: 'Booking Time'),
                readOnly: true,
                onTap: () async {
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
              GestureDetector(
                onTap: () async {
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      child: Stack(
                        children: [
                          GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: selectedCoordinates ?? const LatLng(2.200844, 102.240143),
                              zoom: 14,
                            ),
                            onMapCreated: (GoogleMapController controller) {
                              _mapController = controller;
                            },
                            onCameraMove: (CameraPosition position) {
                              setState(() {
                                selectedCoordinates = position.target;
                              });
                            },
                          ),
                          const Center(
                            child: Icon(
                              Icons.location_on,
                              size: 40,
                              color: Colors.red,
                            ),
                          ),
                          Positioned(
                            bottom: 20,
                            left: 40,
                            right: 80,
                            child: ElevatedButton(
                              onPressed: () {
                                if (selectedCoordinates != null) {
                                  setState(() {
                                    selectedLocation =
                                    'Lat: ${selectedCoordinates!.latitude}, Lng: ${selectedCoordinates!.longitude}';
                                    _locationController.text = selectedLocation;
                                  });
                                }
                                Navigator.pop(context);
                              },
                              child: const Text('Confirm Location'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: AbsorbPointer(
                  child: TextField(
                    controller: _locationController,
                    decoration: const InputDecoration(labelText: 'Location'),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _problemDescriptionController,
                decoration: const InputDecoration(labelText: 'Problem Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _submitBooking,
                child: const Text('Submit Booking'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

