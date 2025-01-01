import 'package:flutter/material.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
    final List<Map<String, String>> chats = isOngoing
        ? [
      {'name': 'John Doe', 'message': 'Let’s finalize the booking.', 'time': '2m ago'},
      {'name': 'Jane Smith', 'message': 'Thanks for the update.', 'time': '10m ago'},
    ]
        : [
      {'name': 'Mike Johnson', 'message': 'Thanks for your help!', 'time': 'Yesterday'},
      {'name': 'Emily Davis', 'message': 'Great service!', 'time': '2 days ago'},
    ];

    return ListView.builder(
      itemCount: chats.length,
      itemBuilder: (context, index) {
        final chat = chats[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blue.shade100,
            child: Text(chat['name']![0]), // First letter of the name
          ),
          title: Text(chat['name']!),
          subtitle: Text(chat['message']!),
          trailing: Text(
            chat['time']!,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          onTap: () {
            // Navigate to detailed chat screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatDetailPage(chatName: chat['name']!),
              ),
            );
          },
        );
      },
    );
  }
}

class ChatDetailPage extends StatelessWidget {
  final String chatName;

  const ChatDetailPage({Key? key, required this.chatName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(chatName),
      ),
      body: Center(
        child: Text('Chat details for $chatName will appear here.'),
      ),
    );
  }
}
