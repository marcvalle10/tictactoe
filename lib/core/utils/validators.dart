class Validators {
  static String? email(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Ingresa tu correo';
    if (!text.contains('@') || !text.contains('.')) {
      return 'Correo inválido';
    }
    return null;
  }

  static String? password(String? value) {
    final text = value ?? '';
    if (text.isEmpty) return 'Ingresa tu contraseña';
    if (text.length < 6) return 'La contraseña debe tener al menos 6 caracteres';
    return null;
  }

  static String? required(String? value, String fieldName) {
    if ((value ?? '').trim().isEmpty) {
      return 'Ingresa $fieldName';
    }
    return null;
  }

  static String? roomCode(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Ingresa el código de sala';
    if (text.length < 6) return 'Código inválido';
    return null;
  }
}
