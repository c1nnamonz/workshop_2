import 'package:flutter/material.dart';
import 'package:projects/auth/auth_service.dart';
import 'package:projects/auth/login_screen.dart';
import 'package:projects/mppage/profile_page.dart';
import 'package:projects/widgets/BookingPage.dart';
import 'package:projects/mppage/CompletedServicesPage.dart';
import 'package:projects/mppage/AcceptedBookingsPage.dart';
import 'package:projects/mppage/SalesPage.dart';

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

  Widget _buildDashboard() {
    double totalSales = salesPage.getTotalSales(); // Retrieve the total sales dynamically
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
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black45),
            ),
            const SizedBox(height: 20),
            _buildDashboardItem(
              title: 'Total Bookings',
              value: '120',
              icon: Icons.calendar_today,
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AcceptedBookingsPage(bookings: [],)),
                );
              },
            ),
            _buildDashboardItem(
              title: 'Services Completed',
              value: '95',
              icon: Icons.check_circle_outline,
              color: Colors.green,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CompletedServicesPage()),
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
                      Text(title, style: const TextStyle(fontSize: 16, color: Colors.grey)),
                      const SizedBox(height: 8),
                      Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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