import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage {
  english('en'),
  turkish('tr');

  final String code;

  const AppLanguage(this.code);

  static AppLanguage fromCode(String? code) {
    switch (code) {
      case 'tr':
        return AppLanguage.turkish;
      case 'en':
      default:
        return AppLanguage.english;
    }
  }
}

class AppController extends ChangeNotifier {
  static const String _languageKey = 'paperpilot_language';

  AppLanguage _language = AppLanguage.english;

  AppLanguage get language => _language;

  Locale get locale => Locale(_language.code);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _language = AppLanguage.fromCode(prefs.getString(_languageKey));
    notifyListeners();
  }

  Future<void> setLanguage(AppLanguage language) async {
    if (_language == language) return;

    _language = language;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language.code);
  }
}

class AppControllerScope extends InheritedNotifier<AppController> {
  final AppController controller;

  const AppControllerScope({
    super.key,
    required this.controller,
    required super.child,
  }) : super(notifier: controller);

  static AppController of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<AppControllerScope>();

    assert(scope != null, 'AppControllerScope not found in widget tree.');
    return scope!.controller;
  }
}
