import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projects/auth/auth_service.dart';
import 'package:projects/auth/login_screen.dart';
import 'package:projects/widgets/MessagesPage.dart';
import 'package:projects/widgets/ProfilePage.dart';
import 'package:projects/widgets/BookingPage.dart';

class MaintenanceProviderHomePage extends StatefulWidget {
  const MaintenanceProviderHomePage({super.key});

  @override
  State<MaintenanceProviderHomePage> createState() =>
      _MaintenanceProviderHomePageState();
}

class _MaintenanceProviderHomePageState
    extends State<MaintenanceProviderHomePage> {
  int _selectedIndex = 0; // Current selected index for BottomNavigationBar

  // List of pages for each BottomNavigationBar item
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      _buildDashboard(), // Updated Dashboard with dynamic data
      BookingPage(),
      const Center(child: Text('Inbox Page')),
      const MessagesPage(),
      const ProfilePage(),
    ];
  }

  Future<Map<String, dynamic>> _fetchDashboardData() async {
    try {
      // Example Firestore collection and document path
      final snapshot = await FirebaseFirestore.instance
          .collection('dashboard')
          .doc('maintenance_provider')
          .get();

      // Return data or fallback values
      return snapshot.data() ?? {
        'totalBookings': 0,
        'servicesCompleted': 0,
        'totalSales': 0.0,
      };
    } catch (e) {
      // Handle errors gracefully and return fallback values
      return {
        'totalBookings': 0,
        'servicesCompleted': 0,
        'totalSales': 0.0,
      };
    }
  }

  Widget _buildDashboard() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchDashboardData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Text('Failed to load dashboard data.'));
        }

        final data = snapshot.data!;
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dashboard',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildDashboardItem(
                title: 'Total Bookings',
                value: data['totalBookings'].toString(),
                icon: Icons.calendar_today,
                color: Colors.blue,
              ),
              _buildDashboardItem(
                title: 'Services Completed',
                value: data['servicesCompleted'].toString(),
                icon: Icons.check_circle_outline,
                color: Colors.green,
              ),
              _buildDashboardItem(
                title: 'Total Sales',
                value: '\$${data['totalSales'].toStringAsFixed(2)}',
                icon: Icons.monetization_on,
                color: Colors.orange,
              ),
            ],
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
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update selected index
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
      body: _pages[_selectedIndex], // Display the selected page
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped, // Handle tap on items
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mail),
            label: 'Inbox',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
