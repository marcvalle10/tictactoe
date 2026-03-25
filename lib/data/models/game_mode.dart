enum GameMode {
  classic,
  multiplayer4,
  rotatingSymbols,
}

extension GameModeX on GameMode {
  String get key => switch (this) {
        GameMode.classic => 'classic',
        GameMode.multiplayer4 => 'multiplayer4',
        GameMode.rotatingSymbols => 'rotatingSymbols',
      };

  /// Nombre para UI (Resultados, títulos, etc.)
  String get title => switch (this) {
        GameMode.classic => 'Clásico (3x3)',
        GameMode.multiplayer4 => 'Multijugador (4 jugadores)',
        GameMode.rotatingSymbols => 'Símbolos rotativos',
      };

  /// Nombre corto opcional (para chips, botones)
  String get shortTitle => switch (this) {
        GameMode.classic => 'Clásico',
        GameMode.multiplayer4 => '4 Jugadores',
        GameMode.rotatingSymbols => 'Rotativo',
      };

  String get description => switch (this) {
        GameMode.classic =>
          '2 jugadores en tablero 3x3. Gana con una línea de 3.',
        GameMode.multiplayer4 =>
          '4 jugadores, tablero 6x6 y línea ganadora de 4.',
        GameMode.rotatingSymbols =>
          'Los símbolos cambian cada turno en tablero 6x6.',
      };

  int get boardSize => switch (this) {
        GameMode.classic => 3,
        GameMode.multiplayer4 => 6,
        GameMode.rotatingSymbols => 6,
      };

  int get maxPlayers => switch (this) {
        GameMode.classic => 2,
        GameMode.multiplayer4 => 4,
        GameMode.rotatingSymbols => 4,
      };

  int get minPlayersToStart => switch (this) {
        GameMode.classic => 2,
        GameMode.multiplayer4 => 2,
        GameMode.rotatingSymbols => 2,
      };

  int get winLength => switch (this) {
        GameMode.classic => 3,
        GameMode.multiplayer4 => 4,
        GameMode.rotatingSymbols => 5,
      };

  static GameMode fromKey(String key) {
    return GameMode.values.firstWhere(
      (mode) => mode.key == key,
      orElse: () => GameMode.classic,
    );
  }
}
