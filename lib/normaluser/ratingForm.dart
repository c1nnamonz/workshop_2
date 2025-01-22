import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RatingForm extends StatefulWidget {
  final String bookingId;

  RatingForm({required this.bookingId});

  @override
  _RatingFormState createState() => _RatingFormState();
}

class _RatingFormState extends State<RatingForm> {
  double _rating = 1.0;
  String _comment = '';
  bool _isLoading = false; // To show loading indicator while submitting
  String _serviceId = ''; // To store the serviceId

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to submit rating and comment to Firebase
  Future<void> _submitRating() async {
    setState(() {
      _isLoading = true; // Start loading
    });

    try {
      // Get serviceId from bookings collection using bookingId
      DocumentSnapshot bookingSnapshot = await _firestore
          .collection('bookings')
          .doc(widget.bookingId)
          .get();

      if (bookingSnapshot.exists) {
        // Retrieve the serviceId from the booking document
        _serviceId = bookingSnapshot['serviceId'];

        // Submit the rating, comment, serviceId, and other details to the ratings collection
        await _firestore.collection('ratings').doc(widget.bookingId).set({
          'rating': _rating,
          'comment': _comment,
          'bookingId': widget.bookingId,
          'serviceId': _serviceId, // Add the serviceId
          'timestamp': FieldValue.serverTimestamp(),
        });

        // Calculate the average rating for the service
        QuerySnapshot ratingSnapshot = await _firestore
            .collection('ratings')
            .where('serviceId', isEqualTo: _serviceId)
            .get();

        if (ratingSnapshot.docs.isNotEmpty) {
          double totalRating = 0.0;

          for (var doc in ratingSnapshot.docs) {
            totalRating += doc['rating'];
          }

          double averageRating = totalRating / ratingSnapshot.docs.length;

          // Update the average rating in the services collection
          await _firestore.collection('services').doc(_serviceId).update({
            'rating': averageRating,
          });


          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Rating and comment submitted successfully! Average rating updated.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Booking not found!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit rating and comment: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Stop loading
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rate This Service', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rate the service (0.0 to 5.0):',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),
            ),
            const SizedBox(height: 10),
            // Rating Bar
            RatingBar.builder(
              initialRating: _rating,
              minRating: 0.5,
              itemSize: 40.0,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                setState(() {
                  _rating = rating;
                });
              },
              allowHalfRating: true,
            ),
            Text(
              'Rating: ${_rating.toStringAsFixed(1)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black54),
            ),
            const SizedBox(height: 20),
            // Comment Section
            const Text(
              'Leave your comment:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            TextField(
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Enter your feedback...',
                hintStyle: TextStyle(color: Colors.grey[600]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(12),
              ),
              onChanged: (value) {
                setState(() {
                  _comment = value;
                });
              },
            ),
            const SizedBox(height: 20),
            // Submit Button
            Center(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitRating,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(
                  color: Colors.white,
                )
                    : const Text(
                  'Submit',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
