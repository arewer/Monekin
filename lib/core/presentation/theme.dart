import 'dart:io';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:monekin/core/database/services/user-setting/enum/app-fonts.enum.dart';
import 'package:monekin/core/database/services/user-setting/enum/border_radius_scale.enum.dart';
import 'package:monekin/core/database/services/user-setting/enum/card_style.enum.dart';
import 'package:monekin/core/database/services/user-setting/user_setting_service.dart';
import 'package:monekin/core/extensions/color.extensions.dart';
import 'package:monekin/core/presentation/styles/borders.dart';
import 'package:monekin/core/presentation/styles/button_styles.dart';

import 'app_colors.dart';

bool isAppUsingDynamicColors = false;

bool isAppInDarkBrightness(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark;
bool isAppInLightBrightness(BuildContext context) =>
    !isAppInDarkBrightness(context);

double getCardBorderRadius() {
  final scale = BorderRadiusScale.fromDB(
    appStateSettings[SettingKey.borderRadiusScale],
  );

  // iOS/macOS get a slight bump for native feel
  final platformBump = (Platform.isIOS || Platform.isMacOS) ? 4.0 : 0.0;
  return scale.radiusValue + platformBump;
}

/// Returns the background color for the window behind the main content area.
/// Used on desktop when the sidebar is visible.
Color getWindowBackgroundColor(BuildContext context) {
  final colorScheme = Theme.of(context).colorScheme;
  return isAppInDarkBrightness(context)
      ? Color.alphaBlend(
          colorScheme.primary.withOpacity(0.05),
          colorScheme.surface,
        )
      : Color.alphaBlend(
          colorScheme.primary.withOpacity(0.04),
          colorScheme.surface,
        );
}

extension TextThemeExtension on TextTheme {
  /// Returns a new [TextTheme] where selected body and label text styles have their
  /// color updated to the specified [color].
  ///
  /// The styles affected by this change are:
  /// - [bodyLarge]
  /// - [bodyMedium]
  /// - [bodySmall]
  /// - [labelMedium]
  /// - [labelSmall]
  TextTheme withDifferentBodyColors(Color color) {
    TextStyle? applyColor(TextStyle? style) => style?.copyWith(color: color);

    return copyWith(
      bodyLarge: applyColor(bodyLarge),
      bodyMedium: applyColor(bodyMedium),
      bodySmall: applyColor(bodySmall),
      labelMedium: applyColor(labelMedium),
      labelSmall: applyColor(labelSmall),
    );
  }
}

ThemeData getThemeData(
  BuildContext context, {
  required bool isDark,
  required bool amoledMode,
  required ColorScheme? lightDynamic,
  required ColorScheme? darkDynamic,
  required String accentColor,
}) {
  ThemeData theme;

  ColorScheme lightColorScheme;
  ColorScheme darkColorScheme;

  final bool highContrast = appStateSettings[SettingKey.contrastMode] == '1';

  if (lightDynamic != null && darkDynamic != null && accentColor == 'auto') {
    // On Android S+ devices, use the provided dynamic color scheme.
    // (Recommended) Harmonize the dynamic color scheme' built-in semantic colors.
    lightColorScheme = ColorScheme.fromSeed(
      seedColor: lightDynamic.primary,
      brightness: Brightness.light,
      surface: lightDynamic.primary.lightenPastel(amount: 0.91),
    ).harmonized();

    // Repeat for the dark color scheme.
    darkColorScheme = ColorScheme.fromSeed(
      seedColor: darkDynamic.primary,
      brightness: Brightness.dark,
      surface: amoledMode
          ? Colors.black
          : darkDynamic.primary.darkenPastel(amount: 0.92),
    );

    // TODO: We can directly use the dynamic palette here, in the following way

    // lightColorScheme = lightDynamic.harmonized();
    // darkColorScheme = darkDynamic.harmonized();

    // if (amoledMode) {
    //   darkColorScheme = darkColorScheme.copyWith(surface: Colors.black);
    // }

    // However, the colorSchemes provided by the `dynamic_color` package do not generate the
    // new surface colors of Flutter 3.22. See https://github.com/material-foundation/flutter-packages/issues/582#issuecomment-2209591668
    // for more info

    isAppUsingDynamicColors = true; // ignore, only for demo purposes
  } else {
    // Otherwise, use fallback schemes:

    final accentColorValue = accentColor == 'auto'
        ? brandBlue
        : ColorHex.get(accentColor);

    /// Fallback scheme for a not-dynamic mode in dark or light mode:
    ColorScheme fallbackScheme = ColorScheme.fromSeed(
      seedColor: accentColorValue,
      brightness: isDark ? Brightness.dark : Brightness.light,
      surface: isDark
          ? (amoledMode
                ? Colors.black
                : accentColorValue.darkenPastel(amount: 0.92))
          : accentColorValue.lightenPastel(amount: 0.91),
    );

    lightColorScheme = fallbackScheme;
    darkColorScheme = fallbackScheme;
  }

  // Apply high-contrast adjustments
  if (highContrast) {
    final scheme = isDark ? darkColorScheme : lightColorScheme;
    final adjusted = scheme.copyWith(
      onSurface: isDark ? Colors.white : Colors.black,
      onSurfaceVariant: isDark
          ? Colors.white.withOpacity(0.87)
          : Colors.black.withOpacity(0.87),
    );
    if (isDark) {
      darkColorScheme = adjusted;
    } else {
      lightColorScheme = adjusted;
    }
  }

  AppColors customAppColors = AppColors.fromColorScheme(
    isDark ? darkColorScheme : lightColorScheme,
  );

  final fontFamily = AppFonts.fromDB(
    appStateSettings[SettingKey.font],
  )?.fontFamilyName;

  final borderRadius = getCardBorderRadius();
  final cardStyleEnum = CardStyle.fromDB(appStateSettings[SettingKey.cardStyle]);

  theme = ThemeData(
    colorScheme: isDark ? darkColorScheme : lightColorScheme,
    brightness: isDark ? Brightness.dark : Brightness.light,
    useMaterial3: true,
    fontFamily: fontFamily,
    extensions: [customAppColors],
  );

  final textTheme = theme.textTheme.withDifferentBodyColors(
    customAppColors.textBody,
  );

  // Card color uses the new token or falls back to computed value
  final cardColor = customAppColors.cardBackground;

  final defaultButtons = defaultButtonStyle(isDark: isDark);

  return theme.copyWith(
    textTheme: textTheme,
    scaffoldBackgroundColor: theme.colorScheme.surface,
    filledButtonTheme: FilledButtonThemeData(style: defaultButtons),
    elevatedButtonTheme: ElevatedButtonThemeData(style: defaultButtons),
    outlinedButtonTheme: OutlinedButtonThemeData(style: defaultButtons),
    textButtonTheme: TextButtonThemeData(style: defaultButtons),
    dividerTheme: DividerThemeData(
      space: 0,
      thickness: 1,
      color: customAppColors.dividerColor,
    ),
    cardColor: cardColor,
    cardTheme: CardThemeData(
      color: cardColor,
      elevation: cardStyleEnum == CardStyle.flat ? 0 : 1,
      shadowColor: cardStyleEnum == CardStyle.elevated
          ? customAppColors.shadowColorLight
          : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        side: cardStyleEnum == CardStyle.outlined
            ? BorderSide(color: customAppColors.cardBorder, width: 1)
            : BorderSide.none,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: theme.colorScheme.surfaceContainerHighest,
      isDense: false,
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      hintStyle: TextStyle(color: customAppColors.textHint),
      border: appInputBorder,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
      elevation: 2,
      highlightElevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    ),
    bottomSheetTheme: theme.bottomSheetTheme.copyWith(
      elevation: 0,
      dragHandleSize: const Size(32, 4),
      modalBackgroundColor: customAppColors.modalBackground,
      dragHandleColor: isDark
          ? Colors.grey[600]
          : Colors.grey[300],
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(borderRadius + 4),
        ),
      ),
    ),
    listTileTheme: ListTileThemeData(
      minVerticalPadding: 12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      elevation: 0,
      height: 72,
      indicatorShape: StadiumBorder(),
      indicatorColor: theme.colorScheme.primary.withOpacity(0.12),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final isSelected = states.contains(WidgetState.selected);
        return theme.textTheme.labelSmall!.copyWith(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: isSelected
              ? theme.colorScheme.primary
              : customAppColors.textSecondary,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final isSelected = states.contains(WidgetState.selected);
        return IconThemeData(
          size: 22,
          color: isSelected
              ? theme.colorScheme.primary
              : customAppColors.textSecondary,
        );
      }),
    ),
    navigationRailTheme: NavigationRailThemeData(
      elevation: 0,
      indicatorShape: const StadiumBorder(),
      indicatorColor: theme.colorScheme.primary.withOpacity(0.12),
      selectedIconTheme: IconThemeData(
        color: theme.colorScheme.primary,
      ),
      unselectedIconTheme: IconThemeData(
        color: customAppColors.textSecondary,
      ),
      selectedLabelTextStyle: theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelTextStyle: theme.textTheme.labelSmall?.copyWith(
        color: customAppColors.textSecondary,
      ),
    ),
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius + 4),
      ),
      elevation: 4,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    ),
    chipTheme: ChipThemeData(
      shape: StadiumBorder(),
      elevation: 0,
      pressElevation: 0,
      side: BorderSide(
        color: theme.colorScheme.outline.withOpacity(0.3),
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      surfaceTintColor: Colors.transparent,
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0.5,
      centerTitle: false,
      backgroundColor: theme.colorScheme.surface,
      surfaceTintColor: Colors.transparent,
    ),
  );
}
