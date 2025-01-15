import 'package:flutter/material.dart';
import 'package:projects/auth/auth_service.dart';
import 'package:projects/auth/login_screen.dart';
import 'package:projects/normaluser/categoryCard.dart';
import 'package:projects/normaluser/serviceCard.dart';
import 'viewService.dart';
import 'bookings.dart';
import 'inbox.dart';
import 'profile.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Import Google Maps package

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
  String _currentLocation = 'Loading...'; // **Added variable to store location**

  late GoogleMapController mapController;

  // **Fetch current location when the page loads**
  Future<void> _getUserLocation() async {
    try {
      // Check if location service is enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _currentLocation = 'Location services are disabled.'; // **Error message for location service**
        });
        return;
      }

      // Check for location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _currentLocation = 'Location permission denied'; // **Error message for location permission**
          });
          return;
        }
      }

      // Get the current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentLocation =
        '${position.latitude.toStringAsFixed(2)}, ${position.longitude.toStringAsFixed(2)}'; // **Display the latitude and longitude**
      });

      // Move the camera to the user's location
      mapController.moveCamera(CameraUpdate.newLatLng(
        LatLng(position.latitude, position.longitude),
      ));

    } catch (e) {
      setState(() {
        _currentLocation = 'Failed to get location: $e'; // **Error handling for location fetching**
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getUserLocation(); // **Call the method to fetch location on initialization**
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

  final Map<String, List<Map<String, String>>> services = {
    'Plumbing': [
      {
        'provider': 'John\'s Plumbing',
        'service': 'Plumbing',
        'price': 'RM100 - RM300',
        'rating': '4.5',
        'location': 'Johor Bahru, Johor',
        'image': 'images/plumbing.png',
      },
    ],
    'Electrical': [
      {
        'provider': 'Reliable Electricians',
        'service': 'Electrical',
        'price': 'RM150 - RM500',
        'rating': '4.7',
        'location': 'Melaka',
        'image': 'images/electrical.png',
      },
    ],
    'Cleaning': [
      {
        'provider': 'Super Clean Services',
        'service': 'Cleaning',
        'price': 'RM80 - RM200',
        'rating': '4.8',
        'location': 'Kuala Lumpur',
        'image': 'images/cleaning.png',
      },
    ],
  };

  List<Widget> _getServiceCards() {
    List<Map<String, String>> serviceList = [];

    if (selectedCategory == null || selectedCategory == 'All') {
      services.forEach((_, value) {
        serviceList.addAll(value);
      });
    } else if (services.containsKey(selectedCategory)) {
      serviceList = services[selectedCategory!]!;
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
      return ServiceCard(
        providerName: service['provider']!,
        serviceType: service['service']!,
        serviceName: service['service']!,
        rangePrice: service['price']!,
        rating: double.parse(service['rating']!),
        location: service['location']!,
        image: service['image']!,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
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
                contentPadding: EdgeInsets.symmetric(vertical: 15.0),
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
            SizedBox(height: 20),
            const Text(
              'Available Services',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            SizedBox(height: 10),
            // **Location Display**
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'Your Location: $_currentLocation', // **Show current location**
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
            // Google Maps Widget
            SizedBox(
              height: 250, // Adjust height as needed
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(0.0, 0.0), // Default initial location
                  zoom: 10,
                ),
                onMapCreated: (GoogleMapController controller) {
                  mapController = controller;
                },
              ),
            ),
            // **Service Cards**
            Column(children: _getServiceCards()),
          ],
        ),
      ),
    );
  }
}
