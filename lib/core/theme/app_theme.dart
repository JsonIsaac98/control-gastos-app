import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'colors.dart';

class AppTheme {
  AppTheme._();

  // ─── Esquema de color LIGHT ──────────────────────────────────────────────
  // Fondo: #F4F7FE · Cards: #FFFFFF · Primary: #4318FF · Secondary: #B0BBD5 · Texto: #2B3674
  static const _lightScheme = ColorScheme(
    brightness: Brightness.light,
    // Azul eléctrico como primario
    primary:              AppColors.primaryLight,
    onPrimary:            Color(0xFFFFFFFF),
    primaryContainer:     AppColors.primaryContainerLight,
    onPrimaryContainer:   Color(0xFF14005D),
    // Azul grisáceo como secundario
    secondary:            AppColors.secondaryLight,
    onSecondary:          AppColors.textLight,
    secondaryContainer:   AppColors.secondaryContainerLight,
    onSecondaryContainer: AppColors.textLight,
    // Cyan como terciario
    tertiary:             Color(0xFF0891B2),
    onTertiary:           Color(0xFFFFFFFF),
    tertiaryContainer:    Color(0xFFCFFAFE),
    onTertiaryContainer:  Color(0xFF083344),
    // Error
    error:                Color(0xFFDC2626),
    onError:              Color(0xFFFFFFFF),
    errorContainer:       Color(0xFFFEE2E2),
    onErrorContainer:     Color(0xFF7F1D1D),
    // Superficies
    surface:              AppColors.surfaceLight,
    onSurface:            AppColors.textLight,
    surfaceContainerHighest: AppColors.cardLight,
    onSurfaceVariant:     Color(0xFF6B7A9F),
    outline:              AppColors.secondaryLight,
    outlineVariant:       AppColors.surfaceVariantLight,
    scrim:                Color(0xFF000000),
    inverseSurface:       AppColors.surfaceDark,
    onInverseSurface:     AppColors.textDark,
    inversePrimary:       AppColors.primaryDark,
    shadow:               Color(0xFF2B3674),
    surfaceTint:          AppColors.primaryLight,
  );

  // ─── Esquema de color DARK ───────────────────────────────────────────────
  // Fondo: #050505 · Cards: #121212 · Primary: #707EAE · Secondary: #1B254B · Texto: #FFFFFF
  static const _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    // Azul acero como primario
    primary:              AppColors.primaryDark,
    onPrimary:            Color(0xFF050505),
    primaryContainer:     AppColors.primaryContainerDark,
    onPrimaryContainer:   Color(0xFFC8CFEB),
    // Azul marino como secundario
    secondary:            AppColors.secondaryDark,
    onSecondary:          Color(0xFFFFFFFF),
    secondaryContainer:   AppColors.secondaryContainerDark,
    onSecondaryContainer: Color(0xFFC8CFEB),
    // Cyan claro como terciario
    tertiary:             Color(0xFF22D3EE),
    onTertiary:           Color(0xFF050505),
    tertiaryContainer:    Color(0xFF083344),
    onTertiaryContainer:  Color(0xFFCFFAFE),
    // Error
    error:                Color(0xFFF87171),
    onError:              Color(0xFF1A0000),
    errorContainer:       Color(0xFF7F1D1D),
    onErrorContainer:     Color(0xFFFECACA),
    // Superficies
    surface:              AppColors.surfaceDark,
    onSurface:            AppColors.textDark,
    surfaceContainerHighest: AppColors.cardDark,
    onSurfaceVariant:     AppColors.secondaryLight,
    outline:              Color(0xFF4A5578),
    outlineVariant:       AppColors.surfaceVariantDark,
    scrim:                Color(0xFF000000),
    inverseSurface:       AppColors.surfaceLight,
    onInverseSurface:     AppColors.textLight,
    inversePrimary:       AppColors.primaryLight,
    shadow:               Color(0xFF000000),
    surfaceTint:          AppColors.primaryDark,
  );

  // ─── Componentes compartidos ─────────────────────────────────────────────
  static CardThemeData _cardTheme(bool isDark) => CardThemeData(
        elevation: isDark ? 0 : 1,
        shadowColor: isDark ? Colors.transparent : const Color(0x1A2B3674),
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      );

  static InputDecorationTheme _inputTheme(ColorScheme cs) =>
      InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.outline.withValues(alpha: 0.5)),
        ),
        filled: true,
        fillColor: cs.surfaceContainerHighest,
      );

  static AppBarTheme _appBarTheme(ColorScheme cs) => AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        systemOverlayStyle: cs.brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      );

  static SegmentedButtonThemeData _segmentedTheme(ColorScheme cs) =>
      SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return cs.primaryContainer;
            }
            return cs.surfaceContainerHighest;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return cs.onPrimaryContainer;
            }
            return cs.onSurfaceVariant;
          }),
          side: WidgetStateProperty.all(
            BorderSide(color: cs.outline.withValues(alpha: 0.3)),
          ),
        ),
      );

  // ─── Tema LIGHT público ──────────────────────────────────────────────────
  static ThemeData light() {
    const cs = _lightScheme;
    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: AppColors.surfaceLight,
      appBarTheme: _appBarTheme(cs),
      cardTheme: _cardTheme(false),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        elevation: 4,
      ),
      inputDecorationTheme: _inputTheme(cs),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.cardLight,
        indicatorColor: cs.primaryContainer,
        labelTextStyle: WidgetStateProperty.all(
          TextStyle(fontSize: 12, color: cs.onSurface),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: cs.outline.withValues(alpha: 0.25),
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: cs.surfaceContainerHighest,
        selectedColor: cs.primaryContainer,
        side: BorderSide.none,
      ),
      segmentedButtonTheme: _segmentedTheme(cs),
    );
  }

  // ─── Tema DARK público ───────────────────────────────────────────────────
  static ThemeData dark() {
    const cs = _darkScheme;
    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: AppColors.surfaceDark,
      appBarTheme: _appBarTheme(cs),
      cardTheme: _cardTheme(true),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        elevation: 4,
      ),
      inputDecorationTheme: _inputTheme(cs),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.cardDark,
        indicatorColor: cs.primaryContainer,
        labelTextStyle: WidgetStateProperty.all(
          TextStyle(fontSize: 12, color: cs.onSurface),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: cs.outline.withValues(alpha: 0.3),
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: cs.surfaceContainerHighest,
        selectedColor: cs.primaryContainer,
        side: BorderSide.none,
      ),
      segmentedButtonTheme: _segmentedTheme(cs),
    );
  }
}
