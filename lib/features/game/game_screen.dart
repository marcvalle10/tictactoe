import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/game_mode.dart';
import '../../data/models/game_room.dart';
import '../../data/models/room_player.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/room_repository.dart';
import '../../shared/widgets/obsidian_card.dart';
import '../results/results_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    required this.roomCode,
  });

  final String roomCode;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool _resultShown = false;
  bool _processingMove = false;

  @override
  Widget build(BuildContext context) {
    final roomRepo = context.read<RoomRepository>();
    final currentUser = context.read<AuthRepository>().currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Partida')),
      body: StreamBuilder<GameRoom?>(
        stream: roomRepo.watchRoom(widget.roomCode),
        builder: (context, snapshot) {
          final room = snapshot.data;
          if (room == null) {
            return const Center(child: CircularProgressIndicator());
          }

          RoomPlayer? me;
          for (final player in room.players) {
            if (player.uid == currentUser?.uid) {
              me = player;
              break;
            }
          }
          final activePlayer = room.currentPlayer;
          final isMyTurn = me != null && activePlayer?.uid == me.uid && room.isPlaying;

          if (room.isFinished && !_resultShown) {
            _resultShown = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => ResultsScreen(roomCode: widget.roomCode),
                ),
              );
            });
          }

          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                ObsidianCard(
                  child: Column(
                    children: [
                      Text(
                        room.mode.title,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isMyTurn ? 'Tu turno' : 'Turno de ${activePlayer?.name ?? 'otro jugador'}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isMyTurn ? AppColors.primary : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (room.mode == GameMode.rotatingSymbols) ...[
                        Text(
                          'Símbolo actual: ${room.currentSymbol}',
                          style: const TextStyle(color: AppColors.xColor, fontWeight: FontWeight.w700),
                        ),
                        if (room.nextSymbol != null)
                          Text(
                            'Siguiente: ${room.nextSymbol}',
                            style: const TextStyle(color: AppColors.textSecondary),
                          ),
                      ] else if (activePlayer != null) ...[
                        Text(
                          'Símbolo activo: ${activePlayer.symbol}',
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ObsidianCard(
                  child: Wrap(
                    runSpacing: 10,
                    spacing: 10,
                    children: room.players.map((player) {
                      final isActive = activePlayer?.uid == player.uid && room.isPlaying;
                      return Container(
                        width: 155,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.surfaceHigher : AppColors.backgroundSoft,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isActive ? AppColors.primary : Colors.transparent,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(player.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text('Símbolo: ${player.symbol}'),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: SizedBox(
                    width: 360,
                    height: 360,
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: room.boardSize * room.boardSize,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: room.boardSize,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                      ),
                      itemBuilder: (context, index) {
                        final row = index ~/ room.boardSize;
                        final col = index % room.boardSize;
                        final value = room.board[row][col];
                        final isWinning = room.winningCells.any((e) => e[0] == row && e[1] == col);

                        return GestureDetector(
                          onTap: !isMyTurn || value.isNotEmpty || _processingMove
                              ? null
                              : () async {
                                  setState(() => _processingMove = true);
                                  await roomRepo.makeMove(
                                    roomCode: room.roomCode,
                                    uid: me!.uid,
                                    row: row,
                                    col: col,
                                  );
                                  if (mounted) setState(() => _processingMove = false);
                                },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            decoration: BoxDecoration(
                              color: isWinning ? AppColors.primary.withOpacity(0.18) : AppColors.backgroundSoft,
                              borderRadius: BorderRadius.circular(room.boardSize == 3 ? 18 : 12),
                              border: Border.all(
                                color: isWinning ? AppColors.primary : AppColors.surfaceHigher,
                                width: isWinning ? 1.4 : 1,
                              ),
                            ),
                            child: Center(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 180),
                                child: Text(
                                  value,
                                  key: ValueKey('${row}_${col}_$value'),
                                  style: TextStyle(
                                    fontSize: room.boardSize == 3 ? 32 : 24,
                                    fontWeight: FontWeight.w900,
                                    color: _symbolColor(value),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ObsidianCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Historial de jugadas',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 12),
                      if (room.moves.isEmpty)
                        const Text('Aún no hay movimientos.', style: TextStyle(color: AppColors.textSecondary))
                      else
                        ...room.moves.reversed.take(6).map(
                          (move) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              '${move.moveNumber}. ${move.playerName} puso ${move.symbol} en (${move.row + 1}, ${move.col + 1})',
                              style: const TextStyle(color: AppColors.textSecondary),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _symbolColor(String value) {
    switch (value) {
      case 'X':
        return AppColors.xColor;
      case 'O':
        return AppColors.oColor;
      case '△':
        return AppColors.triangleColor;
      case '□':
        return AppColors.squareColor;
      default:
        return AppColors.textPrimary;
    }
  }
}
