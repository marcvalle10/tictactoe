import 'package:cloud_firestore/cloud_firestore.dart';

class RankingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> top10() {
    return _firestore
        .collection('leaderboard')
        .orderBy('wins', descending: true)
        .limit(10)
        .snapshots();
  }

  Stream<List<Map<String, dynamic>>> getLeaderboard() {
    return _firestore
        .collection('leaderboard')
        .orderBy('wins', descending: true)
        .orderBy('totalPoints', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'uid': doc.id,
          'displayName': data['displayName'] ?? 'Jugador',
          'wins': data['wins'] ?? 0,
          'matches': data['matches'] ?? 0,
          'totalPoints': data['totalPoints'] ?? 0,
        };
      }).toList();
    });
  }

  Future<void> updatePlayerStats({
    required String uid,
    required String displayName,
    required bool isWinner,
    required bool isDraw,
  }) async {
    final ref = _firestore.collection('leaderboard').doc(uid);

    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(ref);

      int wins = 0;
      int matches = 0;
      int totalPoints = 0;

      if (snap.exists) {
        final data = snap.data()!;
        wins = (data['wins'] ?? 0) as int;
        matches = (data['matches'] ?? 0) as int;
        totalPoints = (data['totalPoints'] ?? 0) as int;
      }

      matches += 1;

      if (isWinner) {
        wins += 1;
        totalPoints += 10;
      } else if (isDraw) {
        totalPoints += 3;
      } else {
        totalPoints += 1;
      }

      tx.set(
          ref,
          {
            'uid': uid,
            'displayName': displayName,
            'wins': wins,
            'matches': matches,
            'totalPoints': totalPoints,
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true));
    });
  }
}
