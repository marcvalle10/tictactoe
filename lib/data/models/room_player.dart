class RoomPlayer {
  final String uid;
  final String name;
  final String symbol;
  final String colorHex;
  final bool isHost;
  final bool isOnline;
  final int score;
  final int joinOrder;

  const RoomPlayer({
    required this.uid,
    required this.name,
    required this.symbol,
    required this.colorHex,
    required this.isHost,
    required this.isOnline,
    required this.score,
    required this.joinOrder,
  });

  RoomPlayer copyWith({
    String? uid,
    String? name,
    String? symbol,
    String? colorHex,
    bool? isHost,
    bool? isOnline,
    int? score,
    int? joinOrder,
  }) {
    return RoomPlayer(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      colorHex: colorHex ?? this.colorHex,
      isHost: isHost ?? this.isHost,
      isOnline: isOnline ?? this.isOnline,
      score: score ?? this.score,
      joinOrder: joinOrder ?? this.joinOrder,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'symbol': symbol,
      'color': colorHex,
      'isHost': isHost,
      'isOnline': isOnline,
      'score': score,
      'joinOrder': joinOrder,
    };
  }

  factory RoomPlayer.fromMap(Map<dynamic, dynamic> map) {
    return RoomPlayer(
      uid: map['uid']?.toString() ?? '',
      name: map['name']?.toString() ?? 'Jugador',
      symbol: map['symbol']?.toString() ?? 'X',
      colorHex: map['color']?.toString() ?? '#FFFFFF',
      isHost: map['isHost'] == true,
      isOnline: map['isOnline'] != false,
      score: (map['score'] as num?)?.toInt() ?? 0,
      joinOrder: (map['joinOrder'] as num?)?.toInt() ?? 0,
    );
  }
}
