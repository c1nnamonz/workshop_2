
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:projects/auth/auth_service.dart';
import 'package:projects/auth/login_screen.dart';
import 'package:projects/normaluser/categoryCard.dart';
import 'package:projects/normaluser/serviceCard.dart';
import 'booking_form.dart';
import 'chatbot.dart';
import 'viewService.dart';
import 'bookings.dart';
import 'inbox.dart';
import 'profile.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> requestLocationPermission() async {
  var status = await Permission.location.request();
  if (status.isGranted) {
    print("Location permission granted.");
  } else if (status.isDenied) {
    print("Location permission denied.");
  } else if (status.isPermanentlyDenied) {
    print("Location permission permanently denied. Open app settings.");
  }
}


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
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _currentLocation = 'Please enable location services.';
        });
        return;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.deniedForever) {
          setState(() {
            _currentLocation = 'Location permissions are permanently denied. Please enable them in settings.';
          });
          return;
        }
        if (permission == LocationPermission.denied) {
          setState(() {
            _currentLocation = 'Location permission denied.';
          });
          return;
        }
      }

      // Fetch the current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Update the location state
      setState(() {
        _currentLocation =
        '${position.latitude.toStringAsFixed(2)}, ${position.longitude.toStringAsFixed(2)}';
      });

      // Update the map's camera position
      if (mapController != null) {
        mapController.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(position.latitude, position.longitude),
            15, // Adjust the zoom level (can be dynamic)
          ),
        );
      } else {
        setState(() {
          _currentLocation = 'Map controller is not initialized.';
        });
      }
    } catch (e) {
      // Handle exceptions
      setState(() {
        _currentLocation = 'Failed to get location. Please try again.';
      });
      print('Error getting location: $e');
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

  Future<List<Map<String, dynamic>>> _fetchServices() async {
    List<Map<String, dynamic>> serviceList = [];
    try {
      QuerySnapshot serviceSnapshot = await FirebaseFirestore.instance
          .collection('services')
          .get();

      for (var serviceDoc in serviceSnapshot.docs) {
        String userId = serviceDoc['userId'];

        // Fetch user details based on userId
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        if (userDoc.exists) {
          serviceList.add({
            'description': serviceDoc['description'] ?? 'Unknown Description',
            'price': serviceDoc['price'] ?? 'Unknown Price',
            'service': serviceDoc['service'] ?? 'Unknown Service',
            'rating': serviceDoc['rating'] ?? 0.0,  // Fetch the rating
            'providerId': userId, // Ensure the providerId is included
            'companyName': userDoc['companyName'] ?? 'Unknown Company',
            'location': userDoc['location'] ?? 'Unknown Location',
          });
        }
      }
    } catch (e) {
      print("Error fetching services: $e");
    }

    return serviceList;
  }




  List<Widget> _getServiceCards(List<Map<String, dynamic>> serviceList) {
    if (selectedCategory != null && selectedCategory != 'All') {
      serviceList = serviceList.where((service) {
        return service['service']!.toLowerCase() == selectedCategory!.toLowerCase();
      }).toList();
    }

    if (_searchQuery.isNotEmpty) {
      serviceList = serviceList.where((service) {
        return service['service']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            service['companyName']!.toLowerCase().contains(_searchQuery.toLowerCase());
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
      String imagePath = categoryIcons[service['service']] ?? 'images/default.png';

      return GestureDetector(
        onTap: () {
          // Dialog showing service details
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      imagePath, // Use the preset image path here
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      service['service'] ?? 'Unknown Service',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text('Price: ${service['price'] ?? 'N/A'}', style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 5),
                    Text('Rating: ${service['rating'] ?? '0'}', style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 5),
                    Text('Location: ${service['location'] ?? 'Unknown Location'}', style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookingForm(
                                  providerId: service['providerId'] ?? '',
                                  serviceName: service['service'] ?? '',
                                  price: service['price'] ?? '',
                                  description: service['description'] ?? '',
                                  companyName: service['companyName'] ?? '',
                                  location: service['location'] ?? '',
                                ),
                              ),
                            );
                          },
                          child: const Text('Book Now'),
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          child: const Text('Chat'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
        child: ServiceCard(
          serviceType: service['service'] ?? 'Unknown Type',
          serviceName: service['service'] ?? 'Unknown Service',
          rangePrice: service['price'] ?? 'N/A',
          rating: (service['rating'] ?? 0.0).toDouble(), // Pass the rating as a double
          location: service['location'] ?? 'Unknown Location',
          companyName: service['companyName'] ?? 'Unknown Company',
          providerId: service['providerId'] ?? '',
          imagePath: imagePath, // Use dynamic image path
        ),
      );
    }).toList();
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchServices(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error fetching services'));
        }

        List<Map<String, dynamic>> services = snapshot.data ?? [];

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
                            categoryIcons[category]!, // Assumes 'categoryIcons' is a map with categories as keys
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          ),
                          category: category, // Pass the category string directly
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
                      target: LatLng(3.1390, 101.6869), // Example: Kuala Lumpur's coordinates
                      zoom: 10,
                    ),
                    onMapCreated: (GoogleMapController controller) {
                      mapController = controller;
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Column(children: _getServiceCards(services)),
              ],
            ),
          ),
        );
      },
    );
  }
}
