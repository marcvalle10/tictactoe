import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../auth/login_screen.dart';
import '../modes/mode_selection_screen.dart';

class HomeGate extends StatelessWidget {
  const HomeGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data == null) {
          return const LoginScreen();
        }

        return const ModeSelectionScreen();
      },
    );
  }
}
