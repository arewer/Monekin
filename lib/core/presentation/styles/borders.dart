import 'package:flutter/material.dart';
import 'package:monekin/core/database/services/user-setting/enum/border_radius_scale.enum.dart';
import 'package:monekin/core/database/services/user-setting/enum/card_style.enum.dart';
import 'package:monekin/core/database/services/user-setting/user_setting_service.dart';
import 'package:monekin/core/presentation/app_colors.dart';

Radius get inputBorderRadius => Radius.circular(
  _currentBorderRadiusScale.inputRadius,
);

/// Gets the current border radius scale from app settings.
BorderRadiusScale get _currentBorderRadiusScale =>
    BorderRadiusScale.fromDB(appStateSettings[SettingKey.borderRadiusScale]);

/// Gets the current card style from app settings.
CardStyle get currentCardStyle =>
    CardStyle.fromDB(appStateSettings[SettingKey.cardStyle]);

/// General soft box shadow for cards (default/elevated style).
List<BoxShadow> boxShadowGeneral(BuildContext context) {
  final style = currentCardStyle;

  if (style == CardStyle.flat || style == CardStyle.outlined) {
    return [];
  }

  return [
    BoxShadow(
      color: AppColors.of(context).shadowColorLight.withOpacity(0.08),
      blurRadius: 16,
      offset: const Offset(0, 2),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: AppColors.of(context).shadowColorLight.withOpacity(0.04),
      blurRadius: 6,
      offset: const Offset(0, 1),
      spreadRadius: 0,
    ),
  ];
}

/// Elevated box shadow for modals, dialogs, elevated surfaces.
List<BoxShadow> boxShadowElevated(BuildContext context) {
  return [
    BoxShadow(
      color: AppColors.of(context).shadowColor.withOpacity(0.12),
      blurRadius: 24,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: AppColors.of(context).shadowColor.withOpacity(0.06),
      blurRadius: 8,
      offset: const Offset(0, 2),
      spreadRadius: 0,
    ),
  ];
}

/// Very subtle shadow for flat card hover states.
List<BoxShadow> boxShadowSubtle(BuildContext context) {
  return [
    BoxShadow(
      color: AppColors.of(context).shadowColorLight.withOpacity(0.04),
      blurRadius: 8,
      offset: const Offset(0, 1),
      spreadRadius: 0,
    ),
  ];
}

/// Returns a border for cards based on the current card style setting.
BoxBorder? getCardBorderForStyle(BuildContext context) {
  final style = currentCardStyle;

  if (style == CardStyle.outlined) {
    return Border.all(
      color: AppColors.of(context).cardBorder,
      width: 1.0,
    );
  }

  return null;
}

UnderlineInputBorder get appInputBorder => UnderlineInputBorder(
  borderSide: BorderSide.none,
  borderRadius: BorderRadius.all(inputBorderRadius),
);
