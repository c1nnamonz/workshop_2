import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<User?> createUserWithUsernameAndEmail(
      String username, String email, String password,
      {String? role, String? certificate, String? firstName, String? lastName, String? phoneNumber, String? address, String? state, String? zipCode, GeoPoint? location}) async {
    try {
      // Create a new user with email and password
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      // Store user details in Firestore
      // Inside userData map
      final userData = {
        'username': username,
        'email': email,
        'role': role ?? 'User',
        'firstName': firstName ?? '',
        'lastName': lastName ?? '',
        'phoneNumber': phoneNumber ?? '',
        'zipCode': zipCode ?? '',
        'location': location ?? GeoPoint(0, 0), // Default location
      };


      // Add certificate if provided
      if (certificate != null && certificate.isNotEmpty) {
        userData['certificate'] = certificate;
      }

      // Store user data in Firestore under users collection
      await _firestore.collection('users').doc(cred.user!.uid).set(userData);

      return cred.user;
    } catch (e) {
      log("Error in createUserWithUsernameAndEmail: ${e.toString()}");
      return null;
    }
  }

  Future<User?> loginUserWithUsernameAndPassword(
      String username, String password) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .get();

      if (querySnapshot.docs.isEmpty) {
        log("Username not found");
        return null;
      }

      final email = querySnapshot.docs.first['email'];
      final cred = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return cred.user;
    } catch (e) {
      log("Error in loginUserWithUsernameAndPassword: ${e.toString()}");
      return null;
    }
  }

  Future<String> getUserRole(String uid) async {
    try {
      // Fetch user data from Firestore
      var userDoc = await _firestore.collection('users').doc(uid).get();

      // If the document exists, return the role
      if (userDoc.exists) {
        return userDoc.data()?['role'] ?? 'User'; // Default to 'User' if no role found
      } else {
        return 'User'; // Default role if no document is found
      }
    } catch (e) {
      log("Error getting user role: ${e.toString()}");
      return 'User'; // Default to 'User' if error occurs
    }
  }


  Future<void> signout() async {
    try {
      await _auth.signOut();
      log("User successfully logged out");
    } catch (e) {
      log("Error during signout: $e");
      throw Exception("Logout failed");
    }
  }
}
