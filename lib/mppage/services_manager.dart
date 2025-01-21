import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ServicesManager extends StatefulWidget {
  @override
  _ServicesManagerState createState() => _ServicesManagerState();
}

class _ServicesManagerState extends State<ServicesManager> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _userId;
  List<Map<String, dynamic>> _services = [];
  List<String> _availableCategories = []; // Dynamically fetched categories

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in! Please log in.")),
      );
      return;
    }

    setState(() {
      _userId = currentUser.uid;
    });

    await _loadUserCategories();
    _loadServices();
  }

  Future<void> _loadUserCategories() async {
    if (_userId == null) return;

    try {
      final userDoc = await _firestore.collection("users").doc(_userId).get();
      if (userDoc.exists) {
        final data = userDoc.data();
        if (data != null && data.containsKey("category")) {
          setState(() {
            _availableCategories = List<String>.from(data["category"]);
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load categories: $e")),
      );
    }
  }

  Future<void> _loadServices() async {
    if (_userId == null) return;

    try {
      final snapshot = await _firestore
          .collection("services")
          .where("userId", isEqualTo: _userId)
          .get();

      setState(() {
        _services = snapshot.docs.map((doc) {
          return {
            "documentId": doc.id,
            "service": doc["service"] ?? "",
            "description": doc["description"] ?? "",
            "price": doc["price"] ?? "",
          };
        }).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load services: $e")),
      );
    }
  }

  void _addService() {
    setState(() {
      _services.add({
        "documentId": null,
        "service": "",
        "description": "",
        "price": "",
      });
    });
  }

  Future<void> _removeService(int index) async {
    final service = _services[index];
    final documentId = service["documentId"];

    if (documentId != null) {
      try {
        await _firestore.collection("services").doc(documentId).delete();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete service: $e")),
        );
      }
    }

    setState(() {
      _services.removeAt(index);
    });
  }

  Future<void> _saveServices() async {
    if (_userId == null) return;

    try {
      for (var service in _services) {
        final documentId = service["documentId"];
        final serviceData = {
          "userId": _userId,
          "service": service["service"],
          "description": service["description"],
          "price": service["price"],
        };

        if (documentId == null) {
          final docRef = await _firestore.collection("services").add(serviceData);
          service["documentId"] = docRef.id;
        } else {
          await _firestore.collection("services").doc(documentId).update(serviceData);
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Services saved successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save services: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Services"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text(
                "Services",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ..._services.asMap().entries.map((entry) {
                final index = entry.key;
                final service = entry.value;

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        DropdownButtonFormField<String>(
                          value: service["service"].isNotEmpty ? service["service"] : null,
                          items: _availableCategories
                              .map((category) => DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ))
                              .toList(),
                          decoration: const InputDecoration(labelText: "Service Name"),
                          onChanged: (value) {
                            setState(() {
                              _services[index]["service"] = value ?? "";
                            });
                          },
                        ),
                        TextField(
                          controller: TextEditingController(text: service["description"]),
                          decoration: const InputDecoration(labelText: "Description"),
                          onChanged: (value) {
                            _services[index]["description"] = value;
                          },
                        ),
                        TextField(
                          controller: TextEditingController(text: service["price"]),
                          decoration: const InputDecoration(labelText: "Price"),
                          onChanged: (value) {
                            _services[index]["price"] = value;
                          },
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeService(index),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _addService,
                icon: const Icon(Icons.add),
                label: const Text("Add Service"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveServices,
                child: const Text("Save Services"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
