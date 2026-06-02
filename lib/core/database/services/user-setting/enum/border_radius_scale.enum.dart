import 'package:monekin/core/extensions/string.extension.dart';

/// An enum representing the available border radius scales for the app.
///
/// Each scale defines a base radius value that is used throughout the app
/// for cards, buttons, inputs, and other UI elements.
enum BorderRadiusScale {
  compact,
  defaultScale,
  rounded,
  pill;

  static BorderRadiusScale fromDB(String? value) {
    if (value.isNullOrEmpty) {
      return BorderRadiusScale.defaultScale;
    }

    return BorderRadiusScale.values.firstWhere(
      (e) => e.name == value,
      orElse: () => BorderRadiusScale.defaultScale,
    );
  }

  String toDB() => name;

  /// The base radius value in logical pixels.
  double get radiusValue {
    switch (this) {
      case BorderRadiusScale.compact:
        return 8.0;
      case BorderRadiusScale.defaultScale:
        return 12.0;
      case BorderRadiusScale.rounded:
        return 16.0;
      case BorderRadiusScale.pill:
        return 24.0;
    }
  }

  /// A slightly larger radius for modals and bottom sheets.
  double get modalRadius => radiusValue + 4;

  /// A smaller radius for input fields and chips.
  double get inputRadius => (radiusValue * 0.5).clamp(4.0, 12.0);

  /// Returns the display name for UI.
  String get displayLabel {
    switch (this) {
      case BorderRadiusScale.compact:
        return 'Compact';
      case BorderRadiusScale.defaultScale:
        return 'Default';
      case BorderRadiusScale.rounded:
        return 'Rounded';
      case BorderRadiusScale.pill:
        return 'Pill';
    }
  }

  /// Returns an icon representing the radius scale.
  // ignore: unused_element
  String get previewChar {
    switch (this) {
      case BorderRadiusScale.compact:
        return '▢';
      case BorderRadiusScale.defaultScale:
        return '▣';
      case BorderRadiusScale.rounded:
        return '◉';
      case BorderRadiusScale.pill:
        return '⬭';
    }
  }
}
