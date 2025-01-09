import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CompletedServicesPage extends StatefulWidget {
  @override
  _CompletedServicesPageState createState() => _CompletedServicesPageState();
}

class _CompletedServicesPageState extends State<CompletedServicesPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _userId;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    final User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      setState(() {
        _userId = currentUser.uid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Completed Services")),
        body: const Center(child: Text("User not logged in!")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Completed Services")),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('completedServices')
            .where('userId', isEqualTo: _userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final completedServices = snapshot.data!.docs;

          if (completedServices.isEmpty) {
            return const Center(child: Text("No completed services yet."));
          }

          return ListView.builder(
            itemCount: completedServices.length,
            itemBuilder: (context, index) {
              final service = completedServices[index].data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service['service'] ?? 'No Service Name',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text("📃 Description: ${service['description'] ?? 'No Description'}",
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text("💰 Price: ${service['price'] ?? 'Not Provided'}",
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text("📅 Completion Date: ${service['completionDate'] ?? 'No Date'}",
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
