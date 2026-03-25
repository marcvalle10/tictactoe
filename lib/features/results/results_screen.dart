import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/game_mode.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/game_room.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/room_repository.dart';
import '../../features/auth/auth_controller.dart';
import '../../features/modes/mode_selection_screen.dart';
import '../../shared/widgets/app_background.dart';
import '../../shared/widgets/brand_widgets.dart';
import '../../shared/widgets/gold_button.dart';
import '../../shared/widgets/obsidian_card.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key, required this.roomCode});

  final String roomCode;

  @override
  Widget build(BuildContext context) {
    final roomRepo = context.read<RoomRepository>();
    final currentUser = context.read<AuthRepository>().currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('TicTacToe')),
      body: StreamBuilder<GameRoom?>(
        stream: roomRepo.watchRoom(roomCode),
        builder: (context, snapshot) {
          final room = snapshot.data;
          if (room == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final meWon =
              room.winnerUid != null && room.winnerUid == currentUser?.uid;
          final title =
              room.isDraw ? 'Empate' : (meWon ? '¡Ganaste!' : 'Perdiste');

          return AppBackground(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
              children: [
                ObsidianCard(
                  glow: true,
                  child: Column(
                    children: [
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary.withOpacity(.08),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(.12),
                              blurRadius: 28,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Icon(
                          room.isDraw
                              ? Icons.balance_rounded
                              : (meWon
                                  ? Icons.emoji_events_rounded
                                  : Icons.gpp_bad_rounded),
                          size: 52,
                          color: room.isDraw
                              ? AppColors.textSecondary
                              : AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 18),
                      const EyebrowText('Partida finalizada'),
                      const SizedBox(height: 8),
                      Text(
                        title,
                        style: const TextStyle(
                            fontSize: 34, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 8),
                      Text(room.mode.title,
                          style:
                              const TextStyle(color: AppColors.textSecondary)),
                      const SizedBox(height: 12),
                      Text(
                        room.isDraw
                            ? 'La partida terminó sin ganador.'
                            : 'Ganador: ${room.winnerName ?? 'Desconocido'}',
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ObsidianCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Resumen de la partida',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 14),
                      ...room.players.map(
                        (player) => Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceHigh,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: AppColors.backgroundSoft,
                                child: Text(player.symbol,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w900)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: Text(player.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700))),
                              if (room.winnerUid == player.uid)
                                const Icon(Icons.emoji_events_rounded,
                                    color: AppColors.primary),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text('Movimientos: ${room.moves.length}',
                          style:
                              const TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                GoldButton(
                  label: 'Volver a jugar',
                  icon: Icons.replay_rounded,
                  onPressed: () async {
                    await roomRepo.replayRoom(room.roomCode);
                    if (!context.mounted) return;
                    Navigator.of(context).pop();
                  },
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () async {
                    await context.read<AuthController>().signOut();
                  },
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Cerrar sesión'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
