import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppPalette {
  teal('Teal', Color(0xFF16796E)),
  purple('Purple', Color(0xFF6554CF)),
  blue('Blue', Color(0xFF2563EB)),
  orange('Orange', Color(0xFFCB5B18));

  const AppPalette(this.label, this.seedColor);

  final String label;
  final Color seedColor;
}

class AppThemeSettings {
  static const _preferenceKey = 'app_color_palette';

  static final selectedPalette = ValueNotifier(AppPalette.teal);

  static Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    final storedName = preferences.getString(_preferenceKey);
    if (storedName == null) return;

    for (final palette in AppPalette.values) {
      if (palette.name == storedName) {
        selectedPalette.value = palette;
        return;
      }
    }

    debugPrint('Unknown saved app palette "$storedName"; using Teal.');
  }

  static Future<void> select(AppPalette palette) async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(_preferenceKey, palette.name);
    if (!saved) {
      throw StateError('The selected app palette could not be saved.');
    }
    selectedPalette.value = palette;
  }
}
