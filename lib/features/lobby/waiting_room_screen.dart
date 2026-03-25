import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../data/models/game_mode.dart';
import '../../data/models/game_room.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/room_repository.dart';
import '../../shared/widgets/gold_button.dart';
import '../../shared/widgets/obsidian_card.dart';
import '../game/game_screen.dart';
import '../ranking/ranking_screen.dart';

class WaitingRoomScreen extends StatefulWidget {
  const WaitingRoomScreen({
    super.key,
    required this.mode,
  });

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
    _subscription = context.read<RoomRepository>().watchRoom(code).listen((room) {
      if (!mounted) return;
      setState(() => _room = room);

      if (room == null) return;
      if (room.isPlaying && !_openedGame) {
        _openedGame = true;
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => GameScreen(roomCode: code)),
        ).then((_) {
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
    final canStart = room != null && room.players.length >= widget.mode.minPlayersToStart;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sala de espera'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const RankingScreen()),
              );
            },
            icon: const Icon(Icons.leaderboard_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            ObsidianCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hola, ${user?.displayName ?? 'Jugador'}',
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.mode.title,
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.mode.description,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ObsidianCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Código de sala', style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 10),
                  SelectableText(
                    _roomCode ?? '------',
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                    ),
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
                    const Text('Unirse a una sala'),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _joinController,
                      textCapitalization: TextCapitalization.characters,
                      validator: Validators.roomCode,
                      decoration: const InputDecoration(hintText: 'Ingresa el código de sala'),
                    ),
                    const SizedBox(height: 16),
                    GoldButton(
                      label: _busy ? 'Uniéndote...' : 'Unirse',
                      onPressed: _busy ? null : _joinRoom,
                    ),
                  ],
                ),
              ),
            ),
            if (room != null) ...[
              const SizedBox(height: 16),
              ObsidianCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Jugadores',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                          ),
                        ),
                        Text(
                          '${room.players.length}/${widget.mode.maxPlayers}',
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...room.players.map(
                      (player) => Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundSoft,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.white10,
                              child: Text(player.symbol),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(player.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                                  Text(
                                    player.isHost ? 'Host' : 'Jugador',
                                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              player.isOnline ? Icons.circle : Icons.circle_outlined,
                              size: 12,
                              color: player.isOnline ? AppColors.success : AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
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
                ),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 14),
              Text(_error!, style: const TextStyle(color: AppColors.danger)),
            ],
          ],
        ),
      ),
    );
  }
}
