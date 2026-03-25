import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/game_mode.dart';
import '../../data/models/game_room.dart';
import '../../data/models/room_player.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/room_repository.dart';
import '../../shared/widgets/app_background.dart';
import '../../shared/widgets/brand_widgets.dart';
import '../../shared/widgets/obsidian_card.dart';
import '../results/results_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.roomCode});

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
      appBar: AppBar(
        title: const Text('TicTacToe'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(child: SoftStatusDot(color: AppColors.success)),
          ),
        ],
      ),
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
                MaterialPageRoute(builder: (_) => ResultsScreen(roomCode: widget.roomCode)),
              );
            });
          }

          return AppBackground(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
              children: [
                ObsidianCard(
                  glow: true,
                  child: Column(
                    children: [
                      const EyebrowText('Estado del juego'),
                      const SizedBox(height: 10),
                      Text(
                        isMyTurn ? 'Tu turno' : 'Turno de ${activePlayer?.name ?? 'otro jugador'}',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          color: isMyTurn ? AppColors.primary : AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        room.mode == GameMode.rotatingSymbols
                            ? 'Símbolo actual ${room.currentSymbol}${room.nextSymbol != null ? ' · siguiente ${room.nextSymbol}' : ''}'
                            : '${activePlayer?.name ?? '--'} juega con ${activePlayer?.symbol ?? '--'}',
                        style: const TextStyle(color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: room.players.map((player) {
                      final isActive = activePlayer?.uid == player.uid && room.isPlaying;
                      final tone = _symbolColor(player.symbol);
                      return Container(
                        width: 162,
                        margin: const EdgeInsets.only(right: 12),
                        child: ObsidianCard(
                          color: isActive ? AppColors.surfaceHigh : AppColors.surfaceContainer,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      player.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontWeight: FontWeight.w800),
                                    ),
                                  ),
                                  if (isActive) const SoftStatusDot(color: AppColors.primary),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                player.symbol,
                                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: tone),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Puntaje: ${player.score}',
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                ObsidianCard(
                  color: AppColors.surfaceContainer,
                  padding: const EdgeInsets.all(18),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final size = constraints.maxWidth;
                        final spacing = room.boardSize == 3 ? 10.0 : 8.0;
                        final cellSize = (size - (spacing * (room.boardSize - 1))) / room.boardSize;
                        return Stack(
                          children: [
                            GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: room.boardSize * room.boardSize,
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: room.boardSize,
                                mainAxisSpacing: spacing,
                                crossAxisSpacing: spacing,
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
                                      color: isWinning ? AppColors.surfaceHigher : AppColors.surfaceHigh,
                                      borderRadius: BorderRadius.circular(room.boardSize == 3 ? 18 : 12),
                                      boxShadow: isWinning
                                          ? [
                                              BoxShadow(
                                                color: AppColors.primary.withOpacity(.18),
                                                blurRadius: 18,
                                                spreadRadius: 1,
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: Center(
                                      child: AnimatedScale(
                                        duration: const Duration(milliseconds: 180),
                                        scale: value.isEmpty ? .7 : 1,
                                        child: Text(
                                          value,
                                          style: TextStyle(
                                            fontSize: room.boardSize == 3 ? 38 : 26,
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
                            if (room.winningCells.length >= 2)
                              IgnorePointer(
                                child: CustomPaint(
                                  size: Size.square(size),
                                  painter: _WinningLinePainter(
                                    winningCells: room.winningCells,
                                    cellSize: cellSize,
                                    spacing: spacing,
                                  ),
                                ),
                              ),
                          ],
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
                      const Text('Historial de jugadas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 12),
                      if (room.moves.isEmpty)
                        const Text('Aún no hay movimientos.', style: TextStyle(color: AppColors.textSecondary))
                      else
                        ...room.moves.reversed.take(6).map(
                          (move) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              '${move.moveNumber}. ${move.playerName} jugó ${move.symbol} en (${move.row + 1}, ${move.col + 1})',
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

class _WinningLinePainter extends CustomPainter {
  _WinningLinePainter({
    required this.winningCells,
    required this.cellSize,
    required this.spacing,
  });

  final List<List<int>> winningCells;
  final double cellSize;
  final double spacing;

  @override
  void paint(Canvas canvas, Size size) {
    if (winningCells.length < 2) return;

    Offset centerOf(List<int> cell) {
      final row = cell[0].toDouble();
      final col = cell[1].toDouble();
      final dx = col * (cellSize + spacing) + cellSize / 2;
      final dy = row * (cellSize + spacing) + cellSize / 2;
      return Offset(dx, dy);
    }

    final start = centerOf(winningCells.first);
    final end = centerOf(winningCells.last);

    final glow = Paint()
      ..color = AppColors.primary.withOpacity(.24)
      ..strokeWidth = 18
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    final line = Paint()
      ..shader = const LinearGradient(
        colors: [AppColors.primary, AppColors.primaryDark],
      ).createShader(Rect.fromPoints(start, end))
      ..strokeWidth = 7
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(start, end, glow);
    canvas.drawLine(start, end, line);
  }

  @override
  bool shouldRepaint(covariant _WinningLinePainter oldDelegate) {
    return oldDelegate.winningCells != winningCells ||
        oldDelegate.cellSize != cellSize ||
        oldDelegate.spacing != spacing;
  }
}
