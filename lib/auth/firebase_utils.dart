import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseUtils {
  static Future<DocumentSnapshot?> getCurrentUserDocument() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          return userDoc; // Return the document snapshot
        }
      }
    } catch (e) {
      print("Error retrieving user document: $e");
    }
    return null; // Return null if user doesn't exist or an error occurs
  }
}
