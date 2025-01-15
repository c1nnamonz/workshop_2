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
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: const Row(
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
              const SizedBox(width: 10),
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
    final userId = currentUser?.uid ?? '';

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('chats')
          .where('senderId', isEqualTo: userId) // Fetch messages where the current user is the sender
          .orderBy('timestamp', descending: true) // Order by timestamp to get the latest messages first
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var chats = snapshot.data!.docs;

        Map<String, QueryDocumentSnapshot> latestMessages = {};
        for (var chat in chats) {
          String receiverId = chat['receiverId'];
          String chatKey = _generateChatKey(userId, receiverId);

          if (!latestMessages.containsKey(chatKey)) {
            latestMessages[chatKey] = chat;
          }
        }

        return FutureBuilder<List<Map<String, dynamic>>>(
          future: _fetchUserDetailsForChats(latestMessages.values.toList()),
          builder: (context, userDetailsSnapshot) {
            if (userDetailsSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (userDetailsSnapshot.hasError) {
              return const Center(child: Text('Error fetching user details'));
            }

            List<Map<String, dynamic>> userDetails = userDetailsSnapshot.data ?? [];

            return ListView.builder(
              itemCount: latestMessages.length,
              itemBuilder: (context, index) {
                var chat = latestMessages.values.toList()[index];
                var userDetail = userDetails[index];

                String receiverName = userDetail['receiverName'] ?? 'Unknown Company';
                String profileImageUrl = userDetail['profileImageUrl'] ?? '';
                String messagePreview = chat['message'];

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: profileImageUrl.isNotEmpty
                        ? NetworkImage(profileImageUrl)
                        : AssetImage('assets/default_avatar.png') as ImageProvider,
                    radius: 25,
                  ),
                  title: Text(
                    receiverName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    messagePreview,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          providerId: chat['receiverId'],
                          userId: userId,
                          otherUserName: receiverName,
                          otherUserId: chat['receiverId'],
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

  Future<List<Map<String, dynamic>>> _fetchUserDetailsForChats(List<QueryDocumentSnapshot> chats) async {
    List<Map<String, dynamic>> userDetails = [];

    for (var chat in chats) {
      String receiverId = chat['receiverId'];

      try {
        DocumentSnapshot receiverDoc = await _firestore.collection('users').doc(receiverId).get();
        if (receiverDoc.exists) {
          String companyName = receiverDoc['companyName'] ?? 'Unknown Company';
          String profileImageUrl = receiverDoc['profileImageUrl'] ?? '';

          userDetails.add({
            'receiverName': companyName,
            'profileImageUrl': profileImageUrl,
          });
        } else {
          userDetails.add({
            'receiverName': 'Unknown Company',
            'profileImageUrl': '',
          });
        }
      } catch (e) {
        userDetails.add({
          'receiverName': 'Error loading name',
          'profileImageUrl': '',
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
      leading: const Icon(Icons.notifications, color: Colors.green),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      subtitle: Text(
        message,
        style: TextStyle(color: Colors.grey[700], fontSize: 14),
      ),
      trailing: Text(
        time,
        style: const TextStyle(color: Colors.grey, fontSize: 12),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      dense: true,
    );
  }

  String _generateChatKey(String senderId, String receiverId) {
    List<String> ids = [senderId, receiverId];
    ids.sort();
    return ids.join('_');
  }
}
