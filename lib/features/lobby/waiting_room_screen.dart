import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../data/models/game_mode.dart';
import '../../data/models/game_room.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/room_repository.dart';
import '../../shared/widgets/app_background.dart';
import '../../shared/widgets/brand_widgets.dart';
import '../../shared/widgets/gold_button.dart';
import '../../shared/widgets/obsidian_card.dart';
import '../auth/auth_controller.dart';
import '../game/game_screen.dart';
import '../ranking/ranking_screen.dart';

class WaitingRoomScreen extends StatefulWidget {
  const WaitingRoomScreen({super.key, required this.mode});

  final GameMode mode;

  @override
  State<WaitingRoomScreen> createState() => _WaitingRoomScreenState();
}

class _WaitingRoomScreenState extends State<WaitingRoomScreen> {
  final _joinController = TextEditingController();
  final _joinFormKey = GlobalKey<FormState>();

  String? _roomCode;
  GameRoom? _room;
  String? _error;
  bool _busy = false;
  bool _openedGame = false;
  StreamSubscription<GameRoom?>? _subscription;

  @override
  void dispose() {
    _joinController.dispose();
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _createRoom() async {
    final authRepo = context.read<AuthRepository>();
    final roomRepo = context.read<RoomRepository>();
    final user = authRepo.currentUser;
    if (user == null) return;

    setState(() {
      _busy = true;
      _error = null;
      _openedGame = false;
    });

    try {
      final code = await roomRepo.createRoom(
        uid: user.uid,
        playerName: user.displayName ?? 'Jugador',
        mode: widget.mode,
      );
      _listenRoom(code);
      setState(() => _roomCode = code);
    } catch (_) {
      setState(() => _error = 'No se pudo crear la sala.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _joinRoom() async {
    final authRepo = context.read<AuthRepository>();
    final roomRepo = context.read<RoomRepository>();
    final user = authRepo.currentUser;
    if (user == null) return;
    if (!_joinFormKey.currentState!.validate()) return;

    setState(() {
      _busy = true;
      _error = null;
      _openedGame = false;
    });

    final code = _joinController.text.trim().toUpperCase();

    try {
      await roomRepo.joinRoom(
        roomCode: code,
        uid: user.uid,
        playerName: user.displayName ?? 'Jugador',
      );
      _listenRoom(code);
      setState(() => _roomCode = code);
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _listenRoom(String code) {
    _subscription?.cancel();
    _subscription =
        context.read<RoomRepository>().watchRoom(code).listen((room) {
      if (!mounted) return;
      setState(() => _room = room);

      if (room == null) return;
      if (room.isPlaying && !_openedGame) {
        _openedGame = true;
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => GameScreen(roomCode: code)))
            .then((_) {
          if (mounted) _openedGame = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authRepo = context.read<AuthRepository>();
    final roomRepo = context.read<RoomRepository>();
    final user = authRepo.currentUser;
    final room = _room;
    final canStart =
        room != null && room.players.length >= widget.mode.minPlayersToStart;

    return Scaffold(
      appBar: AppBar(
        title: const Text('TicTacToe'),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const RankingScreen()),
            ),
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
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          children: [
            ObsidianCard(
              glow: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const EyebrowText('Bienvenido de nuevo'),
                  const SizedBox(height: 8),
                  Text(
                    '¡Hola, ${user?.displayName ?? 'Jugador'}!',
                    style: const TextStyle(
                        fontSize: 32, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceHigh,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Modo seleccionado',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                widget.mode.shortTitle,
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.groups_2_rounded,
                              color: AppColors.primary),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (room != null)
              ObsidianCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: room.players.map((player) {
                        return Container(
                          width: 145,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceHigh,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 26,
                                backgroundColor: AppColors.backgroundSoft,
                                child: Text(player.symbol,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w900)),
                              ),
                              const SizedBox(height: 10),
                              Text(player.name,
                                  maxLines: 1, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              Text(
                                player.isHost ? 'Líder' : 'Listo',
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLowest,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.vpn_key_rounded,
                              color: AppColors.primary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Código de sala',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary)),
                                const SizedBox(height: 4),
                                SelectableText(
                                  _roomCode ?? room.roomCode,
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              final codeToCopy = _roomCode ?? room.roomCode;

                              await Clipboard.setData(
                                  ClipboardData(text: codeToCopy));

                              if (!mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Código copiado al portapapeles'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            icon: const Icon(Icons.copy_rounded,
                                color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else
              ObsidianCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tu código',
                        style: TextStyle(color: AppColors.textSecondary)),
                    const SizedBox(height: 10),
                    Text(
                      _roomCode ?? '------',
                      style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4),
                    ),
                    const SizedBox(height: 16),
                    GoldButton(
                      label: _busy ? 'Creando...' : 'Crear sala',
                      icon: Icons.add_circle_outline,
                      onPressed: _busy ? null : _createRoom,
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            ObsidianCard(
              child: Form(
                key: _joinFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Unirse a partida',
                        style: TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _joinController,
                      textCapitalization: TextCapitalization.characters,
                      validator: Validators.roomCode,
                      decoration: const InputDecoration(
                        labelText: 'CÓDIGO DE SALA',
                        hintText: 'Ingresa el código de sala',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => const RankingScreen()),
                            ),
                            icon: const Icon(Icons.emoji_events_outlined),
                            label: const Text('Ver ranking'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GoldButton(
                            label: _busy ? 'Uniéndote...' : 'Unirse',
                            onPressed: _busy ? null : _joinRoom,
                            height: 56,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (room != null) ...[
              const SizedBox(height: 16),
              GoldButton(
                label: room.isPlaying ? 'Partida en curso' : 'Iniciar partida',
                onPressed: canStart && !room.isPlaying
                    ? () async {
                        try {
                          await roomRepo.startMatch(room.roomCode);
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.toString())),
                          );
                        }
                      }
                    : null,
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!,
                  style: const TextStyle(
                      color: AppColors.danger, fontWeight: FontWeight.w700)),
            ],
          ],
        ),
      ),
    );
  }
}
