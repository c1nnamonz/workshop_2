import 'package:flutter/material.dart';
import 'package:projects/signin.dart'; // Assuming this is the location of your sign-in page

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Dummy data for user profile (you can replace it with actual data)
  String _userName = "John Doe";
  String _userEmail = "johndoe@example.com";
  String _profileImage = "images/user_profile.png"; // You can use a placeholder image initially

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Image Section
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 70,
                      backgroundImage: AssetImage(_profileImage),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: IconButton(
                        icon: Icon(Icons.camera_alt, color: Colors.white),
                        onPressed: () {
                          // Add functionality to update profile picture
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // User Name
              Text(
                _userName,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text(
                _userEmail,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 20),

              // Edit Profile Button
              ElevatedButton(
                onPressed: () {
                  // Navigate to edit profile screen (you can create an EditProfilePage)
                },
                child: Text('Edit Profile'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Correct usage for background color
                ),
              ),

              // Settings, Voucher, and Addresses Sections
              ListTile(
                leading: Icon(Icons.settings),
                title: Text('Settings'),
                onTap: () {
                  // Navigate to settings page
                  _navigateToSettings();
                },
              ),
              ListTile(
                leading: Icon(Icons.card_giftcard),
                title: Text('Vouchers'),
                onTap: () {
                  // Navigate to voucher page
                  _navigateToVouchers();
                },
              ),
              ListTile(
                leading: Icon(Icons.location_on),
                title: Text('Addresses'),
                onTap: () {
                  // Navigate to addresses page
                  _navigateToAddresses();
                },
              ),
              Divider(),

              // Log Out Button
              ListTile(
                leading: Icon(Icons.logout),
                title: Text('Log Out'),
                onTap: () {
                  // Add functionality to log out
                  _logout();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Navigate to Settings page
  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SettingsPage()),
    );
  }

  // Navigate to Vouchers page
  void _navigateToVouchers() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => VouchersPage()),
    );
  }

  // Navigate to Addresses page
  void _navigateToAddresses() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddressesPage()),
    );
  }

  // Log out function
  void _logout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Log Out'),
          content: Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SignInPage()),
                );
              },
              child: Text('Log Out'),
            ),
          ],
        );
      },
    );
  }
}

// Vouchers Page - Search bar and Apply button
class VouchersPage extends StatefulWidget {
  @override
  _VouchersPageState createState() => _VouchersPageState();
}

class _VouchersPageState extends State<VouchersPage> {
  TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Vouchers')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar for Voucher
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Add Voucher',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            // Apply Code Button
            ElevatedButton(
              onPressed: () {
                // Logic for applying voucher code
                String code = _searchController.text;
                if (code.isNotEmpty) {
                  // Perform voucher claim logic
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Voucher code "$code" claimed!')),
                  );
                }
              },
              child: Text('Claim'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}

// Addresses Page - Insert, Edit, Delete Multiple Addresses
class AddressesPage extends StatefulWidget {
  @override
  _AddressesPageState createState() => _AddressesPageState();
}

class _AddressesPageState extends State<AddressesPage> {
  List<String> addresses = ['123 Main St', '456 Oak Rd']; // Example addresses

  TextEditingController _addressController = TextEditingController();

  void _addAddress(String address) {
    setState(() {
      addresses.add(address);
    });
    _addressController.clear();
  }

  void _editAddress(int index, String newAddress) {
    setState(() {
      addresses[index] = newAddress;
    });
  }

  void _deleteAddress(int index) {
    setState(() {
      addresses.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Addresses')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Address Input
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                hintText: 'Enter new address',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                if (_addressController.text.isNotEmpty) {
                  _addAddress(_addressController.text);
                }
              },
              child: Text('Add Address'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            ),
            SizedBox(height: 20),
            // Address List
            Expanded(
              child: ListView.builder(
                itemCount: addresses.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(addresses[index]),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            _addressController.text = addresses[index];
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text('Edit Address'),
                                  content: TextField(
                                    controller: _addressController,
                                    decoration: InputDecoration(
                                      hintText: 'Edit address',
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        _editAddress(index, _addressController.text);
                                        Navigator.pop(context);
                                      },
                                      child: Text('Save'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text('Cancel'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            _deleteAddress(index);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Settings Page - Enable/Disable Push Notifications
class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Push Notifications Toggle
            SwitchListTile(
              title: Text('Enable Push Notifications'),
              value: _notificationsEnabled,
              onChanged: (bool value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
