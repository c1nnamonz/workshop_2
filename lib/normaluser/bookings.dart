import 'package:flutter/material.dart';

class BookingCard extends StatelessWidget {
  final String serviceName;
  final String problemDescription;
  final String scheduleOrCompletion;
  final String? rating; // Optional for "Completed" tab
  final String? price; // Optional for "Completed" tab
  final IconData icon; // New parameter for the icon
  final Color? iconColor; // Optional for the icon color

  BookingCard({
    required this.serviceName,
    required this.problemDescription,
    required this.scheduleOrCompletion,
    this.rating,
    this.price,
    required this.icon, // Required for the icon
    this.iconColor, // Optional for custom icon color
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row for icon and service name
            Row(
              children: [
                Icon(icon, size: 30, color: iconColor ?? Colors.blue),
                const SizedBox(width: 10), // Space between icon and text
                Text(
                  serviceName,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              problemDescription,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            const SizedBox(height: 5),
            Text(
              scheduleOrCompletion,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            if (rating != null) ...[
              const SizedBox(height: 8),
              Text(
                rating!,
                style: TextStyle(fontSize: 14, color: Colors.orange[700]),
              ),
            ],
            if (price != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  price!,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class BookingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Dummy data for the "Booked" tab
    final bookedServices = [
      {
        'serviceName': "HomeFix Repairs",
        'problemDescription': "Air-conditioner servicing",
        'schedule': "Scheduled on: 2024-12-22, 11:00 AM",
      },
      {
        'serviceName': "Sparkle Cleaners",
        'problemDescription': "Kitchen deep cleaning",
        'schedule': "Scheduled on: 2024-12-23, 9:00 AM",
      },
    ];

    // Dummy data for the "Pending" tab
    final pendingServices = [];

    // Dummy data for the "Completed" tab
    final completedServices = [
      {
        'serviceName': "John's Plumbing",
        'problemDescription': "Pipe leaking",
        'rating': "⭐⭐⭐⭐",
        'completionDate': "Completed on: 2024-12-20, 3:00 PM",
        'price': "RM57",
      },
      {
        'serviceName': "CleanPro Cleaning",
        'problemDescription': "Full home cleaning",
        'rating': "⭐⭐⭐⭐⭐",
        'completionDate': "Completed on: 2024-12-18, 10:00 AM",
        'price': "RM120",
      },
    ];

    // Dummy data for canceled services
    final canceledServices = [
      {
        'serviceName': "QuickFix Electrical",
        'problemDescription': "Wiring installation canceled",
        'completionDate': "Canceled on: 2024-12-19, 12:00 PM",
      },
    ];

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          flexibleSpace: SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 16.0),
                  Text(
                    'Booked Services',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            // TabBar wrapped in a styled container
            Container(
              color: Colors.grey[200],
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: const TabBar(
                labelColor: Colors.black87,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.black26,
                indicatorWeight: 3.0,
                tabs: [
                  Tab(text: 'Booked'),
                  Tab(text: 'Pending'),
                  Tab(text: 'Completed'),
                ],
              ),
            ),
            // TabBarView for the content
            Expanded(
              child: TabBarView(
                children: [
                  // 'Booked' tab
                  bookedServices.isNotEmpty
                      ? ListView.builder(
                    itemCount: bookedServices.length,
                    itemBuilder: (context, index) {
                      final service = bookedServices[index];
                      return BookingCard(
                        serviceName: service['serviceName']!,
                        problemDescription: service['problemDescription']!,
                        scheduleOrCompletion: service['schedule']!,
                        icon: Icons.calendar_today, // Scheduled icon for Booked tab
                      );
                    },
                  )
                      : const Center(child: Text('No Booked Services')),

                  // 'Pending' tab
                  pendingServices.isNotEmpty
                      ? ListView.builder(
                    itemCount: pendingServices.length,
                    itemBuilder: (context, index) {
                      final service = pendingServices[index];
                      return BookingCard(
                        serviceName: service['serviceName']!,
                        problemDescription: service['problemDescription']!,
                        scheduleOrCompletion: service['schedule']!,
                        icon: Icons.build, // Ongoing icon for Pending tab
                      );
                    },
                  )
                      : const Center(child: Text('No Pending Services')),

                  // 'Completed' tab
                  completedServices.isNotEmpty || canceledServices.isNotEmpty
                      ? ListView(
                    children: [
                      ...completedServices.map((service) => BookingCard(
                        serviceName: service['serviceName']!,
                        problemDescription: service['problemDescription']!,
                        scheduleOrCompletion: service['completionDate']!,
                        rating: service['rating'],
                        price: service['price'],
                        icon: Icons.check_circle, // Checked icon for Completed tab
                      )),
                      ...canceledServices.map((service) => BookingCard(
                        serviceName: service['serviceName']!,
                        problemDescription: service['problemDescription']!,
                        scheduleOrCompletion: service['completionDate']!,
                        icon: Icons.error, // Exclamation icon for canceled services
                        iconColor: Colors.red,
                      )),
                    ],
                  )
                      : const Center(child: Text('No Completed Services')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
