
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<User> registerAccount({
    required String name,
    required String email,
    required String password,
    required String accountType,
  }) async {
    if (accountType != 'parent' && accountType != 'independent') {
      throw ArgumentError.value(accountType, 'accountType');
    }

    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user;

    if (user == null) {
      throw Exception('Account creation failed.');
    }

    try {
      await user.updateDisplayName(name.trim());
      await _db.collection('users').doc(user.uid).set({
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'role': accountType,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (error) {
      // Remove the Auth account if saving its profile fails.
      await user.delete();
      rethrow;
    }

    return user;
  }

  Future<void> registerParent({
    required String name,
    required String email,
    required String password,
  }) async {
    await registerAccount(
      name: name,
      email: email,
      password: password,
      accountType: 'parent',
    );
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

  // Retrieve the signed-in user's profile
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

  Future<void> updateName({required String name}) async {
    final user = _requireCurrentUser();
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Name cannot be empty.');
    }

    final profile = _db.collection('users').doc(user.uid);
    final previousDisplayName = user.displayName;
    await user.updateDisplayName(trimmedName);

    try {
      await profile.update({'name': trimmedName});
    } catch (error) {
      try {
        await user.updateDisplayName(previousDisplayName);
      } catch (rollbackError) {
        throw StateError(
          'Could not save the profile name ($error) or restore the '
          'Firebase Auth name ($rollbackError).',
        );
      }
      rethrow;
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _requireCurrentUser();
    await _reauthenticate(user, currentPassword);
    await user.updatePassword(newPassword);
  }

  Future<void> deleteAccount({required String currentPassword}) async {
    final user = _requireCurrentUser();
    await _reauthenticate(user, currentPassword);

    final profile = _db.collection('users').doc(user.uid);
    final profileSnapshot = await profile.get();
    final childrenSnapshot = await profile.collection('children').get();

    try {
      final childDocuments = childrenSnapshot.docs;
      if (childDocuments.isEmpty) {
        if (profileSnapshot.exists) {
          final batch = _db.batch()..delete(profile);
          await batch.commit();
        }
      } else {
        for (var start = 0; start < childDocuments.length; start += 450) {
          final end = start + 450 < childDocuments.length
              ? start + 450
              : childDocuments.length;
          final batch = _db.batch();
          for (final child in childDocuments.sublist(start, end)) {
            batch.delete(child.reference);
          }
          if (end == childDocuments.length && profileSnapshot.exists) {
            batch.delete(profile);
          }
          await batch.commit();
        }
      }

      await user.delete();
    } catch (error) {
      try {
        final documentsToRestore =
            <(DocumentReference<Map<String, dynamic>>, Map<String, dynamic>)>[];
        final profileData = profileSnapshot.data();
        if (profileData != null) {
          documentsToRestore.add((profile, profileData));
        }
        documentsToRestore.addAll(
          childrenSnapshot.docs.map((child) => (child.reference, child.data())),
        );

        for (var start = 0; start < documentsToRestore.length; start += 450) {
          final end = start + 450 < documentsToRestore.length
              ? start + 450
              : documentsToRestore.length;
          final batch = _db.batch();
          for (final (reference, data)
              in documentsToRestore.sublist(start, end)) {
            batch.set(reference, data);
          }
          await batch.commit();
        }
      } catch (restoreError) {
        throw StateError(
          'Account deletion failed ($error), and restoring profile data '
          'also failed ($restoreError).',
        );
      }
      rethrow;
    }
  }

  User _requireCurrentUser() {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('You must be signed in to manage your account.');
    }
    return user;
  }

  Future<void> _reauthenticate(User user, String password) async {
    if (password.isEmpty) {
      throw ArgumentError.value(password, 'password', 'Password is required.');
    }

    final email = user.email;
    if (email == null || email.isEmpty) {
      throw StateError('Your account does not have an email address.');
    }

    await user.reauthenticateWithCredential(
      EmailAuthProvider.credential(email: email, password: password),
    );
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
