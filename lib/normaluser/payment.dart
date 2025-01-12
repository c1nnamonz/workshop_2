import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PaymentScreen extends StatefulWidget {
  final String bookingId;
  final String userId;
  final String providerId;
  final String finalPrice;

  const PaymentScreen({
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
  final List<Map<String, String>> banks = [
    {'name': 'Bank Islam', 'logo': 'images/bank_islam.png'},
    {'name': 'Maybank', 'logo': 'images/maybank.png'},
    {'name': 'CIMB', 'logo': 'images/cimb.png'},
    {'name': 'RHB', 'logo': 'images/rhb.png'},
    {'name': 'Public Bank', 'logo': 'images/public_bank.png'},
  ];
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController cardExpiryController = TextEditingController();
  final TextEditingController cardCVVController = TextEditingController();
  bool isSubmitting = false;

  Future<void> submitPayment() async {
    if (selectedPaymentType == 'Credit Card' &&
        (cardNumberController.text.isEmpty ||
            cardExpiryController.text.isEmpty ||
            cardCVVController.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all credit card details')),
      );
      return;
    }

    if (selectedPaymentType == 'FPX' && selectedBank == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a bank')),
      );
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment successful!')),
      );

      Navigator.pop(context); // Navigate back to the previous screen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
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
        elevation: 2.0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Final Price: RM${widget.finalPrice}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Select Payment Type',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 10),
              DropdownButton<String>(
                value: selectedPaymentType,
                items: ['Credit Card', 'FPX']
                    .map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(
                    type,
                    style: const TextStyle(fontSize: 16),
                  ),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedPaymentType = value!;
                    selectedBank = null; // Reset selected bank for FPX
                  });
                },
                isExpanded: true,
              ),
              if (selectedPaymentType == 'Credit Card') ...[
                const SizedBox(height: 20),
                const Text(
                  'Credit Card Details',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  controller: cardNumberController,
                  labelText: 'Card Number',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  controller: cardExpiryController,
                  labelText: 'Expiry Date (MM/YY)',
                  keyboardType: TextInputType.datetime,
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  controller: cardCVVController,
                  labelText: 'CVV',
                  keyboardType: TextInputType.number,
                ),
              ],
              if (selectedPaymentType == 'FPX') ...[
                const SizedBox(height: 20),
                const Text(
                  'Select Bank',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 10),
                DropdownButton<String>(
                  value: selectedBank,
                  items: banks
                      .map((bank) => DropdownMenuItem<String>(
                    value: bank['name'],
                    child: Row(
                      children: [
                        Image.asset(
                          bank['logo']!,
                          width: 30, // Adjust the size as needed
                          height: 30,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          bank['name']!,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedBank = value!;
                    });
                  },
                  isExpanded: true,
                ),
              ],
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : submitPayment,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(200, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: isSubmitting
                      ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                      : const Text(
                    'Submit Payment',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required TextInputType keyboardType,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      ),
      keyboardType: keyboardType,
    );
  }
}
