import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';

import 'ChatPage.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // Only 2 tabs now
    _initializeNotifications();
    _setupFirebaseMessaging();
    _listenForNewMessages();
    _updateLastSeenTimestamp(); // Update last seen timestamp when the page loads
  }

  @override
  void dispose() {
    _tabController.dispose();
    _updateLastSeenTimestamp(); // Update last seen timestamp when the page is disposed
    super.dispose();
  }

  // Update the user's last seen timestamp in Firestore
  void _updateLastSeenTimestamp() async {
    final currentUser = _auth.currentUser;
    final userId = currentUser?.uid ?? '';

    if (userId.isNotEmpty) {
      await _firestore.collection('users').doc(userId).update({
        'lastSeenTimestamp': DateTime.now(),
      });
    }
  }

  // Initialize local notifications
  void _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: null,
    );

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Set up Firebase Messaging
  void _setupFirebaseMessaging() async {
    // Request permission for notifications (required for iOS)
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission for notifications');

      // Listen for incoming messages while the app is in the foreground
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

  // Listen for new messages in Firestore
  void _listenForNewMessages() async {
    final currentUser = _auth.currentUser;
    final userId = currentUser?.uid ?? '';

    if (userId.isEmpty) return;

    // Fetch the user's last seen timestamp
    DocumentSnapshot userDoc = await _firestore.collection('users')
        .doc(userId)
        .get();
    DateTime lastSeenTimestamp = userDoc['lastSeenTimestamp']?.toDate() ??
        DateTime(1970);

    _firestore
        .collection('chats')
        .where('receiverId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) async {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          var message = change.doc.data() as Map<String, dynamic>;
          DateTime messageTimestamp = message['timestamp'].toDate();

          // Only show notifications for messages after the last seen timestamp
          if (messageTimestamp.isAfter(lastSeenTimestamp)) {
            String senderId = message['senderId'];
            String senderName = await _fetchUserName(senderId);

            _showNotification(
              title: 'New Message from $senderName',
              body: message['message'],
            );
          }
        }
      }
    });
  }

  // Fetch the sender's name from Firestore
  Future<String> _fetchUserName(String userId) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(
          userId).get();
      if (userDoc.exists) {
        String firstName = userDoc['firstName'] ?? '';
        String lastName = userDoc['lastName'] ?? '';
        String fullName = '$firstName $lastName'.trim();
        return fullName.isNotEmpty ? fullName : 'Unknown User';
      }
    } catch (e) {
      print('Error fetching user details: $e');
    }
    return 'Unknown User';
  }

  // Show a local notification
  void _showNotification({required String title, required String body}) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Messages'),
            Tab(text: 'Notifications'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildChatList(),
          _buildNotificationsSection(),
        ],
      ),
    );
  }

  Widget _buildChatList() {
    final currentUser = _auth.currentUser;
    final userId = currentUser?.uid ?? '';

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('chats')
          .where('receiverId',
          isEqualTo: userId) // Fetch chats where the user is the receiver
          .orderBy('timestamp', descending: true) // Order by timestamp
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
                if (userDetailsSnapshot.connectionState ==
                    ConnectionState.waiting) {
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

                String otherUserName = userDetailsSnapshot.data?['name'] ??
                    'Unknown User';

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: Text(
                        otherUserName[0]), // First letter of the other user's name
                  ),
                  title: Text(otherUserName),
                  subtitle: Text(chat['message']),
                  trailing: Text(
                    DateFormat('hh:mm a').format(chat['timestamp'].toDate()),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  onTap: () {
                    // Navigate to ChatPage with providerId and userId
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ChatPage(
                              providerId: otherUserId,
                              userId: userId,
                            ),
                      ),
                    ).then((_) {
                      // Mark messages as seen when the chat screen is popped
                      _markMessagesAsSeen(otherUserId, userId);
                    });
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
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(
          userId).get();
      String firstName = userDoc['firstName'] ?? '';
      String lastName = userDoc['lastName'] ?? '';
      String name = '$firstName $lastName'
          .trim(); // Combine first and last name
      if (name.isEmpty) {
        name = 'Unknown User'; // Fallback if both fields are empty
      }
      return {'name': name};
    } catch (e) {
      print('Error fetching user details: $e');
      return {'name': 'Unknown User'};
    }
  }

  String _generateChatKey(String senderId, String receiverId) {
    List<String> ids = [senderId, receiverId];
    ids
        .sort(); // Ensure the key is consistent regardless of sender/receiver order
    return ids.join('_');
  }

  void _markMessagesAsSeen(String senderId, String receiverId) async {
    await _firestore
        .collection('chats')
        .where('senderId', isEqualTo: senderId)
        .where('receiverId', isEqualTo: receiverId)
        .where('seen', isEqualTo: false)
        .get()
        .then((snapshot) {
      for (var doc in snapshot.docs) {
        doc.reference.update({'seen': true});
      }
    });
  }

  Widget _buildNotificationsSection() {
      final currentUser = _auth.currentUser;
      final userId = currentUser?.uid ?? '';

      return StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('notifications')
            .where('userId',
            isEqualTo: userId) // Fetch notifications for the current user
            .orderBy('timestamp', descending: true) // Order by timestamp
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var notifications = snapshot.data!.docs;

          if (notifications.isEmpty) {
            return Center(child: Text('No notifications available.'));
          }

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              var notification = notifications[index];
              String title = notification['title'];
              String body = notification['body'];
              DateTime timestamp = notification['timestamp'].toDate();

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: Icon(Icons.notifications, color: Colors.blue),
                ),
                title: Text(title),
                subtitle: Text(body),
                trailing: Text(
                  DateFormat('hh:mm a').format(timestamp),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              );
            },
          );
        },
      );
    }
  }
