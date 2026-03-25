import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
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
      body: SafeArea(
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
                      const Text(
                        'Registro',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Crea una cuenta para empezar a jugar.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 24),
                      TextInputField(
                        controller: _nameController,
                        hint: 'Nombre de usuario',
                        validator: (value) => Validators.required(value, 'tu nombre'),
                      ),
                      const SizedBox(height: 14),
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
            ),
          ),
        ),
      ),
    );
  }
}
