import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<User?> createUserWithUsernameAndEmail(
      String username, String email, String password,
      {String? role, String? certificate, String? firstName, String? lastName, String? phoneNumber, String? address, String? state, String? zipCode}) async {
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

  Future<void> signout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print("Something went wrong");
    }
  }
}
