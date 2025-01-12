import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatPage extends StatefulWidget {
  final String providerId;
  final String userId;

  ChatPage({required this.providerId, required this.userId});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _userFullName = 'Loading...'; // To store the user's full name
  String _providerFullName = 'Loading...'; // To store the provider's full name
  String _chatTitle = 'Loading...'; // To store the chat title (e.g., "Chat with [Normal User]")

  @override
  void initState() {
    super.initState();
    _fetchUserAndProviderNames(); // Fetch user and provider names when the page loads
  }

  // Method to fetch user and provider names
  Future<void> _fetchUserAndProviderNames() async {
    try {
      // Fetch user details
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(widget.userId).get();
      setState(() {
        _userFullName = '${userDoc['firstName'] ?? 'Unknown'} ${userDoc['lastName'] ?? 'User'}';
      });

      // Fetch provider details
      DocumentSnapshot providerDoc = await _firestore.collection('users').doc(widget.providerId).get();
      setState(() {
        _providerFullName = '${providerDoc['firstName'] ?? 'Unknown'} ${providerDoc['lastName'] ?? 'Provider'}';
      });

      // Determine the chat title based on user roles
      setState(() {
        _chatTitle = 'Chat with $_userFullName';
      });
    } catch (e) {
      print('Error fetching user or provider details: $e');
      setState(() {
        _userFullName = 'Error loading name';
        _providerFullName = 'Error loading name';
        _chatTitle = 'Error loading chat title';
      });
    }
  }

  void _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _firestore.collection('chats').add({
        'senderId': widget.providerId,
        'receiverId': widget.userId,
        'message': _messageController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_chatTitle), // Display the chat title (e.g., "Chat with [Normal User]")
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .where('senderId', whereIn: [widget.userId, widget.providerId])
                  .where('receiverId', whereIn: [widget.userId, widget.providerId])
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var messages = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message = messages[index];
                    bool isMe = message['senderId'] == widget.providerId;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue.shade100 : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            if (!isMe)
                              Text(
                                _userFullName,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            if (!isMe) SizedBox(height: 4),
                            Text(
                              message['message'],
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
