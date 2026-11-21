import 'package:flutter/material.dart';

/// Tema visual de TaskFlow (Material Design 3).
///
/// Se centraliza aquí, igual que el proyecto de referencia agrupa su
/// configuración en `Configurations/`, para que `main.dart` quede corto y las
/// tres pantallas compartan colores, bordes y estilos de botones y campos.
class AppTheme {
  AppTheme._();

  /// Color semilla: Material 3 genera toda la paleta a partir de él.
  static const Color seedColor = Color(0xFF4F46E5);

  /// Colores para el estado "completada" (verde, distinto del primario).
  static const Color completedColor = Color(0xFF1B7F3B);
  static const Color completedContainerColor = Color(0xFFDDF3E2);

  static const double radius = 16;

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(seedColor: seedColor);
    // Tipografía base de Material 3. Los estilos personalizados se derivan de
    // ella con copyWith para conservar la familia tipográfica de la plataforma.
    final textTheme = ThemeData(colorScheme: colorScheme).textTheme;
    final buttonTextStyle = textTheme.labelLarge?.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    );
    final roundedShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        centerTitle: false,
        scrolledUnderElevation: 2,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerLowest,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: roundedShape,
          textStyle: buttonTextStyle,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: roundedShape,
          textStyle: buttonTextStyle,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: roundedShape,
      ),
    );
  }
}
