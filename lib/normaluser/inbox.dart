import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:projects/normaluser/Chatscreen.dart';

class InboxPage extends StatefulWidget {
  @override
  _InboxPageState createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  bool isChatsSelected = false;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _setupFirebaseMessaging();
    _listenForNewMessages();
    _updateLastSeenTimestamp(); // Update last seen timestamp when the page loads
  }

  @override
  void dispose() {
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
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
    DateTime lastSeenTimestamp = userDoc['lastSeenTimestamp']?.toDate() ?? DateTime(1970);

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
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
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
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        flexibleSpace: SafeArea(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
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
                  backgroundColor:
                  isChatsSelected ? Colors.grey[300] : Colors.orangeAccent,
                ),
                child: Text(
                  'Notifications',
                  style: TextStyle(
                    color: isChatsSelected ? Colors.black : Colors.white,
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
                  backgroundColor:
                  isChatsSelected ? Colors.orangeAccent : Colors.grey[300],
                ),
                child: Text(
                  'Chats',
                  style: TextStyle(
                    color: isChatsSelected ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: isChatsSelected
                ? _buildChatsSection()
                : _buildNotificationsSection(),
          ),
        ],
      ),
    );
  }

  Widget _buildChatsSection() {
    final currentUser = _auth.currentUser;
    final userId = currentUser?.uid ?? '';

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('chats')
          .where('receiverId', isEqualTo: userId)
          .orderBy('timestamp', descending: true) // Show all messages, regardless of seen status
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        var chats = snapshot.data!.docs;

        chats = chats.where((chat) {
          String senderId = chat['senderId'];
          String receiverId = chat['receiverId'];
          return senderId == userId || receiverId == userId;
        }).toList();

        Map<String, QueryDocumentSnapshot> latestMessages = {};
        for (var chat in chats) {
          String senderId = chat['senderId'];
          String receiverId = chat['receiverId'];
          String chatKey = _generateChatKey(senderId, receiverId);

          if (!latestMessages.containsKey(chatKey)) {
            latestMessages[chatKey] = chat;
          }
        }

        return FutureBuilder<List<Map<String, dynamic>>>(
          future: _fetchUserDetailsForChats(latestMessages.values.toList(), userId),
          builder: (context, userDetailsSnapshot) {
            if (userDetailsSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (userDetailsSnapshot.hasError) {
              return Center(child: Text('Error fetching user details'));
            }

            List<Map<String, dynamic>> userDetails = userDetailsSnapshot.data ?? [];

            return ListView.builder(
              itemCount: latestMessages.length,
              itemBuilder: (context, index) {
                var chat = latestMessages.values.toList()[index];
                var userDetail = userDetails[index];

                String otherUserName = userDetail['otherUserName'] ?? 'Unknown User';
                String otherUserId = userDetail['otherUserId'] ?? '';

                return ListTile(
                  title: Text(otherUserName),
                  subtitle: Text(chat['message']),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          providerId: otherUserId,
                          userId: userId,
                          otherUserName: otherUserName,
                          otherUserId: otherUserId,
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

  Future<List<Map<String, dynamic>>> _fetchUserDetailsForChats(
      List<QueryDocumentSnapshot> chats, String userId) async {
    List<Map<String, dynamic>> userDetails = [];

    for (var chat in chats) {
      String senderId = chat['senderId'];
      String receiverId = chat['receiverId'];

      String otherUserId = senderId == userId ? receiverId : senderId;

      try {
        DocumentSnapshot otherUserDoc =
        await _firestore.collection('users').doc(otherUserId).get();
        if (otherUserDoc.exists) {
          // Fetch companyName or username
          String companyName = otherUserDoc['companyName'] ?? '';
          String username = otherUserDoc['username'] ?? '';
          String otherUserName = companyName.isNotEmpty ? companyName : username;

          userDetails.add({
            'otherUserName': otherUserName,
            'otherUserId': otherUserId,
          });
        } else {
          userDetails.add({
            'otherUserName': 'Unknown User',
            'otherUserId': otherUserId,
          });
        }
      } catch (e) {
        print('Error fetching user details for otherUserId: $otherUserId, error: $e');
        userDetails.add({
          'otherUserName': 'Error loading name',
          'otherUserId': otherUserId,
        });
      }
    }

    return userDetails;
  }

  Widget _buildNotificationsSection() {
    final currentUser = _auth.currentUser;
    final userId = currentUser?.uid ?? '';

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId) // Filter for the current user
          .orderBy('timestamp', descending: true) // Order by timestamp
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        var notifications = snapshot.data!.docs;

        return ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            var notification = notifications[index];
            String title = notification['title'] ?? 'Warning Issued';
            String body = notification['body'] ??
                'You have received a warning for your reported behavior.';
            String time = notification['timestamp'] != null
                ? DateFormat('hh:mm a').format(notification['timestamp'].toDate())
                : 'Unknown Time';

            return _buildNotificationItem(
              title: title,
              message: body,
              time: time,
            );
          },
        );
      },
    );
  }

  Widget _buildNotificationItem({
    required String title,
    required String message,
    required String time,
  }) {
    return ListTile(
      leading: Icon(Icons.notifications, color: Colors.green),
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
      dense: true,
    );
  }

  String _generateChatKey(String senderId, String receiverId) {
    List<String> ids = [senderId, receiverId];
    ids.sort();
    return ids.join('_');
  }
}
