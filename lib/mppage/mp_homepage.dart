import 'package:flutter/material.dart';
import 'package:projects/auth/auth_service.dart';
import 'package:projects/auth/login_screen.dart';
import 'package:projects/mppage/OngoingBookings.dart';
import 'package:projects/mppage/profile_page.dart';
import 'package:projects/widgets/BookingPage.dart';
import 'package:projects/mppage/CompletedServicesPage.dart';
import 'package:projects/mppage/SalesPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MaintenanceProviderHomePage extends StatefulWidget {
  const MaintenanceProviderHomePage({super.key});

  @override
  State<MaintenanceProviderHomePage> createState() =>
      _MaintenanceProviderHomePageState();
}

class _MaintenanceProviderHomePageState
    extends State<MaintenanceProviderHomePage> {
  int _selectedIndex = 0;
  late List<Widget> _pages;
  final SalesPage salesPage = SalesPage();

  @override
  void initState() {
    super.initState();
    _pages = [
      _buildDashboard(),
      BookingPage(),
      const Center(child: Text('Inbox Page')),
      const Center(child: Text('Chat Page')),
      MaintenanceProviderProfilePage(),
    ];
  }

  Future<Map<String, int>> _fetchCounts() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final providerId = user.uid;

      // Count Ongoing Bookings
      final ongoingSnapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .where('providerId', isEqualTo: providerId)
          .where('status', isEqualTo: 'Ongoing')
          .get();

      // Count Completed Services
      final completedSnapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .where('providerId', isEqualTo: providerId)
          .where('status', isEqualTo: 'Completed')
          .get();

      return {
        'ongoing': ongoingSnapshot.docs.length,
        'completed': completedSnapshot.docs.length,
      };
    }

    return {'ongoing': 0, 'completed': 0};
  }

  Widget _buildDashboard() {
    double totalSales = salesPage.getTotalSales(); // Retrieve the total sales dynamically
    return FutureBuilder<Map<String, int>>(
      future: _fetchCounts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || snapshot.data == null) {
          return const Center(child: Text('Error fetching counts.'));
        }

        final counts = snapshot.data!;
        final totalOngoingBookings = counts['ongoing'] ?? 0;
        final totalCompletedServices = counts['completed'] ?? 0;

        return Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("images/mppage_bg4.png"), // Background image
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dashboard',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black45),
                ),
                const SizedBox(height: 20),
                _buildDashboardItem(
                  title: 'Total Bookings',
                  value: totalOngoingBookings.toString(),
                  icon: Icons.calendar_today,
                  color: Colors.blue,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            OngoingBookingsPage(bookings: []), // Update logic
                      ),
                    );
                  },
                ),
                _buildDashboardItem(
                  title: 'Services Completed',
                  value: totalCompletedServices.toString(),
                  icon: Icons.check_circle_outline,
                  color: Colors.green,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CompletedServicesPage()),
                    );
                  },
                ),
                _buildDashboardItem(
                  title: 'Total Sales',
                  value: '\$${totalSales.toStringAsFixed(2)}',
                  icon: Icons.monetization_on,
                  color: Colors.orange,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SalesPage()),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDashboardItem({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: color.withOpacity(0.2),
                    child: Icon(icon, color: color),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(fontSize: 16, color: Colors.grey)),
                      const SizedBox(height: 8),
                      Text(value,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              const Icon(Icons.arrow_forward, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout(BuildContext context) async {
    await AuthService().signout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maintenance Provider Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Bookings'),
          BottomNavigationBarItem(icon: Icon(Icons.mail), label: 'Inbox'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}
