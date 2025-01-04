import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:projects/auth/auth_service.dart';
import 'package:projects/auth/login_screen.dart';
import 'package:projects/normaluser/categoryCard.dart';
import 'package:projects/normaluser/serviceCard.dart';
import 'chatbot.dart';
import 'viewService.dart';
import 'bookings.dart';
import 'inbox.dart';
import 'profile.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class UserHomepage extends StatefulWidget {
  @override
  _UserHomepageState createState() => _UserHomepageState();
}

class _UserHomepageState extends State<UserHomepage> {
  int _selectedIndex = 0;

  // Pages for each BottomNavigationBar item
  final List<Widget> _pages = [
    HomePageContent(),
    BookingsPage(),
    InboxPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _logout(BuildContext context) async {
    await AuthService().signout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('User Home'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => _logout(context),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.deepOrange,
          unselectedItemColor: Colors.grey[500],
          items: const [
            BottomNavigationBarItem(
              icon: ImageIcon(AssetImage('images/services.png')),
              label: 'Services',
            ),
            BottomNavigationBarItem(
              icon: ImageIcon(AssetImage('images/bookings.png')),
              label: 'Bookings',
            ),
            BottomNavigationBarItem(
              icon: ImageIcon(AssetImage('images/inbox.png')),
              label: 'Inbox',
            ),
            BottomNavigationBarItem(
              icon: ImageIcon(AssetImage('images/user.png')),
              label: 'Profile',
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Replace this with your AI chatbot screen navigation logic
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ChatBotScreen()),
            );
          },
          child: const Icon(Icons.chat),
          backgroundColor: Color(0xFF4AA94E),
        ),
      ),
    );
  }
}

class HomePageContent extends StatefulWidget {
  @override
  _HomePageContentState createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  bool _showMore = false;
  String _searchQuery = '';
  String _currentLocation = 'Loading...';

  late GoogleMapController mapController;

  Future<void> _getUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _currentLocation = 'Location services are disabled.';
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _currentLocation = 'Location permission denied';
          });
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentLocation =
        '${position.latitude.toStringAsFixed(2)}, ${position.longitude.toStringAsFixed(2)}';
      });

      mapController.moveCamera(CameraUpdate.newLatLng(
        LatLng(position.latitude, position.longitude),
      ));

    } catch (e) {
      setState(() {
        _currentLocation = 'Failed to get location: $e';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  final List<String> categories = [
    'All',
    'Plumbing',
    'Electrical',
    'Air-cond',
    'Cleaning',
    'Renovation',
    'Security',
    'Landscaping',
    'Pest Control',
    'Appliance Repair',
    'Furniture Assembly',
    'Smart Home Installation',
    'Pool Maintenance',
  ];

  final Map<String, String> categoryIcons = {
    'All': 'images/all.png',
    'Plumbing': 'images/plumbing.png',
    'Electrical': 'images/electrical.png',
    'Air-cond': 'images/aircond.png',
    'Cleaning': 'images/cleaning.png',
    'Renovation': 'images/renovate.png',
    'Security': 'images/security.png',
    'Landscaping': 'images/landscape.png',
    'Pest Control': 'images/pest.png',
    'Appliance Repair': 'images/appliances.png',
    'Furniture Assembly': 'images/furniture.png',
    'Smart Home Installation': 'images/smart.png',
    'Pool Maintenance': 'images/pool.png',
  };

  String? selectedCategory;

  List<String> _getVisibleCategories() {
    return _showMore ? categories : categories.take(8).toList();
  }

  // **Fetching services from Firestore**
  Future<List<Map<String, String>>> _fetchServices() async {
    List<Map<String, String>> serviceList = [];
    try {
      // Fetch services from Firestore based on the profiles collection and user ID
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('profiles') // Firestore collection name
          .get();

      for (var doc in querySnapshot.docs) {
        String userId = doc.id;
        List<Map<String, String>> services = [];

        // Iterate through services within each user document
        List<dynamic> servicesData = doc['services'] ?? [];
        for (var serviceData in servicesData) {
          services.add({
            'provider': doc['name'] ?? 'Unknown Provider',
            'service': serviceData['service'] ?? 'Unknown Service',
            'price': serviceData['price'] ?? 'Unknown Price',
            'rating': doc['rating']?.toString() ?? '0',
            'location': doc['location'] ?? 'Unknown Location',
            'image': doc['profileImageUrl'] ?? '',
          });
        }

        serviceList.addAll(services);
      }
    } catch (e) {
      print("Error fetching services: $e");
    }

    return serviceList;
  }

  List<Widget> _getServiceCards(List<Map<String, String>> serviceList) {
    if (selectedCategory != null && selectedCategory != 'All') {
      serviceList = serviceList.where((service) {
        return service['service']!.toLowerCase() == selectedCategory!.toLowerCase();
      }).toList();
    }

    if (_searchQuery.isNotEmpty) {
      serviceList = serviceList.where((service) {
        return service['service']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            service['provider']!.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    if (serviceList.isEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.only(top: 20.0),
          child: Center(
            child: Text(
              'No services available',
              style: TextStyle(fontSize: 18, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ];
    }

    return serviceList.map((service) {
      // Get the image path for the service
      String imagePath = categoryIcons[service['service']] ?? 'images/default.png';

      return ServiceCard(
        providerName: service['provider']!,
        serviceType: service['service']!,
        serviceName: service['service']!,
        rangePrice: service['price']!,
        rating: double.parse(service['rating']!),
        location: service['location']!,
        imagePath: imagePath, // Pass the image path to the ServiceCard
      );
    }).toList();
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, String>>>(
      future: _fetchServices(), // Fetch services when the page loads
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error fetching services'));
        }

        List<Map<String, String>> services = snapshot.data ?? [];

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.asset(
                    'images/logo1.png',
                    width: 100,
                    height: 100,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search services, provider, or category',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: const Icon(Icons.search, color: Colors.black),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
                    fillColor: Colors.white,
                    filled: true,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Categories',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 5.0,
                  runSpacing: 20.0,
                  children: _getVisibleCategories().map((category) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedCategory = category == 'All' ? null : category;
                        });
                      },
                      child: Container(
                        width: (MediaQuery.of(context).size.width - 80) / 4,
                        child: CategoryCard(
                          image: Image.asset(
                            categoryIcons[category]!,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          ),
                          category: category,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                Align(
                  alignment: Alignment.center,
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _showMore = !_showMore;
                      });
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _showMore ? 'Collapse' : 'More Category',
                          style: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.blue,
                            decorationThickness: 2,
                          ),
                        ),
                        Icon(
                          _showMore ? Icons.arrow_upward : Icons.arrow_downward,
                          color: Colors.blue,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Available Services',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    'Your Location: $_currentLocation',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),
                SizedBox(
                  height: 250,
                  child: GoogleMap(
                    initialCameraPosition: const CameraPosition(
                      target: LatLng(0.0, 0.0),
                      zoom: 10,
                    ),
                    onMapCreated: (GoogleMapController controller) {
                      mapController = controller;
                    },
                  ),
                ),
                Column(children: _getServiceCards(services)),
              ],
            ),
          ),
        );
      },
    );
  }
}
