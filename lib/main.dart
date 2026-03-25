import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/ranking_repository.dart';
import 'data/repositories/room_repository.dart';
import 'features/auth/auth_controller.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthRepository>(create: (_) => AuthRepository()),
        Provider<RankingRepository>(create: (_) => RankingRepository()),
        Provider<RoomRepository>(create: (_) => RoomRepository()),
        ChangeNotifierProvider<AuthController>(
          create: (context) => AuthController(context.read<AuthRepository>()),
        ),
      ],
      child: const TicTacticApp(),
    ),
  );
}
