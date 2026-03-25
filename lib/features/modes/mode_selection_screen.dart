import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/game_mode.dart';
import '../../data/repositories/auth_repository.dart';
import '../../features/auth/auth_controller.dart';
import '../../features/lobby/waiting_room_screen.dart';
import '../../features/ranking/ranking_screen.dart';
import '../../shared/widgets/gold_button.dart';
import '../../shared/widgets/obsidian_card.dart';

class ModeSelectionScreen extends StatefulWidget {
  const ModeSelectionScreen({super.key});

  @override
  State<ModeSelectionScreen> createState() => _ModeSelectionScreenState();
}

class _ModeSelectionScreenState extends State<ModeSelectionScreen> {
  GameMode _selectedMode = GameMode.classic;

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthRepository>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Elige tu desafío'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const RankingScreen()),
              );
            },
            icon: const Icon(Icons.emoji_events_outlined),
          ),
          IconButton(
            onPressed: () => context.read<AuthController>().signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Hola, ${user?.displayName ?? 'Jugador'}',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Selecciona un modo antes de crear o unirte a una sala.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            ...GameMode.values.map((mode) {
              final selected = _selectedMode == mode;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedMode = mode),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: selected ? AppColors.primary : Colors.transparent,
                        width: 1.2,
                      ),
                      boxShadow: selected
                          ? const [
                              BoxShadow(
                                color: Color(0x22F0C94D),
                                blurRadius: 20,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: ObsidianCard(
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  mode.title,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  mode.description,
                                  style: const TextStyle(color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            selected ? Icons.check_circle : Icons.radio_button_off,
                            color: selected ? AppColors.primary : AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
            GoldButton(
              label: 'Continuar',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => WaitingRoomScreen(mode: _selectedMode),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
