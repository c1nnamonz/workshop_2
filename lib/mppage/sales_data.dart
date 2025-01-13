// sales_data.dart
import 'package:intl/intl.dart';


class SalesData {
  static final List<Map<String, dynamic>> salesData = [
    {'Service': 'Plumbing', 'Amount': 100.0, 'Date': '2025-01-10'},
    {'Service': 'Electrical Repair', 'Amount': 150.0, 'Date': '2025-01-15'},
    {'Service': 'Carpentry', 'Amount': 120.0, 'Date': '2025-02-05'},
    {'Service': 'Painting', 'Amount': 200.0, 'Date': '2025-02-18'},
    {'Service': 'HVAC Repair', 'Amount': 250.0, 'Date': '2025-03-10'},
  ];

  // Function to calculate total sales
  static double calculateTotalSales() {
    return salesData.fold(0.0, (sum, sale) => sum + sale['Amount']);
  }

  // Function to group sales by month with totals
  static Map<String, double> getMonthlyTotals() {
    Map<String, double> monthlyTotals = {};
    for (var sale in salesData) {
      DateTime date = DateTime.parse(sale['Date']);
      String month = DateFormat('MMMM yyyy').format(date);
      monthlyTotals[month] = (monthlyTotals[month] ?? 0) + sale['Amount'];
    }
    return monthlyTotals;
  }
}
