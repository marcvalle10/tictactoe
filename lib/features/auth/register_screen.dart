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

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: AppBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: UniSonBadge()),
                  const SizedBox(height: 18),
                  const Center(child: EyebrowText('Registro de jugador')),
                  const SizedBox(height: 8),
                  const Text(
                    'Crea tu perfil',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Configura tu identidad para jugar, compartir salas y guardar tu historial.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary, height: 1.45),
                  ),
                  const SizedBox(height: 24),
                  ObsidianCard(
                    glow: true,
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextInputField(
                            controller: _nameController,
                            label: 'NOMBRE DE USUARIO',
                            hint: 'Alex_Gamer',
                            validator: (value) => Validators.required(value, 'tu nombre'),
                          ),
                          const SizedBox(height: 14),
                          TextInputField(
                            controller: _emailController,
                            label: 'CORREO ELECTRÓNICO',
                            hint: 'alex@unison.mx',
                            keyboardType: TextInputType.emailAddress,
                            validator: Validators.email,
                          ),
                          const SizedBox(height: 14),
                          TextInputField(
                            controller: _passwordController,
                            label: 'CONTRASEÑA',
                            hint: 'mínimo 6 caracteres',
                            obscureText: true,
                            validator: Validators.password,
                            helperText: 'Debe tener al menos 6 caracteres.',
                          ),
                          const SizedBox(height: 18),
                          if (auth.errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text(
                                auth.errorMessage!,
                                style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.w600),
                              ),
                            ),
                          GoldButton(
                            label: auth.isLoading ? 'Creando...' : 'Crear cuenta',
                            onPressed: auth.isLoading
                                ? null
                                : () async {
                                    if (!_formKey.currentState!.validate()) return;
                                    await auth.register(
                                      name: _nameController.text,
                                      email: _emailController.text,
                                      password: _passwordController.text,
                                    );
                                    if (context.mounted && auth.errorMessage == null) {
                                      Navigator.of(context).pop();
                                    }
                                  },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
