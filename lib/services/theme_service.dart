import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeService {
  static const _boxName = 'settings';
  static const _key = 'isDarkMode';

  static final ValueNotifier<ThemeMode> themeNotifier =
      ValueNotifier(ThemeMode.light);
  static final ValueNotifier<int> navIndexNotifier = ValueNotifier(0);

  static Future<void> init() async {
    final box = await Hive.openBox(_boxName);
    final isDark = box.get(_key, defaultValue: false) as bool;
    themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  static bool get isDarkMode => themeNotifier.value == ThemeMode.dark;

  static void setNavIndex(int index) {
    navIndexNotifier.value = index;
  }

  static Future<void> toggleTheme() async {
    final newMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    themeNotifier.value = newMode;

    final box = Hive.box(_boxName);
    await box.put(_key, newMode == ThemeMode.dark);
  }
}
