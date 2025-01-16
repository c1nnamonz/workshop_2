import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // Add this import
import 'package:projects/widgets/ChatPage.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance; // Add this line

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _setupNotifications(); // Call the notification setup function
  }

  // Set up Firebase Messaging
  void _setupNotifications() async {
    // Request permission for notifications (required for iOS)
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission for notifications');

      // Listen for incoming messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Received a new message: ${message.notification?.title}');

        // Show a notification
        _showNotification(
          title: message.notification?.title ?? 'New Message',
          body: message.notification?.body ?? 'You have a new message',
        );
      });
    } else {
      print('User declined or has not accepted notification permissions');
    }
  }

  // Show a notification
  void _showNotification({required String title, required String body}) {
    // Use a package like `flutter_local_notifications` to display notifications
    // Example: https://pub.dev/packages/flutter_local_notifications
    print('Notification: $title - $body');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Ongoing'),
            Tab(text: 'Past'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildChatList(isOngoing: true), // Ongoing Chats
          _buildChatList(isOngoing: false), // Past Chats
        ],
      ),
    );
  }

  Widget _buildChatList({required bool isOngoing}) {
    final currentUser = _auth.currentUser;
    final userId = currentUser?.uid ?? ''; // Get the logged-in user's ID

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('chats')
          .orderBy('timestamp', descending: true) // Order by timestamp to get the latest messages first
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        var chats = snapshot.data!.docs;

        // Filter messages to include only those where the logged-in user is either the sender or the receiver
        chats = chats.where((chat) {
          String senderId = chat['senderId'];
          String receiverId = chat['receiverId'];
          return senderId == userId || receiverId == userId;
        }).toList();

        // Group messages by chat participants (senderId and receiverId)
        Map<String, QueryDocumentSnapshot> latestMessages = {};
        for (var chat in chats) {
          String senderId = chat['senderId'];
          String receiverId = chat['receiverId'];

          // Create a unique key for each chat pair
          String chatKey = _generateChatKey(senderId, receiverId);

          // Store only the latest message for each chat pair
          if (!latestMessages.containsKey(chatKey)) {
            latestMessages[chatKey] = chat;
          }
        }

        return ListView.builder(
          itemCount: latestMessages.length,
          itemBuilder: (context, index) {
            var chat = latestMessages.values.toList()[index];
            String senderId = chat['senderId'];
            String receiverId = chat['receiverId'];

            // Determine the other user's ID (the one who is not the logged-in user)
            String otherUserId = senderId == userId ? receiverId : senderId;

            return FutureBuilder<Map<String, String>>(
              future: _fetchUserDetails(otherUserId),
              builder: (context, userDetailsSnapshot) {
                if (userDetailsSnapshot.connectionState == ConnectionState.waiting) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      child: Text('...'), // Placeholder while loading
                    ),
                    title: Text('Loading...'),
                    subtitle: Text(chat['message']),
                  );
                }

                if (userDetailsSnapshot.hasError) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.red.shade100,
                      child: Text('!'), // Error indicator
                    ),
                    title: Text('Error loading user details'),
                    subtitle: Text(chat['message']),
                  );
                }

                String otherUserName = userDetailsSnapshot.data?['name'] ?? 'Unknown User';

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: Text(otherUserName[0]), // First letter of the other user's name
                  ),
                  title: Text(otherUserName),
                  subtitle: Text(chat['message']),
                  trailing: Text(
                    chat['timestamp'].toDate().toString(),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  onTap: () {
                    // Navigate to ChatPage with providerId and userId
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatPage(
                          providerId: otherUserId,
                          userId: userId,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Future<Map<String, String>> _fetchUserDetails(String userId) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
      String firstName = userDoc['firstName'] ?? '';
      String lastName = userDoc['lastName'] ?? '';
      String name = '$firstName $lastName'.trim(); // Combine first and last name
      if (name.isEmpty) {
        name = 'Unknown User'; // Fallback if both fields are empty
      }
      return {'name': name};
    } catch (e) {
      print('Error fetching user details: $e');
      return {'name': 'Unknown User'};
    }
  }

  // Helper function to generate a unique key for each chat pair
  String _generateChatKey(String senderId, String receiverId) {
    List<String> ids = [senderId, receiverId];
    ids.sort(); // Ensure the key is consistent regardless of sender/receiver order
    return ids.join('_');
  }
}
