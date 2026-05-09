import 'package:flutter/material.dart';

/// Paleta de colores central de RoundFlow.
/// Importa esta clase en cualquier widget para acceder a los colores.
///
/// Uso:
///   Container(color: AppColors.work)
///   Text('RONDA', style: TextStyle(color: AppColors.textPrimary))
abstract class AppColors {
  // Fondos
  static const Color background = Color(0xFF0D0D0D); // Negro carbón
  static const Color surface = Color(0xFF1A1A1A); // Superficie de cards
  static const Color surfaceVariant = Color(0xFF242424); // Inputs, tiles

  // Fases del timer
  static const Color work = Color(0xFFE63946); // Rojo — trabajo
  static const Color rest = Color(0xFF457B9D); // Azul frío — descanso
  static const Color warmup = Color(0xFFF4A261); // Naranja — calentamiento
  static const Color cooldown = Color(0xFFF4A261); // Naranja — enfriamiento
  static const Color completed = Color(0xFF2A9D8F); // Verde teal — completado

  // Texto
  static const Color textPrimary = Color(0xFFF1FAEE); // Blanco hueso
  static const Color textSecondary = Color(0xFF8D99AE); // Gris claro
  static const Color textDisabled = Color(0xFF4A4A4A); // Gris oscuro

  // UI General
  static const Color accent = Color(
    0xFF1D3557,
  ); // Azul oscuro — botones secundarios
  static const Color divider = Color(0xFF2C2C2C); // Separadores

  /// Devuelve el color correspondiente a cada fase.
  static Color forPhase(String phase) {
    switch (phase) {
      case 'warmup':
        return warmup;
      case 'work':
        return work;
      case 'rest':
        return rest;
      case 'cooldown':
        return cooldown;
      case 'completed':
        return completed;
      default:
        return textSecondary;
    }
  }
}

/// Estilos de texto reutilizables.
abstract class AppTextStyles {
  // El timer grande en el centro de pantalla
  static const TextStyle timerDisplay = TextStyle(
    fontFamily: 'Rajdhani',
    fontSize: 96,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -2,
    height: 1.0,
  );

  // Badge de fase: "TRABAJO" / "DESCANSO"
  static const TextStyle phaseBadge = TextStyle(
    fontFamily: 'Rajdhani',
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 3,
  );

  // Contador de rondas: "3 / 12"
  static const TextStyle roundCounter = TextStyle(
    fontFamily: 'Rajdhani',
    fontSize: 28,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 1,
  );

  // Títulos de pantalla
  static const TextStyle screenTitle = TextStyle(
    fontFamily: 'Rajdhani',
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: 1,
  );

  // Subtítulos / labels de configuración
  static const TextStyle label = TextStyle(
    fontFamily: 'Rajdhani',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 1.5,
  );

  // Cuerpo general
  static const TextStyle body = TextStyle(
    fontFamily: 'Rajdhani',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );
}

/// ThemeData completo de la app.
class AppTheme {
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Rajdhani',

      // Color scheme
      colorScheme: const ColorScheme.dark(
        surface: AppColors.surface,
        primary: AppColors.work,
        secondary: AppColors.rest,
        tertiary: AppColors.warmup,
        onPrimary: AppColors.textPrimary,
        onSurface: AppColors.textPrimary,
        outline: AppColors.divider,
      ),

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Rajdhani',
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          letterSpacing: 2,
        ),
      ),

      // Botón principal (ElevatedButton)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.work,
          foregroundColor: AppColors.textPrimary,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Rajdhani',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
      ),

      // Botón outline (OutlinedButton)
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.divider),
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Rajdhani',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
      ),

      // FloatingActionButton
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.work,
        foregroundColor: AppColors.textPrimary,
      ),

      // Cards
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.divider),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // Inputs / TextFields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariant,
        labelStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontFamily: 'Rajdhani',
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.work, width: 2),
        ),
      ),

      // Sliders
      sliderTheme: const SliderThemeData(
        activeTrackColor: AppColors.work,
        inactiveTrackColor: AppColors.surfaceVariant,
        thumbColor: AppColors.work,
        overlayColor: Color(0x33E63946),
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.work
              : AppColors.textDisabled,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? const Color(0x55E63946)
              : AppColors.surfaceVariant,
        ),
      ),

      // Dividers
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surface,
        contentTextStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontFamily: 'Rajdhani',
          fontSize: 15,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
