import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/game_mode.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/game_room.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/room_repository.dart';
import '../../features/auth/auth_controller.dart';
import '../../features/modes/mode_selection_screen.dart';
import '../../shared/widgets/gold_button.dart';
import '../../shared/widgets/obsidian_card.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({
    super.key,
    required this.roomCode,
  });

  final String roomCode;

  @override
  Widget build(BuildContext context) {
    final roomRepo = context.read<RoomRepository>();
    final currentUser = context.read<AuthRepository>().currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Resultados')),
      body: StreamBuilder<GameRoom?>(
        stream: roomRepo.watchRoom(roomCode),
        builder: (context, snapshot) {
          final room = snapshot.data;
          if (room == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final meWon =
              room.winnerUid != null && room.winnerUid == currentUser?.uid;
          final title = room.isDraw
              ? 'Empate'
              : meWon
                  ? '¡Ganaste!'
                  : 'Perdiste';

          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                ObsidianCard(
                  child: Column(
                    children: [
                      Icon(
                        room.isDraw
                            ? Icons.balance
                            : (meWon
                                ? Icons.emoji_events
                                : Icons.flag_outlined),
                        size: 54,
                        color: room.isDraw
                            ? AppColors.textSecondary
                            : AppColors.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        title,
                        style: const TextStyle(
                            fontSize: 30, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        room.mode.title,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        room.isDraw
                            ? 'La partida terminó sin ganador.'
                            : 'Ganador: ${room.winnerName ?? 'Desconocido'}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ObsidianCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Resumen de la partida',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 12),
                      ...room.players.map(
                        (player) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Expanded(child: Text(player.name)),
                              Text(player.symbol),
                              const SizedBox(width: 10),
                              if (room.winnerUid == player.uid)
                                const Icon(Icons.emoji_events,
                                    color: AppColors.primary),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Movimientos: ${room.moves.length}',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                GoldButton(
                  label: 'Volver a jugar',
                  icon: Icons.replay,
                  onPressed: () async {
                    await roomRepo.replayRoom(room.roomCode);
                    if (!context.mounted) return;
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (_) => const ModeSelectionScreen()),
                      (route) => false,
                    );
                  },
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () async {
                    await context.read<AuthController>().signOut();
                  },
                  icon: const Icon(Icons.logout),
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
