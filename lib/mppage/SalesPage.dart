import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SalesPage extends StatelessWidget {
  final List<Map<String, dynamic>> salesData = [
    {'Service': 'Plumbing', 'Amount': 100.0, 'Date': '2025-01-10'},
    {'Service': 'Electrical Repair', 'Amount': 150.0, 'Date': '2025-01-15'},
    {'Service': 'Carpentry', 'Amount': 120.0, 'Date': '2025-02-05'},
    {'Service': 'Painting', 'Amount': 200.0, 'Date': '2025-02-18'},
    {'Service': 'HVAC Repair', 'Amount': 250.0, 'Date': '2025-03-10'},
  ];

  double getTotalSales() {
    return salesData.fold(0.0, (sum, sale) => sum + sale['Amount']);
  }

  @override
  Widget build(BuildContext context) {
    double totalSales = getTotalSales(); // Total calculated here

    // Group sales by month
    Map<String, double> monthlyTotals = {};
    for (var sale in salesData) {
      DateTime date = DateTime.parse(sale['Date']);
      String month = DateFormat('MMMM yyyy').format(date);
      monthlyTotals[month] = (monthlyTotals[month] ?? 0) + sale['Amount'];
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Sales Page')),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              'Total Sales: \$${totalSales.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orange),
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
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                ...salesData
                    .where((sale) =>
                DateFormat('MMMM yyyy').format(DateTime.parse(sale['Date'])) == month)
                    .map((sale) => Card(
                  child: ListTile(
                    title: Text('Service: ${sale['Service']}'),
                    subtitle: Text('Amount: \$${sale['Amount'].toStringAsFixed(2)}\nDate: ${sale['Date']}'),
                  ),
                )),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    'Total for $month: \$${monthlyTotals[month]!.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
