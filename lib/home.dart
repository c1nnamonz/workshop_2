import 'package:flutter/material.dart';
import 'package:projects/viewService.dart';
import 'bookings.dart'; // Import bookings.dart
import 'inbox.dart'; // Import inbox.dart
import 'chat.dart'; // Import chat.dart
import 'profile.dart'; // Import profile.dart

class PageHome extends StatefulWidget {
  @override
  _PageHomeState createState() => _PageHomeState();
}

class _PageHomeState extends State<PageHome> {
  int _selectedIndex = 0;

  // Pages for each BottomNavigationBar item
  final List<Widget> _pages = [
    HomePageContent(),
    BookingsPage(),
    InboxPage(),
    ChatPage(),
    ProfilePage(), // Add ProfilePage here
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: ImageIcon(AssetImage('images/fixitLogo.png')), // Updated logo
              label: 'Services',
            ),
            BottomNavigationBarItem(
              icon: ImageIcon(AssetImage('images/fixitLogo.png')), // Updated logo
              label: 'Bookings',
            ),
            BottomNavigationBarItem(
              icon: ImageIcon(AssetImage('images/fixitLogo.png')), // Updated logo
              label: 'Inbox',
            ),
            BottomNavigationBarItem(
              icon: ImageIcon(AssetImage('images/fixitLogo.png')), // Updated logo
              label: 'Chats',
            ),
            BottomNavigationBarItem(
              icon: ImageIcon(AssetImage('images/fixitLogo.png')), // Updated logo
              label: 'Profile',
            ),
          ],
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
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
  bool _showMore = false; // Track whether to show all categories or only 8
  String _searchQuery = '';

  // Category list
  final List<String> categories = [
    'All',
    'Plumbing',
    'Electrical',
    'Air Conditioning',
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

  // Map of category icons
  final Map<String, String> categoryIcons = {
    'All': 'images/all.png',
    'Plumbing': 'images/plumbing.png',
    'Electrical': 'images/electrical.png',
    'Air Conditioning': 'images/aircond.png',
    'Cleaning': 'images/cleaning.png',
    'Renovation': 'images/renovate.png',
    'Security': 'images/security.png',
    'Landscaping': 'images/fixitLogo.png',
    'Pest Control': 'images/fixitLogo.png',
    'Appliance Repair': 'images/fixitLogo.png',
    'Furniture Assembly': 'images/fixitLogo.png',
    'Smart Home Installation': 'images/fixitLogo.png',
    'Pool Maintenance': 'images/fixitLogo.png',
  };


  // Selected category for filtering services
  String? selectedCategory;

  // Function to get the visible categories based on `_showMore`
  List<String> _getVisibleCategories() {
    return _showMore ? categories : categories.take(8).toList();
  }

  // Dummy data for services
  final Map<String, List<Map<String, String>>> services = {
    'Plumbing': [
      {'provider': 'John\'s Plumbing Co.', 'service': 'Pipe Repair', 'price': '\$50 - \$200', 'rating': '4.5', 'location': 'New York, NY', 'image': 'images/fixitLogo.png'}, // Updated logo
      {'provider': 'Expert Plumbing', 'service': 'Leak Fixing', 'price': '\$30 - \$150', 'rating': '4.7', 'location': 'Los Angeles, CA', 'image': 'images/fixitLogo.png'}, // Updated logo
    ],
    'Electrical': [
      {'provider': 'Power Electricians', 'service': 'Wiring', 'price': '\$100 - \$500', 'rating': '4.8', 'location': 'San Francisco, CA', 'image': 'images/fixitLogo.png'}, // Updated logo
    ],
    'Air Conditioning': [
      {'provider': 'Cool Breeze AC Services', 'service': 'AC Installation', 'price': '\$150 - \$600', 'rating': '4.2', 'location': 'Miami, FL', 'image': 'images/fixitLogo.png'}, // Updated logo
    ],
  };

  // Function to search services
  List<Widget> _getServiceCards() {
    List<Map<String, String>> serviceList = [];

    // Add all services from all categories if no search term
    services.forEach((category, serviceCategory) {
      serviceList.addAll(serviceCategory);
    });

    // If there's a search term, filter services by the search query
    if (_searchQuery.isNotEmpty) {
      serviceList = serviceList.where((service) {
        return service['service']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            service['provider']!.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // If a category is selected and there's no search term, filter by the selected category
    if (selectedCategory != null && selectedCategory != 'All' && _searchQuery.isEmpty) {
      serviceList = services[selectedCategory!] ?? [];
    }

    // Map the filtered list to ServiceCard widgets
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search services, provider, or category',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 15.0),
              ),
            ),
            SizedBox(height: 20),

            // Categories Section
            Text(
              'Categories',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            // Categories with Wrap for responsive layout (4 categories per row)
            Wrap(
              spacing: 10.0,
              runSpacing: 10.0,
              children: _getVisibleCategories().map((category) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = category == 'All' ? null : category;
                    });
                  },
                  child: Container(
                    width: (MediaQuery.of(context).size.width - 70) / 4, // Adjust width to fit 4 items per row
                    child: CategoryCard(
                      image: Image.asset(
                        categoryIcons[category]!, // Use the icon for this category
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

            SizedBox(height: 10),

            // "More Category" or "Collapse" button
            Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _showMore = !_showMore;
                  });
                },
                child: Text(_showMore ? 'Collapse' : 'More Category'),
              ),
            ),
            SizedBox(height: 20),

            // Services Section
            Text(
              'Available Services',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            // Display service cards based on selected category and search query
            Column(children: _getServiceCards()),
          ],
        ),
      ),
    );
  }
}

// Category Card Widget
class CategoryCard extends StatelessWidget {
  final Image image;
  final String category;

  CategoryCard({required this.image, required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: image,
          ),
          SizedBox(height: 5),
          Text(
            category,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Service Card Widget
class ServiceCard extends StatelessWidget {
  final String providerName;
  final String serviceType;
  final String serviceName;
  final String rangePrice;
  final double rating;
  final String location;
  final String image;

  ServiceCard({
    required this.providerName,
    required this.serviceType,
    required this.serviceName,
    required this.rangePrice,
    required this.rating,
    required this.location,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to ViewServicePage when the service card is tapped
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ViewServicePage(
              providerName: providerName,
              serviceName: serviceName,
              serviceType: serviceType,
              location: location,
              rangePrice: rangePrice,
              rating: rating,
              image: image,
              feedback: [
                'Great service, highly recommended!',
                'Professional and fast.',
                'Very affordable and efficient.',
              ],
            ),
          ),
        );
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Service Image
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  image,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 10),

              // Service Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      providerName,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      serviceType,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    SizedBox(height: 5),
                    Text(
                      serviceName,
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 5),
                    Text(
                      rangePrice,
                      style: TextStyle(fontSize: 14, color: Colors.green),
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(Icons.star, size: 16, color: Colors.orange),
                        SizedBox(width: 5),
                        Text(
                          rating.toString(),
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(width: 10),
                        Text(
                          location,
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
