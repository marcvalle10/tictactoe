import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import 'package:firebase_database/firebase_database.dart' as rtdb;

import '../models/game_mode.dart';
import '../models/game_room.dart';
import '../models/room_player.dart';

class MoveOutcome {
  final bool success;
  final String? error;
  final bool gameFinished;

  const MoveOutcome({
    required this.success,
    this.error,
    this.gameFinished = false,
  });
}

class _WinResult {
  final String winnerSymbol;
  final List<List<int>> cells;

  const _WinResult({
    required this.winnerSymbol,
    required this.cells,
  });
}

class RoomRepository {
  final rtdb.FirebaseDatabase _database = rtdb.FirebaseDatabase.instance;
  final fs.FirebaseFirestore _firestore = fs.FirebaseFirestore.instance;

  rtdb.DatabaseReference get _roomsRef => _database.ref('rooms');

  static const List<String> _rotatingSymbols = ['X', 'O', '△', '□'];

  String generateRoomCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random();
    return List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
  }

  List<List<String>> _emptyBoard(int size) {
    return List.generate(size, (_) => List.generate(size, (_) => ''));
  }

  List<Map<String, String>> _symbolPalette(GameMode mode) {
    switch (mode) {
      case GameMode.classic:
        return const [
          {'symbol': 'X', 'color': '#55E6DB'},
          {'symbol': 'O', 'color': '#FFB3B5'},
        ];
      case GameMode.multiplayer4:
      case GameMode.rotatingSymbols:
        return const [
          {'symbol': 'X', 'color': '#55E6DB'},
          {'symbol': 'O', 'color': '#FFB3B5'},
          {'symbol': '△', 'color': '#B88CFF'},
          {'symbol': '□', 'color': '#F3D95A'},
        ];
    }
  }

  Future<String> createRoom({
    required String uid,
    required String playerName,
    required GameMode mode,
  }) async {
    String code = generateRoomCode();
    while ((await _roomsRef.child(code).get()).exists) {
      code = generateRoomCode();
    }

    final palette = _symbolPalette(mode);

    final player = RoomPlayer(
      uid: uid,
      name: playerName,
      symbol: palette.first['symbol']!,
      colorHex: palette.first['color']!,
      isHost: true,
      isOnline: true,
      score: 0,
      joinOrder: 0,
    );

    final now = DateTime.now().millisecondsSinceEpoch;

    await _roomsRef.child(code).set({
      'roomCode': code,
      'hostId': uid,
      'mode': mode.key,
      'boardSize': mode.boardSize,
      'winLength': mode.winLength,
      'status': 'waiting',
      'currentTurnIndex': 0,
      'currentSymbol': mode == GameMode.rotatingSymbols
          ? _rotatingSymbols.first
          : player.symbol,
      'nextSymbol':
          mode == GameMode.rotatingSymbols ? _rotatingSymbols[1] : null,
      'winnerUid': null,
      'winnerName': null,
      'resultLabel': null,
      'isDraw': false,
      'winningCells': <List<int>>[],
      'createdAt': now,
      'updatedAt': now,
      'players': {uid: player.toMap()},
      'moves': <Map<String, dynamic>>[],
      'board': _emptyBoard(mode.boardSize),
    });

    return code;
  }

  Future<void> joinRoom({
    required String roomCode,
    required String uid,
    required String playerName,
  }) async {
    final roomRef = _roomsRef.child(roomCode.toUpperCase());
    final snapshot = await roomRef.get();

    if (!snapshot.exists) throw Exception('La sala no existe');

    final value = snapshot.value;
    if (value == null) throw Exception('Datos inválidos');

    final room = GameRoom.fromMap(value as Map<dynamic, dynamic>);

    if (room.players.any((p) => p.uid == uid)) {
      await roomRef.child('players').child(uid).update({'isOnline': true});
      return;
    }

    if (room.players.length >= room.mode.maxPlayers) {
      throw Exception('La sala ya está llena');
    }

    if (room.isFinished) {
      throw Exception('La partida ya terminó');
    }

    final palette = _symbolPalette(room.mode);
    final assigned = palette[min(room.players.length, palette.length - 1)];

    final player = RoomPlayer(
      uid: uid,
      name: playerName,
      symbol: assigned['symbol']!,
      colorHex: assigned['color']!,
      isHost: false,
      isOnline: true,
      score: 0,
      joinOrder: room.players.length,
    );

    await roomRef.child('players').child(uid).set(player.toMap());

    final nextStatus = room.players.length + 1 >= room.mode.minPlayersToStart
        ? 'ready'
        : 'waiting';

    await roomRef.update({
      'status': nextStatus,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Stream<GameRoom?> watchRoom(String roomCode) {
    return _roomsRef.child(roomCode.toUpperCase()).onValue.map((event) {
      final value = event.snapshot.value;
      if (value == null) return null;
      return GameRoom.fromMap(value as Map<dynamic, dynamic>);
    });
  }

  Future<void> startMatch(String roomCode) async {
    final roomRef = _roomsRef.child(roomCode.toUpperCase());
    final snapshot = await roomRef.get();

    if (!snapshot.exists) return;

    final value = snapshot.value;
    if (value == null) return;

    final room = GameRoom.fromMap(value as Map<dynamic, dynamic>);

    if (room.players.length < room.mode.minPlayersToStart) {
      throw Exception('Aún faltan jugadores');
    }

    final firstPlayer = room.players.first;

    await roomRef.update({
      'status': 'playing',
      'board': _emptyBoard(room.boardSize),
      'moves': <Map<String, dynamic>>[],
      'currentTurnIndex': 0,
      'currentSymbol': room.mode == GameMode.rotatingSymbols
          ? _rotatingSymbols.first
          : firstPlayer.symbol,
      'nextSymbol':
          room.mode == GameMode.rotatingSymbols ? _rotatingSymbols[1] : null,
      'winnerUid': null,
      'winnerName': null,
      'resultLabel': null,
      'isDraw': false,
      'winningCells': <List<int>>[],
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<MoveOutcome> makeMove({
    required String roomCode,
    required String uid,
    required int row,
    required int col,
  }) async {
    final roomRef = _roomsRef.child(roomCode.toUpperCase());

    final rtdb.TransactionResult tx =
        await roomRef.runTransaction((currentData) {
      if (currentData == null) {
        return rtdb.Transaction.abort();
      }

      final map = Map<dynamic, dynamic>.from(currentData as Map);
      final room = GameRoom.fromMap(map);

      if (room.status != 'playing') {
        return rtdb.Transaction.abort();
      }

      if (row < 0 ||
          col < 0 ||
          row >= room.boardSize ||
          col >= room.boardSize) {
        return rtdb.Transaction.abort();
      }

      final currentPlayer = room.currentPlayer;
      if (currentPlayer == null || currentPlayer.uid != uid) {
        return rtdb.Transaction.abort();
      }

      if (room.board[row][col].isNotEmpty) {
        return rtdb.Transaction.abort();
      }

      final symbol = room.mode == GameMode.rotatingSymbols
          ? room.currentSymbol
          : currentPlayer.symbol;

      final board = room.board.map((e) => List<String>.from(e)).toList();
      board[row][col] = symbol;

      final moves = room.moves.map((e) => e.toMap()).toList();

      final move = GameMove(
        playerUid: currentPlayer.uid,
        playerName: currentPlayer.name,
        symbol: symbol,
        row: row,
        col: col,
        moveNumber: room.moves.length + 1,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );

      moves.add(move.toMap());

      final win = _findWinner(board, room.winLength);
      final draw =
          win == null && moves.length >= room.boardSize * room.boardSize;

      final nextTurn = (room.currentTurnIndex + 1) % room.players.length;
      final nextPlayer = room.players[nextTurn];

      final nextSymbol = room.mode == GameMode.rotatingSymbols
          ? _rotatingSymbols[moves.length % _rotatingSymbols.length]
          : nextPlayer.symbol;

      final updated = <String, dynamic>{
        ...map.map((k, v) => MapEntry(k.toString(), v)),
        'board': board,
        'moves': moves,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      };

      if (win != null) {
        updated.addAll({
          'status': 'finished',
          'winnerUid': currentPlayer.uid,
          'winnerName': currentPlayer.name,
          'isDraw': false,
          'winningCells': win.cells,
        });
      } else if (draw) {
        updated.addAll({
          'status': 'finished',
          'isDraw': true,
          'winningCells': <List<int>>[],
        });
      } else {
        updated.addAll({
          'currentTurnIndex': nextTurn,
          'currentSymbol': nextSymbol,
        });
      }

      return rtdb.Transaction.success(updated);
    });

    final value = tx.snapshot.value;
    if (!tx.committed || value == null) {
      return const MoveOutcome(success: false, error: 'Movimiento inválido');
    }

    final room = GameRoom.fromMap(value as Map<dynamic, dynamic>);

    if (room.isFinished) {
      await _persistFinishedGame(room);
      return const MoveOutcome(success: true, gameFinished: true);
    }

    return const MoveOutcome(success: true);
  }

  Future<void> replayRoom(String roomCode) async {
    final roomRef = _roomsRef.child(roomCode.toUpperCase());
    final snapshot = await roomRef.get();

    if (!snapshot.exists) return;

    final value = snapshot.value;
    if (value == null) return;

    final room = GameRoom.fromMap(value as Map<dynamic, dynamic>);
    final firstPlayer = room.players.isNotEmpty ? room.players.first : null;

    await roomRef.update({
      'status': room.players.length >= room.mode.minPlayersToStart
          ? 'ready'
          : 'waiting',
      'board': _emptyBoard(room.boardSize),
      'moves': <Map<String, dynamic>>[],
      'currentTurnIndex': 0,
      'currentSymbol': room.mode == GameMode.rotatingSymbols
          ? _rotatingSymbols.first
          : (firstPlayer?.symbol ?? 'X'),
      'nextSymbol':
          room.mode == GameMode.rotatingSymbols ? _rotatingSymbols[1] : null,
      'winnerUid': null,
      'winnerName': null,
      'resultLabel': null,
      'isDraw': false,
      'winningCells': <List<int>>[],
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> leaveRoom({
    required String roomCode,
    required String uid,
  }) async {
    final roomRef = _roomsRef.child(roomCode.toUpperCase());
    final snapshot = await roomRef.get();

    if (!snapshot.exists) return;

    final value = snapshot.value;
    if (value == null) return;

    final room = GameRoom.fromMap(value as Map<dynamic, dynamic>);

    if (!room.players.any((p) => p.uid == uid)) return;

    await roomRef.child('players').child(uid).remove();

    final updatedSnapshot = await roomRef.get();
    if (!updatedSnapshot.exists) return;

    final updatedValue = updatedSnapshot.value;
    if (updatedValue == null) return;

    final updatedRoom = GameRoom.fromMap(updatedValue as Map<dynamic, dynamic>);

    if (updatedRoom.players.isEmpty) {
      await roomRef.remove();
      return;
    }

    if (updatedRoom.currentTurnIndex >= updatedRoom.players.length) {
      await roomRef.update({'currentTurnIndex': 0});
    }
  }

  Future<void> _persistFinishedGame(GameRoom room) async {
    final matchRef = _firestore.collection('match_history').doc();

    await matchRef.set({
      'matchId': matchRef.id,
      'roomCode': room.roomCode,
      'mode': room.mode.key,
      'playerNames': room.players.map((e) => e.name).toList(),
      'playerIds': room.players.map((e) => e.uid).toList(),
      'moves': room.moves.map((e) => e.toMap()).toList(),
      'winnerUid': room.winnerUid,
      'winnerName': room.winnerName,
      'isDraw': room.isDraw,
      'createdAt': fs.FieldValue.serverTimestamp(),
    });

    for (final player in room.players) {
      final isWinner = room.winnerUid == player.uid;
      final isDraw = room.isDraw;
      final points = isWinner ? 10 : (isDraw ? 3 : 1);

      await _firestore.collection('users').doc(player.uid).set({
        'uid': player.uid,
        'displayName': player.name,
        'matches': fs.FieldValue.increment(1),
        'wins': fs.FieldValue.increment(isWinner ? 1 : 0),
        'draws': fs.FieldValue.increment(isDraw ? 1 : 0),
        'losses': fs.FieldValue.increment(!isWinner && !isDraw ? 1 : 0),
        'totalPoints': fs.FieldValue.increment(points),
        'updatedAt': fs.FieldValue.serverTimestamp(),
      }, fs.SetOptions(merge: true));

      await _firestore.collection('leaderboard').doc(player.uid).set({
        'uid': player.uid,
        'displayName': player.name,
        'wins': fs.FieldValue.increment(isWinner ? 1 : 0),
        'matches': fs.FieldValue.increment(1),
        'totalPoints': fs.FieldValue.increment(points),
        'updatedAt': fs.FieldValue.serverTimestamp(),
      }, fs.SetOptions(merge: true));
    }
  }

  _WinResult? _findWinner(List<List<String>> board, int winLength) {
    final size = board.length;
    if (size == 0) return null;

    const directions = <List<int>>[
      [0, 1],
      [1, 0],
      [1, 1],
      [1, -1],
    ];

    for (int row = 0; row < size; row++) {
      for (int col = 0; col < size; col++) {
        final symbol = board[row][col];
        if (symbol.isEmpty) continue;

        for (final dir in directions) {
          final dr = dir[0];
          final dc = dir[1];
          final cells = <List<int>>[
            [row, col]
          ];

          for (int step = 1; step < winLength; step++) {
            final nr = row + dr * step;
            final nc = col + dc * step;

            if (nr < 0 || nc < 0 || nr >= size || nc >= size) break;
            if (board[nr][nc] != symbol) break;

            cells.add([nr, nc]);
          }

          if (cells.length == winLength) {
            return _WinResult(
              winnerSymbol: symbol,
              cells: cells,
            );
          }
        }
      }
    }

    return null;
  }
}
