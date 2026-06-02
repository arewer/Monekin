import 'package:flutter/material.dart';

/// Monekin brand color.
const brandBlue = Color(0xFF0F3375);

class AppColors extends ThemeExtension<AppColors> {
  const AppColors({required this.colors});

  final Map<String, Color> colors;

  // ─── Existing tokens ───
  Color get link => colors['link']!;
  Color get danger => colors['danger']!;
  Color get success => colors['success']!;
  Color get brand => colors['brand']!;
  Color get shadowColor => colors['shadowColor']!;
  Color get shadowColorLight => colors['shadowColorLight']!;
  Color get textBody => colors['textBody']!;
  Color get textHint => colors['textHint']!;
  Color get modalBackground => colors['modalBackground']!;
  Color get consistentPrimary => colors['consistentPrimary']!;
  Color get onConsistentPrimary => colors['onConsistentPrimary']!;
  Color get white => colors['white']!;
  Color get black => colors['black']!;

  // ─── New semantic tokens ───
  /// Mid-emphasis text color (between textBody and textHint).
  Color get textSecondary => colors['textSecondary']!;

  /// Card background color — applies to flat/elevated/outlined cards.
  Color get cardBackground => colors['cardBackground']!;

  /// Elevated card background — slightly more prominent than cardBackground.
  Color get cardBackgroundElevated => colors['cardBackgroundElevated']!;

  /// Subtle card border color (for outlined card style).
  Color get cardBorder => colors['cardBorder']!;

  /// Dedicated color for income amounts and indicators.
  Color get incomeColor => colors['incomeColor']!;

  /// Dedicated color for expense amounts and indicators.
  Color get expenseColor => colors['expenseColor']!;

  /// Dedicated color for transfer amounts and indicators.
  Color get transferColor => colors['transferColor']!;

  /// Themed divider color.
  Color get dividerColor => colors['dividerColor']!;

  /// Shimmer skeleton loading base color.
  Color get shimmerBase => colors['shimmerBase']!;

  /// Shimmer skeleton loading highlight color.
  Color get shimmerHighlight => colors['shimmerHighlight']!;

  /// Dashboard header gradient start color.
  Color get headerGradientStart => colors['headerGradientStart']!;

  /// Dashboard header gradient end color.
  Color get headerGradientEnd => colors['headerGradientEnd']!;

  static AppColors fromColorScheme(ColorScheme colorScheme) {
    final isDark = colorScheme.brightness == Brightness.dark;

    return AppColors(
      colors: {
        // ─── Existing tokens ───
        'link': isDark ? Colors.blue.shade200 : Colors.blue.shade700,
        'danger': isDark ? Colors.redAccent : Colors.red,
        'success': isDark
            ? Colors.lightGreen
            : const Color.fromARGB(255, 55, 161, 59),
        'brand': isDark ? const Color.fromARGB(255, 128, 134, 177) : brandBlue,
        'shadowColor': isDark
            ? const Color.fromARGB(105, 189, 189, 189)
            : const Color.fromARGB(100, 90, 90, 90),
        'shadowColorLight': isDark
            ? Colors.transparent
            : const Color.fromARGB(44, 90, 90, 90),
        'textBody': isDark
            ? const Color.fromARGB(245, 211, 211, 211)
            : const Color.fromARGB(255, 67, 67, 67),
        'textHint': isDark
            ? const Color.fromARGB(255, 153, 153, 153)
            : const Color.fromARGB(255, 123, 123, 123),
        'modalBackground': colorScheme.surfaceContainer,
        'consistentPrimary': isDark
            ? colorScheme.primaryContainer
            : colorScheme.primary,
        'onConsistentPrimary': isDark
            ? colorScheme.onPrimaryContainer
            : colorScheme.onPrimary,
        'white': !isDark ? Colors.white : Colors.black,
        'black': isDark ? Colors.white : Colors.black,

        // ─── New semantic tokens ───
        'textSecondary': isDark
            ? const Color.fromARGB(220, 180, 180, 180)
            : const Color.fromARGB(255, 95, 95, 95),
        'cardBackground': isDark
            ? Color.alphaBlend(
                colorScheme.primary.withOpacity(0.06),
                colorScheme.surface,
              )
            : Color.alphaBlend(
                colorScheme.primary.withOpacity(0.03),
                Colors.white,
              ),
        'cardBackgroundElevated': isDark
            ? Color.alphaBlend(
                colorScheme.primary.withOpacity(0.10),
                colorScheme.surface,
              )
            : Color.alphaBlend(
                colorScheme.primary.withOpacity(0.05),
                Colors.white,
              ),
        'cardBorder': isDark
            ? colorScheme.outlineVariant.withOpacity(0.3)
            : colorScheme.outlineVariant.withOpacity(0.5),
        'incomeColor': isDark
            ? const Color(0xFF81C784)
            : const Color(0xFF2E7D32),
        'expenseColor': isDark
            ? const Color(0xFFEF9A9A)
            : const Color(0xFFC62828),
        'transferColor': isDark
            ? const Color(0xFF90CAF9)
            : const Color(0xFF1565C0),
        'dividerColor': isDark
            ? Colors.white.withOpacity(0.08)
            : Colors.black.withOpacity(0.06),
        'shimmerBase': isDark
            ? Colors.white.withOpacity(0.06)
            : Colors.black.withOpacity(0.04),
        'shimmerHighlight': isDark
            ? Colors.white.withOpacity(0.12)
            : Colors.black.withOpacity(0.08),
        'headerGradientStart': isDark
            ? colorScheme.primaryContainer
            : colorScheme.primary,
        'headerGradientEnd': isDark
            ? Color.alphaBlend(
                colorScheme.primaryContainer.withOpacity(0.7),
                colorScheme.surface,
              )
            : Color.alphaBlend(
                colorScheme.primary.withOpacity(0.85),
                colorScheme.primaryContainer,
              ),
      },
    );
  }

  static AppColors of(BuildContext context) {
    return Theme.of(context).extension<AppColors>()!;
  }

  @override
  AppColors copyWith({Map<String, Color>? colors}) {
    return AppColors(colors: colors ?? this.colors);
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) {
      return this;
    }

    final lerpedColors = <String, Color>{};
    colors.forEach((key, value) {
      lerpedColors[key] = Color.lerp(value, other.colors[key], t)!;
    });

    return AppColors(colors: lerpedColors);
  }
}
