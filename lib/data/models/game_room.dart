import 'game_mode.dart';
import 'room_player.dart';

class GameMove {
  final String playerUid;
  final String playerName;
  final String symbol;
  final int row;
  final int col;
  final int moveNumber;
  final int timestamp;

  const GameMove({
    required this.playerUid,
    required this.playerName,
    required this.symbol,
    required this.row,
    required this.col,
    required this.moveNumber,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'playerUid': playerUid,
      'playerName': playerName,
      'symbol': symbol,
      'row': row,
      'col': col,
      'moveNumber': moveNumber,
      'timestamp': timestamp,
    };
  }

  factory GameMove.fromMap(Map<dynamic, dynamic> map) {
    return GameMove(
      playerUid: map['playerUid']?.toString() ?? '',
      playerName: map['playerName']?.toString() ?? '',
      symbol: map['symbol']?.toString() ?? '',
      row: (map['row'] as num?)?.toInt() ?? 0,
      col: (map['col'] as num?)?.toInt() ?? 0,
      moveNumber: (map['moveNumber'] as num?)?.toInt() ?? 0,
      timestamp: (map['timestamp'] as num?)?.toInt() ?? 0,
    );
  }
}

class GameRoom {
  final String roomCode;
  final String hostId;
  final GameMode mode;
  final int boardSize;
  final int winLength;
  final String status;
  final int currentTurnIndex;
  final String currentSymbol;
  final String? nextSymbol;
  final List<List<String>> board;
  final List<RoomPlayer> players;
  final List<GameMove> moves;
  final String? winnerUid;
  final String? winnerName;
  final String? resultLabel;
  final bool isDraw;
  final List<List<int>> winningCells;

  const GameRoom({
    required this.roomCode,
    required this.hostId,
    required this.mode,
    required this.boardSize,
    required this.winLength,
    required this.status,
    required this.currentTurnIndex,
    required this.currentSymbol,
    required this.nextSymbol,
    required this.board,
    required this.players,
    required this.moves,
    required this.winnerUid,
    required this.winnerName,
    required this.resultLabel,
    required this.isDraw,
    required this.winningCells,
  });

  bool get isFinished => status == 'finished';
  bool get isPlaying => status == 'playing';
  bool get isWaiting => status == 'waiting' || status == 'ready';

  RoomPlayer? get currentPlayer {
    if (players.isEmpty) return null;
    if (currentTurnIndex < 0 || currentTurnIndex >= players.length) return null;
    return players[currentTurnIndex];
  }

  factory GameRoom.fromMap(Map<dynamic, dynamic> map) {
    final playersMap = (map['players'] as Map<dynamic, dynamic>? ?? {});
    final boardRaw = (map['board'] as List<dynamic>? ?? []);
    final movesRaw = (map['moves'] as List<dynamic>? ?? []);
    final winningCellsRaw = (map['winningCells'] as List<dynamic>? ?? []);

    final players = playersMap.values
        .map((e) => RoomPlayer.fromMap(e as Map<dynamic, dynamic>))
        .toList()
      ..sort((a, b) => a.joinOrder.compareTo(b.joinOrder));

    return GameRoom(
      roomCode: map['roomCode']?.toString() ?? '',
      hostId: map['hostId']?.toString() ?? '',
      mode: GameModeX.fromKey(map['mode']?.toString() ?? 'classic'),
      boardSize: (map['boardSize'] as num?)?.toInt() ?? 3,
      winLength: (map['winLength'] as num?)?.toInt() ?? 3,
      status: map['status']?.toString() ?? 'waiting',
      currentTurnIndex: (map['currentTurnIndex'] as num?)?.toInt() ?? 0,
      currentSymbol: map['currentSymbol']?.toString() ?? 'X',
      nextSymbol: map['nextSymbol']?.toString(),
      board: boardRaw
          .map<List<String>>(
            (row) => (row as List<dynamic>).map((cell) => cell.toString()).toList(),
          )
          .toList(),
      players: players,
      moves: movesRaw
          .map((e) => GameMove.fromMap(e as Map<dynamic, dynamic>))
          .toList(),
      winnerUid: map['winnerUid']?.toString(),
      winnerName: map['winnerName']?.toString(),
      resultLabel: map['resultLabel']?.toString(),
      isDraw: map['isDraw'] == true,
      winningCells: winningCellsRaw
          .map<List<int>>(
            (cell) => (cell as List<dynamic>).map((e) => (e as num).toInt()).toList(),
          )
          .toList(),
    );
  }
}
