import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SalesPage extends StatefulWidget {
  @override
  _SalesPageState createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  late Future<Map<String, dynamic>> _salesDataFuture;

  Future<Map<String, dynamic>> _fetchSalesData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return {'totalSales': 0.0, 'monthlyTotals': <String, double>{}, 'completedServices': []};
    }

    final providerId = user.uid;
    try {
      final completedSnapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .where('providerId', isEqualTo: providerId)
          .where('status', isEqualTo: 'Completed')
          .get();

      double totalSales = 0.0;
      Map<String, double> monthlyTotals = {};
      List<Map<String, dynamic>> completedServices = [];

      for (var doc in completedSnapshot.docs) {
        final data = doc.data();

        if (data['Final Price'] != null && data['bookingDate'] != null && data['userId'] != null) {
          double finalPrice = double.tryParse(data['Final Price'].toString()) ?? 0.0;
          DateTime bookingDate;

          try {
            bookingDate = DateTime.parse(data['bookingDate']);
          } catch (e) {
            print("Invalid bookingDate format: ${data['bookingDate']}");
            continue; // Skip this document
          }

          totalSales += finalPrice;
          String month = DateFormat('MMMM yyyy').format(bookingDate);
          monthlyTotals[month] = (monthlyTotals[month] ?? 0.0) + finalPrice;

          // Fetch customer details
          final userSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(data['userId'])
              .get();
          String firstname = userSnapshot.data()?['firstName'] ?? 'Unknown';
          String lastname = userSnapshot.data()?['lastName'] ?? 'Unknown';

          completedServices.add({
            'firstname': firstname,
            'lastname': lastname,
            'Service': data['serviceName'],
            'Amount': finalPrice,
            'Date': data['bookingDate'],
          });
        } else {
          print("Missing required fields for document: ${doc.id}");
          continue; // Skip this document
        }
      }

      return {
        'totalSales': totalSales,
        'monthlyTotals': monthlyTotals,
        'completedServices': completedServices,
      };
    } catch (e) {
      print("Error fetching sales data: $e");
      return {'totalSales': 0.0, 'monthlyTotals': <String, double>{}, 'completedServices': []};
    }
  }

  @override
  void initState() {
    super.initState();
    _salesDataFuture = _fetchSalesData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sales Page')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _salesDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Error fetching sales data.'));
          }

          final data = snapshot.data!;
          final double totalSales = data['totalSales'];
          final Map<String, double> monthlyTotals = data['monthlyTotals'];
          final List<Map<String, dynamic>> completedServices = data['completedServices'];

          return ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  'Total Sales: \$${totalSales.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orange),
                ),
              ),
              for (var month in monthlyTotals.keys)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        month,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    ...completedServices
                        .where((service) =>
                    DateFormat('MMMM yyyy').format(
                        DateTime.parse(service['Date'])) ==
                        month)
                        .map((service) => Card(
                      child: ListTile(
                        title: Text(
                            '${service['firstname']} ${service['lastname']}'),
                        subtitle: Text(
                            'Service: ${service['Service']}\nAmount: \$${service['Amount'].toStringAsFixed(2)}\nDate: ${service['Date']}'),
                      ),
                    )),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        'Total for $month: \$${monthlyTotals[month]!.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}
