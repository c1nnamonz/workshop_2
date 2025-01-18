import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projects/normaluser/Chatscreen.dart';

class InboxPage extends StatefulWidget {
  @override
  _InboxPageState createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isChatsSelected = false;

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
                  backgroundColor: isChatsSelected ? Colors.grey[300] : Colors.orangeAccent,
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
                  backgroundColor: isChatsSelected ? Colors.orangeAccent : Colors.grey[300],
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
            child: isChatsSelected ? _buildChatsSection() : _buildNotificationsSection(),
          ),
        ],
      ),
    );
  }

  Widget _buildChatsSection() {
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
                  title: Text(otherUserName), // Display full name
                  subtitle: Text(chat['message']), // Display latest message
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

  Future<List<Map<String, dynamic>>> _fetchUserDetailsForChats(List<QueryDocumentSnapshot> chats, String userId) async {
    List<Map<String, dynamic>> userDetails = [];

    for (var chat in chats) {
      String senderId = chat['senderId'];
      String receiverId = chat['receiverId'];

      // Determine the other user's ID (the one who is not the logged-in user)
      String otherUserId = senderId == userId ? receiverId : senderId;

      try {
        DocumentSnapshot otherUserDoc = await _firestore.collection('users').doc(otherUserId).get();
        if (otherUserDoc.exists) {
          String firstName = otherUserDoc['firstName'] ?? '';
          String lastName = otherUserDoc['lastName'] ?? '';
          String otherUserName = '$firstName $lastName'.trim(); // Combine first and last name
          if (otherUserName.isEmpty) {
            otherUserName = 'Unknown User'; // Fallback if both fields are empty
          }

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
        print('Error fetching user details for otherUserId: $otherUserId, error: $e'); // Debug log
        userDetails.add({
          'otherUserName': 'Error loading name',
          'otherUserId': otherUserId,
        });
      }
    }

    return userDetails;
  }

  Widget _buildNotificationsSection() {
    return ListView.builder(
      itemCount: 0, // Replace with actual notifications count
      itemBuilder: (context, index) {
        return _buildNotificationItem(
          title: 'Notification Title',
          message: 'Notification Message',
          time: 'Notification Time',
        );
      },
    );
  }

  Widget _buildNotificationItem(
      {required String title, required String message, required String time}) {
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

  // Helper function to generate a unique key for each chat pair
  String _generateChatKey(String senderId, String receiverId) {
    List<String> ids = [senderId, receiverId];
    ids.sort(); // Ensure the key is consistent regardless of sender/receiver order
    return ids.join('_');
  }
}
