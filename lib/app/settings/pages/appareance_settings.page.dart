import 'package:flutter/material.dart';
import 'package:monekin/app/layout/page_framework.dart';
import 'package:monekin/app/settings/widgets/monekin_tile_switch.dart';
import 'package:monekin/app/settings/widgets/settings_list_utils.dart';
import 'package:monekin/core/database/services/user-setting/enum/app-fonts.enum.dart';
import 'package:monekin/core/database/services/user-setting/enum/border_radius_scale.enum.dart';
import 'package:monekin/core/database/services/user-setting/enum/card_style.enum.dart';
import 'package:monekin/core/database/services/user-setting/user_setting_service.dart';
import 'package:monekin/core/database/services/user-setting/utils/get_theme_from_string.dart';
import 'package:monekin/core/extensions/color.extensions.dart';
import 'package:monekin/core/extensions/padding.extension.dart';
import 'package:monekin/core/presentation/animations/scaled_animated_switcher.dart';
import 'package:monekin/core/presentation/app_colors.dart';
import 'package:monekin/core/presentation/theme.dart';
import 'package:monekin/core/presentation/theme_presets.dart';
import 'package:monekin/core/presentation/widgets/color_picker/color_picker.dart';
import 'package:monekin/core/presentation/widgets/color_picker/color_picker_modal.dart';
import 'package:monekin/core/presentation/widgets/dynamic_selector_modal.dart';
import 'package:monekin/core/routes/route_utils.dart';
import 'package:monekin/i18n/generated/translations.g.dart';
import 'package:monekin/core/presentation/widgets/number_ui_formatters/currency_displayer.dart';
import 'package:monekin/core/presentation/widgets/card_with_header.dart';

class AppareanceSettingsPage extends StatefulWidget {
  const AppareanceSettingsPage({super.key});

  @override
  State<AppareanceSettingsPage> createState() => _AppareanceSettingsPageState();
}

class _AppareanceSettingsPageState extends State<AppareanceSettingsPage> {
  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    final currentThemeMode = getThemeFromString(appStateSettings[SettingKey.themeMode]);
    final currentAccentColor = appStateSettings[SettingKey.accentColor];
    final currentPreset = currentAccentColor == 'auto' ? null : getPresetForAccentColor(currentAccentColor ?? brandBlue.toHex());
    final currentBorderRadiusScale = BorderRadiusScale.fromDB(appStateSettings[SettingKey.borderRadiusScale]);
    final currentCardStyle = CardStyle.fromDB(appStateSettings[SettingKey.cardStyle]);
    final isAmoled = appStateSettings[SettingKey.amoledMode] == '1';
    final isHighContrast = appStateSettings[SettingKey.contrastMode] == '1';

    return PageFramework(
      title: t.settings.appearance.menu_title,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 16).withSafeBottom(context),
        child: ListTileTheme(
          data: getSettingListTileStyle(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLivePreviewCard(context),
              
              createListSeparator(context, t.settings.appearance.theme.title),
              _buildThemeModeSegmentedButton(context, currentThemeMode),
              
              createListSeparator(context, "Color Palette"),
              _buildColorPalette(context, currentPreset, currentAccentColor),
              
              MonekinTileSwitch(
                title: t.settings.appearance.dynamic_colors,
                subtitle: t.settings.appearance.dynamic_colors_descr,
                initialValue: currentAccentColor == 'auto',
                onSwitchDebounceMs: 200,
                onSwitch: (bool value) async {
                  await UserSettingService.instance.setItem(
                    SettingKey.accentColor,
                    value ? 'auto' : brandBlue.toHex(),
                    updateGlobalState: true,
                  );
                },
              ),

              createListSeparator(context, "Style"),
              _buildBorderRadiusSelector(context, currentBorderRadiusScale),
              _buildCardStyleSelector(context, currentCardStyle),

              createListSeparator(context, "Accessibility"),
              MonekinTileSwitch(
                title: t.settings.appearance.amoled_mode,
                subtitle: t.settings.appearance.amoled_mode_descr,
                initialValue: isAmoled,
                disabled: isAppInLightBrightness(context),
                onSwitchDebounceMs: 200,
                onSwitch: (bool value) async {
                  await UserSettingService.instance.setItem(
                    SettingKey.amoledMode,
                    value ? '1' : '0',
                    updateGlobalState: true,
                  );
                },
              ),
              MonekinTileSwitch(
                title: "High Contrast Mode",
                subtitle: "Increases text and background contrast",
                initialValue: isHighContrast,
                onSwitchDebounceMs: 200,
                onSwitch: (bool value) async {
                  await UserSettingService.instance.setItem(
                    SettingKey.contrastMode,
                    value ? '1' : '0',
                    updateGlobalState: true,
                  );
                },
              ),

              createListSeparator(context, t.settings.appearance.text),
              _buildFontSelector(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLivePreviewCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: CardWithHeader(
        title: "Preview",
        bodyPadding: const EdgeInsets.all(16),
        body: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.of(context).consistentPrimary.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.fastfood_rounded, color: AppColors.of(context).consistentPrimary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Lunch", style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text("Today, 14:30", style: TextStyle(color: AppColors.of(context).textSecondary, fontSize: 13)),
                ],
              ),
            ),
            Text(
              "- \$15.00",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.of(context).expenseColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeModeSegmentedButton(BuildContext context, ThemeMode currentThemeMode) {
    final t = Translations.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SizedBox(
        width: double.infinity,
        child: SegmentedButton<ThemeMode>(
          segments: [
            ButtonSegment(
              value: ThemeMode.system,
              icon: const Icon(Icons.brightness_auto_rounded),
              label: Text(t.settings.appearance.theme.auto),
            ),
            ButtonSegment(
              value: ThemeMode.light,
              icon: const Icon(Icons.light_mode_rounded),
              label: Text(t.settings.appearance.theme.light),
            ),
            ButtonSegment(
              value: ThemeMode.dark,
              icon: const Icon(Icons.dark_mode_rounded),
              label: Text(t.settings.appearance.theme.dark),
            ),
          ],
          selected: {currentThemeMode},
          onSelectionChanged: (Set<ThemeMode> newSelection) {
            UserSettingService.instance.setItem(
              SettingKey.themeMode,
              newSelection.first.name,
              updateGlobalState: true,
            );
          },
        ),
      ),
    );
  }

  Widget _buildColorPalette(BuildContext context, ThemePreset? currentPreset, String? currentAccentColor) {
    final isDynamic = currentAccentColor == 'auto';
    final customColor = isDynamic ? Theme.of(context).colorScheme.primary : ColorHex.get(currentAccentColor ?? brandBlue.toHex());

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...themePresets.map((preset) => _buildColorSwatch(
            context,
            color: preset.seedColor,
            label: preset.name,
            isSelected: !isDynamic && currentPreset?.id == preset.id,
            onTap: () async {
              await UserSettingService.instance.setItem(
                SettingKey.accentColor,
                preset.seedColorHex,
                updateGlobalState: true,
              );
            },
          )),
          _buildColorSwatch(
            context,
            color: currentPreset == null && !isDynamic ? customColor : Colors.grey.shade400,
            label: "Custom",
            isSelected: currentPreset == null && !isDynamic,
            icon: Icons.colorize_rounded,
            onTap: () {
              showColorPickerModal(
                context,
                ColorPickerModal(
                  colorOptions: [brandBlue.toHex(), ...defaultColorPickerOptions],
                  selectedColor: customColor.toHex(),
                  onColorSelected: (value) async {
                    RouteUtils.popRoute();
                    await UserSettingService.instance.setItem(
                      SettingKey.accentColor,
                      value.toHex(),
                      updateGlobalState: true,
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildColorSwatch(BuildContext context, {required Color color, required String label, required bool isSelected, IconData? icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        margin: const EdgeInsets.only(right: 8),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: isSelected ? Border.all(color: Theme.of(context).colorScheme.primary, width: 3) : null,
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 28)
                  : icon != null
                      ? Icon(icon, color: Colors.white)
                      : null,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Theme.of(context).colorScheme.primary : AppColors.of(context).textSecondary,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBorderRadiusSelector(BuildContext context, BorderRadiusScale currentScale) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Corner Radius", style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 12),
          Row(
            children: BorderRadiusScale.values.map((scale) {
              final isSelected = scale == currentScale;
              return Expanded(
                child: GestureDetector(
                  onTap: () async {
                    await UserSettingService.instance.setItem(
                      SettingKey.borderRadiusScale,
                      scale.toDB(),
                      updateGlobalState: true,
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.4) : AppColors.of(context).cardBackground,
                      border: Border.all(
                        color: isSelected ? Theme.of(context).colorScheme.primary : AppColors.of(context).cardBorder,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(scale.radiusValue.clamp(4.0, 16.0)),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            border: Border.all(color: isSelected ? Theme.of(context).colorScheme.primary : AppColors.of(context).textSecondary, width: 2),
                            borderRadius: BorderRadius.circular(scale.radiusValue.clamp(2.0, 12.0)),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          scale.displayLabel,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: isSelected ? Theme.of(context).colorScheme.primary : AppColors.of(context).textSecondary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCardStyleSelector(BuildContext context, CardStyle currentStyle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Card Style", style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 12),
          Row(
            children: CardStyle.values.map((style) {
              final isSelected = style == currentStyle;
              return Expanded(
                child: GestureDetector(
                  onTap: () async {
                    await UserSettingService.instance.setItem(
                      SettingKey.cardStyle,
                      style.toDB(),
                      updateGlobalState: true,
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: style == CardStyle.flat ? AppColors.of(context).cardBackground : AppColors.of(context).cardBackgroundElevated,
                      border: Border.all(
                        color: isSelected ? Theme.of(context).colorScheme.primary : (style == CardStyle.outlined ? AppColors.of(context).cardBorder : Colors.transparent),
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: style == CardStyle.elevated && !isSelected ? boxShadowElevated(context) : null,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          style.icon,
                          color: isSelected ? Theme.of(context).colorScheme.primary : AppColors.of(context).textSecondary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          style.displayLabel,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: isSelected ? Theme.of(context).colorScheme.primary : AppColors.of(context).textSecondary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFontSelector(BuildContext context) {
    final t = Translations.of(context);
    final font = AppFonts.fromDB(appStateSettings[SettingKey.font]);

    return ListTile(
      leading: const Icon(Icons.font_download_rounded),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        spacing: 12,
        children: [
          Flexible(child: Text(t.settings.appearance.font)),
          Flexible(
            child: SelectorContainer(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Text(
                font?.fontFamilyName ?? t.settings.appearance.font_platform,
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
      onTap: () {
        showDynamicSelectorBottomSheet(
          context,
          selectorWidget: DynamicSelectorModal(
            items: const [null, ...AppFonts.values],
            selectedValue: font,
            displayNameGetter: (action) => action?.fontFamilyName ?? t.settings.appearance.font_platform,
            elementTitleBuilder: (title, item) => Text(
              title,
              style: TextStyle(fontFamily: item?.fontFamilyName),
            ),
            valueGetter: (action) => action,
            title: t.settings.appearance.font,
          ),
        ).then((modalResult) async {
          if (modalResult == null) return;
          await UserSettingService.instance.setItem(
            SettingKey.font,
            modalResult.result?.toDB(),
            updateGlobalState: true,
          );
        });
      },
    );
  }
}
