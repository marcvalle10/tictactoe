import 'package:cloud_firestore/cloud_firestore.dart';

class RankingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> top10() {
    return _firestore
        .collection('leaderboard')
        .orderBy('wins', descending: true)
        .orderBy('totalPoints', descending: true)
        .limit(10)
        .snapshots();
  }
}
