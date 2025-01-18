import 'package:flutter/material.dart';
import 'package:projects/auth/auth_service.dart';
import 'package:projects/auth/login_screen.dart';
import 'package:projects/mppage/OngoingBookings.dart';
import 'package:projects/mppage/profile_page.dart';
import 'package:projects/widgets/BookingPage.dart';
import 'package:projects/mppage/CompletedServicesPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:table_calendar/table_calendar.dart';

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
  String _ownerName = "";
  Map<DateTime, List<String>> _bookingsByDate = {};

  @override
  void initState() {
    super.initState();
    _fetchOwnerName();
    _fetchOngoingBookings();
    _pages = [
      _buildDashboard(),
      BookingPage(),
      const Center(child: Text('Inbox Page')),
      const Center(child: Text('Chat Page')),
      MaintenanceProviderProfilePage(),
    ];
  }

  Future<void> _fetchOwnerName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        setState(() {
          _ownerName = doc.data()?['ownerName'] ?? "";
        });
      }
    }
  }

  Future<void> _fetchOngoingBookings() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final providerId = user.uid;
      final ongoingSnapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .where('providerId', isEqualTo: providerId)
          .where('status', isEqualTo: 'Ongoing')
          .get();

      Map<DateTime, List<String>> bookings = {};

      for (var doc in ongoingSnapshot.docs) {
        final data = doc.data();
        if (data['bookingDate'] != null) {
          DateTime date = DateTime.parse(data['bookingDate']);
          DateTime dateOnly = DateTime(date.year, date.month, date.day); // Strip time
          bookings[dateOnly] = bookings[dateOnly] ?? [];
          bookings[dateOnly]?.add(data['serviceName'] ?? 'Ongoing Booking');
        }
      }

      setState(() {
        _bookingsByDate = bookings;
      });
    }
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

  Future<double> _fetchTotalSales() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return 0.0;
    }

    final providerId = user.uid;
    final completedSnapshot = await FirebaseFirestore.instance
        .collection('bookings')
        .where('providerId', isEqualTo: providerId)
        .where('status', isEqualTo: 'Completed')
        .get();

    double totalSales = 0.0;

    for (var doc in completedSnapshot.docs) {
      final data = doc.data();
      if (data['Final Price'] != null) {
        totalSales += double.tryParse(data['Final Price'].toString()) ?? 0.0;
      }
    }

    return totalSales;
  }

  Widget _buildDashboard() {
    return FutureBuilder<Map<String, dynamic>>(
      future: Future.wait([
        _fetchCounts(),
        _fetchTotalSales()
      ]).then((results) => {
        'counts': results[0],
        'totalSales': results[1],
      }),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || snapshot.data == null) {
          return const Center(child: Text('Error fetching data.'));
        }

        final counts = snapshot.data!['counts'] as Map<String, int>;
        final totalSales = snapshot.data!['totalSales'] as double;
        final totalOngoingBookings = counts['ongoing'] ?? 0;
        final totalCompletedServices = counts['completed'] ?? 0;

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeBox(_ownerName),
                const SizedBox(height: 20),
                _buildTotalSalesBox(totalSales),
                const SizedBox(height: 20),
                const Text(
                  'Dashboard',
                  style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      color: Colors.black45),
                ),
                const SizedBox(height: 20),
                _buildDashboardItem(
                  title: 'Ongoing Bookings',
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
                  title: 'Completed Services',
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
                const SizedBox(height: 20),
                _buildCalendar(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeBox(String ownerName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Welcome',
          style: TextStyle(
            fontSize: 13,

            color: Colors.black,
          ),
        ),
        Text(
          ownerName,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildTotalSalesBox(double totalSales) {
    return Container(
      width: double.infinity, // Full width of the screen
      height: 150, // Fixed height for a rectangle shape
      padding: const EdgeInsets.all(16), // Adjust padding as needed
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.8),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Total Sales',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '\$${totalSales.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 50,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
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

  Widget _buildCalendar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: DateTime.now(),
        eventLoader: (day) {
          // Fetch events for the day
          DateTime dateOnly = DateTime(day.year, day.month, day.day); // Strip time
          return _bookingsByDate[dateOnly] ?? [];
        },
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: Colors.orangeAccent,
            shape: BoxShape.circle,
          ),
          outsideDaysVisible: false, // Hide non-month days
        ),
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, date, _) {
            // Highlight ongoing booking dates
            DateTime dateOnly = DateTime(date.year, date.month, date.day);
            if (_bookingsByDate.containsKey(dateOnly)) {
              return Container(
                margin: const EdgeInsets.all(6.0),
                decoration: BoxDecoration(
                  color: Colors.blue, // Highlight in blue
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${date.day}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              );
            }
            // Default styling for other dates
            return null;
          },
          todayBuilder: (context, date, _) {
            return Container(
              margin: const EdgeInsets.all(6.0),
              decoration: const BoxDecoration(
                color: Colors.orange, // Highlight today in orange
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '${date.day}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            );
          },
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
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/mppage_bg4.png"), // Background image
            fit: BoxFit.cover,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
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
        ),
      ),
    );
  }
}
