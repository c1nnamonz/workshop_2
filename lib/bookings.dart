import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'images/fixitLogo.png', // Replace with your actual asset path
              height: 30,
            ),
            SizedBox(width: 10),
            Text(
              'FixIt',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.delete_outline,
              size: 50,
            ),
            SizedBox(height: 10),
            Text(
              'No booked services',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inbox),
            label: 'Inbox',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        selectedItemColor: Colors.green,
      ),
    );
  }
}

class BookingCard extends StatelessWidget {
  final String serviceName;
  final String serviceDate;
  final String serviceTime;

  BookingCard({required this.serviceName, required this.serviceDate, required this.serviceTime});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              serviceName,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              'Date: $serviceDate',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 5),
            Text(
              'Time: $serviceTime',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class BookingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Bookings'),
      ),
      body: ListView(
        children: [
          BookingCard(
            serviceName: 'Plumbing Service',
            serviceDate: '2023-10-15',
            serviceTime: '10:00 AM',
          ),
          BookingCard(
            serviceName: 'Electrical Service',
            serviceDate: '2023-10-16',
            serviceTime: '2:00 PM',
          ),
          BookingCard(
            serviceName: 'Cleaning Service',
            serviceDate: '2023-10-17',
            serviceTime: '1:00 PM',
          ),
        ],
      ),
    );
  }
}