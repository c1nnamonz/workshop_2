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

  String? _userId; // Dynamically set user ID from FirebaseAuth
  List<Map<String, String>> _services = [];
  final List<String> _availableServices = [
    "Plumbing",
    "Electrical",
    "Air-cond",
    "Cleaning",
    "Renovation",
    "Security",
    "Landscaping",
    "Pest Control",
    "Appliance Repair",
    "Furniture Assembly",
    "Smart Home Installation",
    "Pool Maintenance",

  ]; // Predefined services

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  // Initialize the user and fetch services
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

    // Load services data from Firestore
    _loadServices();
  }

  // Load services data from Firestore
  Future<void> _loadServices() async {
    if (_userId == null) return;

    final snapshot = await _firestore
        .collection("services")
        .where("userId", isEqualTo: _userId)
        .get();

    setState(() {
      _services = snapshot.docs.map((doc) {
        return {
          "service": doc["service"]?.toString() ?? "",
          "description": doc["description"]?.toString() ?? "",
          "price": doc["price"]?.toString() ?? "",
          "docId": doc.id, // Store document ID for uniqueness
        };
      }).toList();
    });
  }

  // Add a new empty service to the list
  void _addService() {
    setState(() {
      _services.add({
        "service": "",
        "description": "",
        "price": "",
      });
    });
  }

  // Remove a service from the list
  void _removeService(int index) {
    setState(() {
      _services.removeAt(index);
    });
  }

  // Save services to Firestore, avoiding duplicates
  Future<void> _saveServices() async {
    if (_userId == null) return;

    try {
      for (var service in _services) {
        if (service["service"]!.isNotEmpty) {
          final existingServices = await _firestore
              .collection("services")
              .where("userId", isEqualTo: _userId)
              .where("service", isEqualTo: service["service"])
              .get();

          if (existingServices.docs.isEmpty) {
            await _firestore.collection("services").add({
              "userId": _userId,
              "service": service["service"],
              "description": service["description"],
              "price": service["price"],
            });
          }
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Services saved successfully!")),
      );

      // Reload services to reflect new additions
      _loadServices();
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
              // Display services
              ..._services.asMap().entries.map((entry) {
                final index = entry.key;
                final service = entry.value;

                return Card(
                  child: ListTile(
                    title: DropdownButtonFormField<String>(
                      value: (service["service"] ?? "").isEmpty ? null : service["service"],
                      items: _availableServices.map((service) {
                        return DropdownMenuItem<String>(
                          value: service,
                          child: Text(service),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _services[index]["service"] = value!;
                        });
                      },
                      decoration: const InputDecoration(labelText: "Service"),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: TextEditingController(text: service["description"]),
                          decoration: const InputDecoration(labelText: "Description"),
                          onChanged: (value) {
                            _services[index]["description"] = value;
                          },
                        ),
                        const SizedBox(height: 5),
                        TextField(
                          controller: TextEditingController(text: service["price"]),
                          decoration: const InputDecoration(labelText: "Price"),
                          onChanged: (value) {
                            _services[index]["price"] = value;
                          },
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeService(index),
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
              const SizedBox(height: 20),
              const Text(
                "Saved Services:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ..._services.map((service) {
                if (service["service"]!.isNotEmpty) {
                  return ListTile(
                    title: Text(service["service"]!),
                    subtitle: Text("Description: ${service["description"]}\nPrice: ${service["price"]}"),
                  );
                }
                return Container();
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
