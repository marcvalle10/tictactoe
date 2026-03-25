import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    await credential.user?.updateDisplayName(name.trim());

    await _firestore.collection('users').doc(credential.user!.uid).set({
      'uid': credential.user!.uid,
      'displayName': name.trim(),
      'email': email.trim(),
      'wins': 0,
      'losses': 0,
      'draws': 0,
      'matches': 0,
      'totalPoints': 0,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await _firestore.collection('leaderboard').doc(credential.user!.uid).set({
      'uid': credential.user!.uid,
      'displayName': name.trim(),
      'wins': 0,
      'matches': 0,
      'totalPoints': 0,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
