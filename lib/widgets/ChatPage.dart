import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatPage extends StatefulWidget {
  final String providerId;
  final String userId;

  const ChatPage({
    Key? key,
    required this.providerId,
    required this.userId,
  }) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _messageController = TextEditingController();

  void _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      // Add the message to Firestore
      await _firestore.collection('chats').add({
        'senderId': widget.userId,
        'receiverId': widget.providerId,
        'message': _messageController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Send a notification to the receiver
      await _sendNotification(
        receiverId: widget.providerId,
        message: _messageController.text,
      );

      _messageController.clear();
    }
  }

// Send a notification to the receiver
  Future<void> _sendNotification({required String receiverId, required String message}) async {
    try {
      // Fetch the receiver's FCM token
      DocumentSnapshot receiverDoc = await _firestore.collection('users').doc(receiverId).get();
      String? fcmToken = receiverDoc['fcmToken'];

      if (fcmToken != null) {
        // Send the notification using Firebase Cloud Messaging
        await _firestore.collection('notifications').add({
          'to': fcmToken,
          'notification': {
            'title': 'New Message',
            'body': message,
          },
        });
      } else {
        print('Receiver does not have an FCM token');
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
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
                    String senderId = message['senderId'];
                    String messageText = message['message'];
                    bool isMe = senderId == widget.userId;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue : Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          messageText,
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black,
                          ),
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
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    if (_messageController.text.isNotEmpty) {
                      await _firestore.collection('chats').add({
                        'senderId': widget.userId,
                        'receiverId': widget.providerId,
                        'message': _messageController.text,
                        'timestamp': FieldValue.serverTimestamp(),
                      });

                      _messageController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
