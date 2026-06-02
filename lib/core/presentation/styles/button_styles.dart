import 'package:flutter/material.dart';
import 'package:monekin/core/database/services/user-setting/enum/border_radius_scale.enum.dart';
import 'package:monekin/core/database/services/user-setting/user_setting_service.dart';

/// Gets the current border radius from settings, or uses the default (12.0).
double get defaultButtonBorderRadius =>
    BorderRadiusScale.fromDB(
      appStateSettings[SettingKey.borderRadiusScale],
    ).radiusValue;

/// Height for prominent call-to-action buttons (e.g. onboarding).
const bigButtonStyleHeight = 52.0;

/// Height for full-width persistent footer action buttons.
const mediumButtonStyleHeight = 42.0;

ButtonStyle _iconButtonStyle(BuildContext context, double height) {
  return ButtonStyle(
    textStyle: WidgetStatePropertyAll(Theme.of(context).textTheme.titleMedium!),
    iconSize: const WidgetStatePropertyAll(20),
    fixedSize: WidgetStatePropertyAll(Size.fromHeight(height)),
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(defaultButtonBorderRadius),
      ),
    ),
  );
}

/// Prominent icon+label button style (e.g. onboarding).
ButtonStyle getBigButtonStyle(BuildContext context) {
  return _iconButtonStyle(context, bigButtonStyleHeight);
}

/// Full-width persistent footer icon+label button style.
ButtonStyle getMediumButtonStyle(BuildContext context) {
  return _iconButtonStyle(context, mediumButtonStyleHeight);
}

RoundedRectangleBorder get defaultButtonShape => RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(defaultButtonBorderRadius),
);

/// Base [ButtonStyle] applied via [ThemeData] for standard-sized buttons.
ButtonStyle defaultButtonStyle({required bool isDark}) {
  return FilledButton.styleFrom(
    shape: defaultButtonShape,
    disabledBackgroundColor: isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.grey[200],
    disabledForegroundColor: isDark
        ? Colors.white.withOpacity(0.35)
        : Colors.grey,
  );
}

/// A refined outlined button style with subtle border.
ButtonStyle getOutlinedButtonStyle(BuildContext context) {
  final colorScheme = Theme.of(context).colorScheme;

  return OutlinedButton.styleFrom(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(defaultButtonBorderRadius),
    ),
    side: BorderSide(
      color: colorScheme.outline.withOpacity(0.4),
      width: 1.0,
    ),
  );
}
