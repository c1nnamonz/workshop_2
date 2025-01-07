import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'; // For geolocation
import 'package:google_maps_flutter/google_maps_flutter.dart'; // For Google Maps
import '../auth/firebase_utils.dart'; // Import the utility function

class BookingForm extends StatefulWidget {
  final String providerId; // The service provider's document ID
  final String serviceName; // The service name

  BookingForm({required this.providerId, required this.serviceName});

  @override
  _BookingFormState createState() => _BookingFormState();
}

class _BookingFormState extends State<BookingForm> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  String selectedLocation = 'Select Location';
  LatLng? selectedCoordinates; // Store selected coordinates from the map
  late GoogleMapController _mapController; // Map controller

  @override
  void initState() {
    super.initState();
    // Get the current user location using geolocator
    _getCurrentLocation();
  }

  // Method to get the current user's location
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enable location services')),
      );
      return;
    }

    // Check location permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location permission is denied')),
        );
        return;
      }
    }

    // Get current position
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      selectedCoordinates = LatLng(position.latitude, position.longitude);
      selectedLocation =
      'Lat: ${position.latitude}, Lng: ${position.longitude}';
      _locationController.text = selectedLocation; // Show the location in the text field
    });
  }

  // Method to handle map tap and update location
  void _onMapTapped(LatLng latLng) {
    setState(() {
      selectedCoordinates = latLng;
      selectedLocation = 'Lat: ${latLng.latitude}, Lng: ${latLng.longitude}';
      _locationController.text = selectedLocation; // Update text field
    });
  }

  Future<void> _submitBooking() async {
    // Get data from controllers
    String bookingDate = _dateController.text;
    String bookingTime = _timeController.text;
    String location = selectedLocation;

    // Ensure all fields are filled
    if (bookingDate.isEmpty || bookingTime.isEmpty || location == 'Select Location') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    try {
      // Retrieve the current user's document ID using FirebaseUtils
      final userDoc = await FirebaseUtils.getCurrentUserDocument();
      if (userDoc == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to retrieve user information')),
        );
        return;
      }

      String userId = userDoc.id;

      // Ensure providerId is not null or empty
      if (widget.providerId.isEmpty || widget.providerId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Provider ID is missing')),
        );
        return;
      }

      // Save the booking to Firestore
      await FirebaseFirestore.instance.collection('bookings').add({
        'userId': userId, // Current user's document ID
        'providerId': widget.providerId, // Service provider's ID
        'serviceName': widget.serviceName, // Service name
        'bookingDate': bookingDate,
        'bookingTime': bookingTime,
        'location': location,
        'coordinates': {
          'latitude': selectedCoordinates?.latitude,
          'longitude': selectedCoordinates?.longitude
        },
        'createdAt': FieldValue.serverTimestamp(), // Timestamp
      });

      // Show success message and navigate back
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking successfully created!')),
      );

      Navigator.pop(context); // Go back to the previous screen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create booking: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Booking Form')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _dateController,
              decoration: InputDecoration(labelText: 'Booking Date'),
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
            SizedBox(height: 20),
            TextField(
              controller: _timeController,
              decoration: InputDecoration(labelText: 'Booking Time'),
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
            SizedBox(height: 20),
            GestureDetector(
              onTap: () async {
                showDialog(
                  context: context,
                  builder: (context) => Dialog(
                    child: Container(
                      height: 400,
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: selectedCoordinates ?? LatLng(2.200844, 102.240143),
                          zoom: 14,
                        ),
                        onMapCreated: (GoogleMapController controller) {
                          _mapController = controller;
                        },
                        onTap: (LatLng latLng) {
                          setState(() {
                            selectedCoordinates = latLng;
                            selectedLocation = 'Lat: ${latLng.latitude}, Lng: ${latLng.longitude}';
                            _locationController.text = selectedLocation; // Update text field
                          });
                        },
                        markers: {
                          if (selectedCoordinates != null)
                            Marker(
                              markerId: MarkerId('selectedLocation'),
                              position: selectedCoordinates!,
                            )
                        },
                      ),
                    ),
                  ),
                );
              },
              child: AbsorbPointer(
                child: TextField(
                  controller: _locationController,
                  decoration: InputDecoration(labelText: 'Location'),
                ),
              ),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: _submitBooking,
              child: Text('Submit Booking'),
            ),
          ],
        ),
      ),
    );
  }
}