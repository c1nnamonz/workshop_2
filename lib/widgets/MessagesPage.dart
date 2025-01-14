import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projects/widgets/ChatPage.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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

            return FutureBuilder<Map<String, String>>(
              future: _fetchUserDetails(senderId, receiverId),
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

                String senderName = userDetailsSnapshot.data?['senderName'] ?? 'Unknown User';
                String receiverName = userDetailsSnapshot.data?['receiverName'] ?? 'Unknown User';

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: Text(senderName[0]), // First letter of the sender's name
                  ),
                  title: Text(senderName),
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
                          providerId: receiverId,
                          userId: senderId,
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

  Future<Map<String, String>> _fetchUserDetails(String senderId, String receiverId) async {
    try {
      // Fetch sender details
      DocumentSnapshot senderDoc = await _firestore.collection('users').doc(senderId).get();
      String senderFirstName = senderDoc['firstName'] ?? '';
      String senderLastName = senderDoc['lastName'] ?? '';
      String senderName = '$senderFirstName $senderLastName'.trim(); // Combine first and last name
      if (senderName.isEmpty) {
        senderName = 'Unknown User'; // Fallback if both fields are empty
      }

      // Fetch receiver details
      DocumentSnapshot receiverDoc = await _firestore.collection('users').doc(receiverId).get();
      String receiverFirstName = receiverDoc['firstName'] ?? '';
      String receiverLastName = receiverDoc['lastName'] ?? '';
      String receiverName = '$receiverFirstName $receiverLastName'.trim(); // Combine first and last name
      if (receiverName.isEmpty) {
        receiverName = 'Unknown User'; // Fallback if both fields are empty
      }

      return {
        'senderName': senderName,
        'receiverName': receiverName,
      };
    } catch (e) {
      print('Error fetching user details: $e');
      return {
        'senderName': 'Unknown User',
        'receiverName': 'Unknown User',
      };
    }
  }

  // Helper function to generate a unique key for each chat pair
  String _generateChatKey(String senderId, String receiverId) {
    List<String> ids = [senderId, receiverId];
    ids.sort(); // Ensure the key is consistent regardless of sender/receiver order
    return ids.join('_');
  }
}
