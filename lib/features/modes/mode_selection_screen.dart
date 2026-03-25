import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/game_mode.dart';
import '../../data/repositories/auth_repository.dart';
import '../../features/auth/auth_controller.dart';
import '../../features/lobby/waiting_room_screen.dart';
import '../../features/ranking/ranking_screen.dart';
import '../../shared/widgets/app_background.dart';
import '../../shared/widgets/brand_widgets.dart';
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
        title: const Text('TicTacToe'),
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
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: AppBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
          children: [
            const EyebrowText('Selección de juego'),
            const SizedBox(height: 8),
            const Text(
              'Elige tu desafío',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              'Bienvenido de nuevo, ${user?.displayName ?? 'Jugador'}. Selecciona el modo que se adapte a tu estilo.',
              style:
                  const TextStyle(color: AppColors.textSecondary, height: 1.45),
            ),
            const SizedBox(height: 24),
            ...GameMode.values.map((mode) {
              final selected = _selectedMode == mode;
              return Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedMode = mode),
                  child: ObsidianCard(
                    glow: selected,
                    color: selected
                        ? AppColors.surfaceHigh
                        : AppColors.surfaceContainer,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    mode.shortTitle,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    mode.description,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                switch (mode) {
                                  GameMode.classic => Icons.grid_3x3_rounded,
                                  GameMode.multiplayer4 => Icons.groups_rounded,
                                  GameMode.rotatingSymbols =>
                                    Icons.sync_rounded,
                                },
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Align(
                          alignment: Alignment.center,
                          child: _ModePreview(mode: mode),
                        ),
                        if (selected) ...[
                          const SizedBox(height: 12),
                          const Align(
                            alignment: Alignment.centerRight,
                            child: Icon(Icons.check_circle,
                                color: AppColors.primary),
                          )
                        ]
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 6),
            GoldButton(
              label: 'CONTINUAR',
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

class _ModePreview extends StatelessWidget {
  const _ModePreview({required this.mode});

  final GameMode mode;

  @override
  Widget build(BuildContext context) {
    switch (mode) {
      case GameMode.classic:
        return SizedBox(
          width: 110,
          child: GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            crossAxisCount: 3,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            children: const [
              _MiniCell(symbol: 'X', color: AppColors.xColor),
              _MiniCell(),
              _MiniCell(),
              _MiniCell(),
              _MiniCell(symbol: 'O', color: AppColors.oColor),
              _MiniCell(),
              _MiniCell(),
              _MiniCell(),
              _MiniCell(),
            ],
          ),
        );
      case GameMode.multiplayer4:
        return SizedBox(
          width: 170,
          child: GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            crossAxisCount: 6,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            children: List.generate(18, (index) {
              final symbols = {
                0: const _MiniCell(symbol: 'X', color: AppColors.xColor),
                3: const _MiniCell(symbol: '△', color: AppColors.triangleColor),
                7: const _MiniCell(symbol: 'O', color: AppColors.oColor),
                10: const _MiniCell(symbol: '□', color: AppColors.squareColor),
              };
              return symbols[index] ?? const _MiniCell(tight: true);
            }),
          ),
        );
      case GameMode.rotatingSymbols:
        return const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _PreviewFlow(symbol: 'X', color: AppColors.xColor),
            SizedBox(width: 18),
            Icon(Icons.south_rounded, color: AppColors.textSecondary),
            SizedBox(width: 18),
            _PreviewFlow(symbol: 'O', color: AppColors.oColor),
            SizedBox(width: 18),
            Icon(Icons.south_rounded, color: AppColors.textSecondary),
            SizedBox(width: 18),
            _PreviewFlow(symbol: '△', color: AppColors.triangleColor),
          ],
        );
    }
  }
}

class _MiniCell extends StatelessWidget {
  const _MiniCell(
      {this.symbol = '',
      this.color = AppColors.textPrimary,
      this.tight = false});

  final String symbol;
  final Color color;
  final bool tight;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceHigher,
        borderRadius: BorderRadius.circular(tight ? 6 : 10),
      ),
      child: Center(
        child: Text(
          symbol,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w900,
            fontSize: tight ? 10 : 16,
          ),
        ),
      ),
    );
  }
}

class _PreviewFlow extends StatelessWidget {
  const _PreviewFlow({required this.symbol, required this.color});

  final String symbol;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(symbol,
            style: TextStyle(
                color: color, fontSize: 26, fontWeight: FontWeight.w900)),
        const SizedBox(height: 6),
        const Text('turno',
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }
}
