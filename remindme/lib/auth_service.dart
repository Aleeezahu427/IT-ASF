
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Register a new parent account
  Future<void> registerParent({
    required String name,
    required String username,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user;

    if (user == null) {
      throw Exception('Account creation failed.');
    }

    try {
      await _db.collection('users').doc(user.uid).set({
        'name': name.trim(),
        'username': username.trim().toLowerCase(),
        'email': email.trim().toLowerCase(),
        'role': 'parent',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (error) {
      // Remove the Auth account if saving its profile fails.
      await user.delete();
      rethrow;
    }
  }

  // Log in an existing parent
  Future<void> loginParent({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  // Retrieve the signed-in parent's profile
  Future<Map<String, dynamic>?> getMyProfile() async {
    final user = _auth.currentUser;

    if (user == null) {
      return null;
    }

    final document = await _db
        .collection('users')
        .doc(user.uid)
        .get();

    return document.data();
  }

  // Add a child profile under the signed-in parent
  Future<void> addChild({
    required String name,
    required String username,
  }) async {
    final parent = _auth.currentUser;

    if (parent == null) {
      throw Exception('You must be logged in to add a child.');
    }

    await _db
        .collection('users')
        .doc(parent.uid)
        .collection('children')
        .add({
      'name': name.trim(),
      'username': username.trim().toLowerCase(),
      'role': 'child',
      'parentUid': parent.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Send a password reset email
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(
      email: email.trim(),
    );
  }

  // Log out
  Future<void> logout() async {
    await _auth.signOut();
  }
}
