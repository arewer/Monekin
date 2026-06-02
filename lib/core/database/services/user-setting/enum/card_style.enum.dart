import 'package:flutter/material.dart';
import 'package:monekin/core/extensions/string.extension.dart';

/// An enum representing the available card visual styles for the app.
///
/// Controls how cards appear throughout the app — their shadow,
/// background emphasis, and border treatment.
enum CardStyle {
  flat,
  elevated,
  outlined;

  static CardStyle fromDB(String? value) {
    if (value.isNullOrEmpty) {
      return CardStyle.elevated;
    }

    return CardStyle.values.firstWhere(
      (e) => e.name == value,
      orElse: () => CardStyle.elevated,
    );
  }

  String toDB() => name;

  /// Returns the display name for UI.
  String get displayLabel {
    switch (this) {
      case CardStyle.flat:
        return 'Flat';
      case CardStyle.elevated:
        return 'Elevated';
      case CardStyle.outlined:
        return 'Outlined';
    }
  }

  /// Returns an icon representing the card style.
  IconData get icon {
    switch (this) {
      case CardStyle.flat:
        return Icons.square_rounded;
      case CardStyle.elevated:
        return Icons.filter_none_rounded;
      case CardStyle.outlined:
        return Icons.crop_square_rounded;
    }
  }
}
