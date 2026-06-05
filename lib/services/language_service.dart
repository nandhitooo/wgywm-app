import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LanguageService {
  static const _boxName = 'settings';
  static const _key = 'languageCode';

  static final ValueNotifier<Locale> localeNotifier =
      ValueNotifier(const Locale('en'));

  static Future<void> init() async {
    final box = await Hive.openBox(_boxName);
    final langCode = box.get(_key, defaultValue: 'en') as String;
    localeNotifier.value = Locale(langCode);
  }

  static Future<void> setLocale(String langCode) async {
    localeNotifier.value = Locale(langCode);
    final box = Hive.box(_boxName);
    await box.put(_key, langCode);
  }

  static String get currentLanguageCode => localeNotifier.value.languageCode;
}
