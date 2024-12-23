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

  // Variable to toggle between "Chats" and "Notifications" sections
  bool isChatsSelected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // Removes default back button
        flexibleSpace: SafeArea(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center, // Center-align the text
              children: [
                SizedBox(width: 16.0),
                Text(
                  'Inbox',
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
          // Button to toggle between chats and notifications
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isChatsSelected = false;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isChatsSelected ? Colors.grey[300] : Colors.orangeAccent, // Change color based on selection
                ),
                child: Text(
                  'Notifications',
                  style: TextStyle(
                    color: isChatsSelected ? Colors.black : Colors.white, // Text color based on selection
                  ),
                ),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isChatsSelected = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isChatsSelected ? Colors.orangeAccent : Colors.grey[300], // Change color based on selection
                ),
                child: Text(
                  'Chats',
                  style: TextStyle(
                    color: isChatsSelected ? Colors.white : Colors.black, // Text color based on selection
                  ),
                ),
              ),
            ],
          ),
          // Conditional rendering of sections
          Expanded(
            child: isChatsSelected ? _buildChatsSection() : _buildNotificationsSection(),
          ),
        ],
      ),
    );
  }

  // Dummy chats section (replace with real chat data later)
  Widget _buildChatsSection() {
    return Center(
      child: Text('No chats yet', style: TextStyle(fontSize: 18, color: Colors.grey)),
    );
  }

  // Notifications section (Updated with ListTile for inline display)
  Widget _buildNotificationsSection() {
    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        return _buildNotificationItem(
          title: notifications[index]['title']!,
          message: notifications[index]['message']!,
          time: notifications[index]['time']!,
        );
      },
    );
  }

  // A single notification item
  Widget _buildNotificationItem({required String title, required String message, required String time}) {
    return ListTile(
      leading: Icon(Icons.notifications, color: Colors.green), // Icon for notification
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
      contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      dense: true, // Makes the list item more compact
    );
  }
}
