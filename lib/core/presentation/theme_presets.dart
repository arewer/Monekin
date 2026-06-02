import 'package:flutter/material.dart';
import 'package:monekin/core/extensions/color.extensions.dart';

/// A curated theme preset with a seed color and display properties.
class ThemePreset {
  const ThemePreset({
    required this.id,
    required this.name,
    required this.seedColor,
    this.icon,
  });

  /// Unique identifier for the preset (used in DB storage).
  final String id;

  /// Display name for the preset.
  final String name;

  /// The primary seed color used to generate the full color scheme.
  final Color seedColor;

  /// Optional icon for the preset.
  final IconData? icon;

  /// Returns the hex string representation of the seed color (without #).
  String get seedColorHex => seedColor.toHex();
}

/// All available theme presets in the app.
const List<ThemePreset> themePresets = [
  ThemePreset(
    id: 'ocean',
    name: 'Ocean',
    seedColor: Color(0xFF1A73E8),
    icon: Icons.water_rounded,
  ),
  ThemePreset(
    id: 'forest',
    name: 'Forest',
    seedColor: Color(0xFF2E7D32),
    icon: Icons.forest_rounded,
  ),
  ThemePreset(
    id: 'sunset',
    name: 'Sunset',
    seedColor: Color(0xFFE65100),
    icon: Icons.wb_twilight_rounded,
  ),
  ThemePreset(
    id: 'lavender',
    name: 'Lavender',
    seedColor: Color(0xFF7B1FA2),
    icon: Icons.spa_rounded,
  ),
  ThemePreset(
    id: 'midnight',
    name: 'Midnight',
    seedColor: Color(0xFF1A237E),
    icon: Icons.dark_mode_rounded,
  ),
  ThemePreset(
    id: 'rose',
    name: 'Rose',
    seedColor: Color(0xFFC62828),
    icon: Icons.local_florist_rounded,
  ),
];

/// Returns the [ThemePreset] matching a given accent color hex string,
/// or `null` if no preset matches.
ThemePreset? getPresetForAccentColor(String accentColorHex) {
  final normalizedHex = accentColorHex.toUpperCase().replaceAll('#', '');
  return themePresets.cast<ThemePreset?>().firstWhere(
    (preset) => preset!.seedColorHex.toUpperCase() == normalizedHex,
    orElse: () => null,
  );
}

/// Returns the [ThemePreset] matching a given preset ID,
/// or `null` if no preset matches.
ThemePreset? getPresetById(String? presetId) {
  if (presetId == null) return null;
  return themePresets.cast<ThemePreset?>().firstWhere(
    (preset) => preset!.id == presetId,
    orElse: () => null,
  );
}
