import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../data/repositories/ranking_repository.dart';
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

          final docs = snapshot.data?.docs ?? const [];

          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                ObsidianCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Clasificación global',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Ranking actualizado desde Firestore.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
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
                            CircleAvatar(
                              backgroundColor: index < 3 ? AppColors.primary.withOpacity(0.2) : AppColors.backgroundSoft,
                              child: Text('#${index + 1}'),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data['displayName']?.toString() ?? 'Jugador',
                                    style: const TextStyle(fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Victorias: ${(data['wins'] as num?)?.toInt() ?? 0} · Partidas: ${(data['matches'] as num?)?.toInt() ?? 0}',
                                    style: const TextStyle(color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${(data['totalPoints'] as num?)?.toInt() ?? 0} pts',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                              ),
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
