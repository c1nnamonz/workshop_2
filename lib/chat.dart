// chat.dart
import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Text(
          'No new messages.',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
