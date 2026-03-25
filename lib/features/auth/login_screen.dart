import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../shared/widgets/app_background.dart';
import '../../shared/widgets/brand_widgets.dart';
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

bool _obscurePassword = true;

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
      body: AppBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    const Center(child: UniSonBadge(size: 84)),
                    const SizedBox(height: 20),
                    const Center(child: EyebrowText('Universidad de Sonora')),
                    const SizedBox(height: 8),
                    const Text(
                      'TicTacToe',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Inicia sesión para entrar al duelo competitivo en tiempo real.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppColors.textSecondary, height: 1.45),
                    ),
                    const SizedBox(height: 28),
                    ObsidianCard(
                      glow: true,
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceHigh,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 44,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          AppColors.primary,
                                          AppColors.primaryDark
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    alignment: Alignment.center,
                                    child: const Text(
                                      'INICIAR SESIÓN',
                                      style: TextStyle(
                                        color: AppColors.surfaceLowest,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: TextButton(
                                    onPressed: () {
                                      auth.clearError();
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                const RegisterScreen()),
                                      );
                                    },
                                    child: const Text('CREAR CUENTA'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextInputField(
                            controller: _emailController,
                            label: 'CORREO',
                            hint: 'estudiante@unison.mx',
                            keyboardType: TextInputType.emailAddress,
                            validator: Validators.email,
                          ),
                          const SizedBox(height: 14),
                          TextInputField(
                            controller: _passwordController,
                            label: 'CONTRASEÑA',
                            hint: '••••••••',
                            obscureText: _obscurePassword,
                            validator: Validators.password,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppColors.textMuted,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              child: const Text('¿Olvidaste tu contraseña?'),
                            ),
                          ),
                          if (auth.errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text(
                                auth.errorMessage!,
                                style: const TextStyle(
                                    color: AppColors.danger,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          GoldButton(
                            label: auth.isLoading ? 'Entrando...' : 'Entrar',
                            onPressed: auth.isLoading
                                ? null
                                : () async {
                                    if (!_formKey.currentState!.validate())
                                      return;
                                    await auth.login(
                                      email: _emailController.text,
                                      password: _passwordController.text,
                                    );
                                  },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Desarrollado por: \n Vallejo Leyva Marcos \n Casas Gastelum Ana Cecilia \n Murillo Monga Joshua David',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
