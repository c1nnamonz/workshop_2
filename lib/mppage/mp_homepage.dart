import 'package:flutter/material.dart';
import 'package:projects/auth/auth_service.dart';
import 'package:projects/auth/login_screen.dart';
import 'package:projects/mppage/profile_page.dart'; // Adjust path if necessary
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
      _buildDashboard(),
      BookingPage(), // BookingPage widget
      const Center(child: Text('Inbox Page')), // Placeholder for Inbox
      const Center(child: Text('Chat Page')), // Placeholder for Chat
      MaintenanceProviderProfilePage(), // Correct reference to ProfilePage widget
    ];
  }


  Widget _buildDashboard() {
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
            value: '120', // Replace with dynamic data
            icon: Icons.calendar_today,
            color: Colors.blue,
          ),
          _buildDashboardItem(
            title: 'Services Completed',
            value: '95', // Replace with dynamic data
            icon: Icons.check_circle_outline,
            color: Colors.green,
          ),
          _buildDashboardItem(
            title: 'Total Sales',
            value: '\$7,500', // Replace with dynamic data
            icon: Icons.monetization_on,
            color: Colors.orange,
          ),
        ],
      ),
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
