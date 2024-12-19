import 'package:flutter/material.dart';

class InboxPage extends StatefulWidget {
  @override
  _InboxPageState createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  // Sample data for inbox notifications
  final List<Map<String, String>> notifications = [
    {
      'title': 'Service Request Approved',
      'message': 'Your request for plumbing service has been approved.',
      'time': '10 minutes ago',
    },
    {
      'title': 'New Service Available',
      'message': 'We now offer air conditioning maintenance services.',
      'time': '1 hour ago',
    },
    {
      'title': 'Profile Update Reminder',
      'message': 'Please update your profile to ensure smooth communication.',
      'time': '3 hours ago',
    },
    {
      'title': 'Booking Confirmation',
      'message': 'Your booking for cleaning service has been confirmed.',
      'time': '1 day ago',
    },
    // Add more notifications here
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inbox'),
        backgroundColor: Colors.blue,
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          return NotificationCard(
            title: notifications[index]['title']!,
            message: notifications[index]['message']!,
            time: notifications[index]['time']!,
          );
        },
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final String title;
  final String message;
  final String time;

  NotificationCard({required this.title, required this.message, required this.time});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          message,
          style: TextStyle(color: Colors.grey[700], fontSize: 14),
        ),
        trailing: Text(
          time,
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ),
    );
  }
}
