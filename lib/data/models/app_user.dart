class AppUser {
  final String uid;
  final String displayName;
  final String email;
  final int wins;
  final int losses;
  final int draws;
  final int matches;
  final int totalPoints;

  const AppUser({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.wins,
    required this.losses,
    required this.draws,
    required this.matches,
    required this.totalPoints,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'] as String? ?? '',
      displayName: map['displayName'] as String? ?? 'Jugador',
      email: map['email'] as String? ?? '',
      wins: (map['wins'] as num?)?.toInt() ?? 0,
      losses: (map['losses'] as num?)?.toInt() ?? 0,
      draws: (map['draws'] as num?)?.toInt() ?? 0,
      matches: (map['matches'] as num?)?.toInt() ?? 0,
      totalPoints: (map['totalPoints'] as num?)?.toInt() ?? 0,
    );
  }
}
