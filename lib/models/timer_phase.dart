/// Representa en qué fase del workout se encuentra el temporizador.
/// Usar enum en lugar de Strings evita errores de tipeo y permite
/// switch exhaustivo en el código.
enum TimerPhase {
  /// Calentamiento inicial antes de la primera ronda.
  /// Solo activo si WorkoutConfig.warmupSeconds > 0.
  warmup,

  /// Ronda activa — el usuario está trabajando/peleando.
  work,

  /// Descanso entre rondas.
  rest,

  /// Enfriamiento al terminar la última ronda.
  /// Solo activo si WorkoutConfig.cooldownSeconds > 0.
  cooldown,

  /// La sesión terminó completamente.
  completed,
}

/// Extensión para obtener propiedades visuales directamente del enum.
extension TimerPhaseExtension on TimerPhase {
  String get label {
    switch (this) {
      case TimerPhase.warmup:
        return 'CALENTAMIENTO';
      case TimerPhase.work:
        return 'TRABAJO';
      case TimerPhase.rest:
        return 'DESCANSO';
      case TimerPhase.cooldown:
        return 'ENFRIAMIENTO';
      case TimerPhase.completed:
        return 'COMPLETADO';
    }
  }

  /// Color hexadecimal asociado a cada fase.
  /// Se usa en el CircularTimer y en el flash de transición.
  int get colorValue {
    switch (this) {
      case TimerPhase.warmup:
        return 0xFFF4A261; // Naranja
      case TimerPhase.work:
        return 0xFFE63946; // Rojo
      case TimerPhase.rest:
        return 0xFF457B9D; // Azul frío
      case TimerPhase.cooldown:
        return 0xFFF4A261; // Naranja (mismo que warmup)
      case TimerPhase.completed:
        return 0xFF2A9D8F; // Verde teal
    }
  }

  /// Indica si esta fase cuenta como una "ronda activa".
  bool get isActiveRound => this == TimerPhase.work;

  /// Indica si la sesión sigue en curso (no terminada).
  bool get isOngoing => this != TimerPhase.completed;
}
