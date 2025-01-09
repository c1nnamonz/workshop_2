import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PaymentScreen extends StatefulWidget {
  final String bookingId;
  final String userId;
  final String providerId;
  final String finalPrice;

  PaymentScreen({
    required this.bookingId,
    required this.userId,
    required this.providerId,
    required this.finalPrice,
  });

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String selectedPaymentType = 'Credit Card';
  String? selectedBank;
  final List<String> banks = ['Bank Islam', 'Maybank', 'CIMB', 'RHB', 'Public Bank'];
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController cardExpiryController = TextEditingController();
  final TextEditingController cardCVVController = TextEditingController();
  bool isSubmitting = false;

  Future<void> submitPayment() async {
    if (selectedPaymentType == 'Credit Card' &&
        (cardNumberController.text.isEmpty || cardExpiryController.text.isEmpty || cardCVVController.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all credit card details')));
      return;
    }

    if (selectedPaymentType == 'FPX' && selectedBank == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a bank')));
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      // Add payment details to the Firebase 'payments' collection
      await FirebaseFirestore.instance.collection('payments').add({
        'bookingId': widget.bookingId,
        'userId': widget.userId,
        'providerId': widget.providerId,
        'finalPrice': widget.finalPrice,
        'paymentType': selectedPaymentType,
        'bank': selectedPaymentType == 'FPX' ? selectedBank : null,
        'cardNumber': selectedPaymentType == 'Credit Card' ? cardNumberController.text : null,
        'paymentStatus': 'Paid', // Mark payment as paid
        'createdAt': Timestamp.now(),
      });

      // Update the booking status to 'Completed' in the Firebase 'bookings' collection
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(widget.bookingId)
          .update({'status': 'Completed'});

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment successful!')));

      Navigator.pop(context); // Navigate back to the previous screen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Make Payment'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Final Price: RM${widget.finalPrice}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text('Select Payment Type', style: TextStyle(fontSize: 16)),
            DropdownButton<String>(
              value: selectedPaymentType,
              items: ['Credit Card', 'FPX']
                  .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedPaymentType = value!;
                  selectedBank = null; // Reset selected bank for FPX
                });
              },
            ),
            if (selectedPaymentType == 'Credit Card') ...[
              const SizedBox(height: 20),
              const Text('Credit Card Details', style: TextStyle(fontSize: 16)),
              TextField(
                controller: cardNumberController,
                decoration: const InputDecoration(labelText: 'Card Number'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: cardExpiryController,
                decoration: const InputDecoration(labelText: 'Expiry Date (MM/YY)'),
              ),
              TextField(
                controller: cardCVVController,
                decoration: const InputDecoration(labelText: 'CVV'),
                keyboardType: TextInputType.number,
              ),
            ],
            if (selectedPaymentType == 'FPX') ...[
              const SizedBox(height: 20),
              const Text('Select Bank', style: TextStyle(fontSize: 16)),
              DropdownButton<String>(
                value: selectedBank,
                items: banks
                    .map((bank) => DropdownMenuItem(value: bank, child: Text(bank)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedBank = value!;
                  });
                },
              ),
            ],
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: isSubmitting ? null : submitPayment,
                child: isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Submit Payment'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
