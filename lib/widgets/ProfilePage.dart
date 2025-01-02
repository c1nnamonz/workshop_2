import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projects/widgets/EditBusinessPage.dart';
import 'package:projects/widgets/EditProfilePage.dart';



class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<Map<String, dynamic>> _getUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          return {
            ...doc.data()!,
            'email': user.email ?? 'No Email',
            'profileImage': doc.data()?['profileImage'] ?? 'assets/profile_placeholder.png',
          };
        }
      } catch (e) {
        return {'error': 'Error fetching user data: $e'};
      }
    }

    return {
      'name': 'Guest',
      'email': 'No Email',
      'profileImage': 'assets/profile_placeholder.png',
    };
  }

  Future<Map<String, dynamic>> _getBusinessInfo() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('businesses').doc(user.uid).get();
        if (doc.exists) {
          return doc.data()!;
        }
      } catch (e) {
        return {'error': 'Error fetching business data: $e'};
      }
    }

    return {'businessName': 'No Business', 'businessAddress': 'No Address'};
  }

  Widget _buildCard(String title, Map<String, dynamic> data, VoidCallback onTap) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              ...data.entries.map(
                    (entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Flexible(
                        child: Text(
                          entry.value.toString(),
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: Future.wait([_getUserInfo(), _getBusinessInfo()])
          .then((results) => {'user': results[0], 'business': results[1]}),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading profile information.'));
        }

        final userInfo = snapshot.data?['user'] ?? {};
        final businessInfo = snapshot.data?['business'] ?? {};
        final profileImage = userInfo['profileImage'].toString().startsWith('http')
            ? NetworkImage(userInfo['profileImage'])
            : AssetImage(userInfo['profileImage']) as ImageProvider;

        return Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: profileImage,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        userInfo['name'] ?? 'Maintenance Provider',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildCard('Profile Details', userInfo, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfilePage(userInfo: userInfo),
                    ),
                  );
                }),
                _buildCard('Business Details', businessInfo, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditBusinessPage(businessInfo: businessInfo),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}
