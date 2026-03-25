import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../shared/widgets/gold_button.dart';
import '../../shared/widgets/obsidian_card.dart';
import '../../shared/widgets/text_input_field.dart';
import 'auth_controller.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.background, AppColors.backgroundSoft],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: ObsidianCard(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceHigh,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(
                            Icons.shield_outlined,
                            color: AppColors.primary,
                            size: 30,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'TicTactic',
                          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Inicia sesión para entrar al duelo.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 24),
                        TextInputField(
                          controller: _emailController,
                          hint: 'Correo electrónico',
                          validator: Validators.email,
                        ),
                        const SizedBox(height: 14),
                        TextInputField(
                          controller: _passwordController,
                          hint: 'Contraseña',
                          obscureText: true,
                          validator: Validators.password,
                        ),
                        const SizedBox(height: 18),
                        if (auth.errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              auth.errorMessage!,
                              style: const TextStyle(color: AppColors.danger),
                            ),
                          ),
                        GoldButton(
                          label: auth.isLoading ? 'Entrando...' : 'Entrar',
                          onPressed: auth.isLoading
                              ? null
                              : () async {
                                  if (!_formKey.currentState!.validate()) return;
                                  await auth.login(
                                    email: _emailController.text,
                                    password: _passwordController.text,
                                  );
                                },
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () {
                            auth.clearError();
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const RegisterScreen()),
                            );
                          },
                          child: const Text('Crear cuenta'),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Universidad de Sonora · Juego multijugador en tiempo real',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
