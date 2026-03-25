import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../data/repositories/ranking_repository.dart';
import '../../shared/widgets/app_background.dart';
import '../../shared/widgets/brand_widgets.dart';
import '../../shared/widgets/obsidian_card.dart';

class RankingScreen extends StatelessWidget {
  const RankingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.read<RankingRepository>();

    return Scaffold(
      appBar: AppBar(title: const Text('Top 10 jugadores')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: repo.top10(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return AppBackground(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Error al cargar ranking:\n${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? const [];

          return AppBackground(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
              children: [
                const EyebrowText('Top 10 Jugadores'),
                const SizedBox(height: 8),
                const Text(
                  'Clasificación global',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Los datos se obtienen en tiempo real desde la base de datos de partidas.',
                  style:
                      TextStyle(color: AppColors.textSecondary, height: 1.45),
                ),
                const SizedBox(height: 18),
                if (docs.length >= 3)
                  ObsidianCard(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                            child: _PodiumCard(
                                rank: 2, data: docs[1].data(), height: 120)),
                        const SizedBox(width: 10),
                        Expanded(
                            child: _PodiumCard(
                                rank: 1,
                                data: docs[0].data(),
                                height: 150,
                                highlight: true)),
                        const SizedBox(width: 10),
                        Expanded(
                            child: _PodiumCard(
                                rank: 3, data: docs[2].data(), height: 108)),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                if (docs.isEmpty)
                  const ObsidianCard(
                    child: Text('Aún no hay datos de ranking.'),
                  )
                else
                  ...docs.asMap().entries.map((entry) {
                    final index = entry.key;
                    final data = entry.value.data();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ObsidianCard(
                        child: Row(
                          children: [
                            SizedBox(
                              width: 40,
                              child: Text(
                                '#${index + 1}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            const CircleAvatar(
                              radius: 18,
                              backgroundColor: AppColors.surfaceHigh,
                              child: Icon(Icons.person_outline_rounded,
                                  color: AppColors.textPrimary, size: 18),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data['displayName']?.toString() ??
                                        'Jugador',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Partidas ${(data['matches'] as num?)?.toInt() ?? 0}',
                                    style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${(data['wins'] as num?)?.toInt() ?? 0}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 18),
                                ),
                                const Text(
                                  'victorias',
                                  style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 11),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PodiumCard extends StatelessWidget {
  const _PodiumCard({
    required this.rank,
    required this.data,
    required this.height,
    this.highlight = false,
  });

  final int rank;
  final Map<String, dynamic> data;
  final double height;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: highlight
            ? AppColors.primary.withOpacity(.18)
            : AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(
              rank == 1
                  ? Icons.workspace_premium_rounded
                  : Icons.emoji_events_outlined,
              color: AppColors.primary),
          const SizedBox(height: 8),
          Text(
            data['displayName']?.toString() ?? 'Jugador',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text('${(data['wins'] as num?)?.toInt() ?? 0} victorias',
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}
