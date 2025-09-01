import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static const String _languageKey = 'language_code';
  static const String _accentColorKey = 'accent_color';

  ThemeMode _themeMode = ThemeMode.system;
  String _languageCode = 'zh';
  Color _accentColor = Colors.blue;

  // Getters
  ThemeMode get themeMode => _themeMode;
  String get languageCode => _languageCode;
  Color get accentColor => _accentColor;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isEnglish => _languageCode == 'en';

  // Available accent colors
  static const List<Color> availableAccentColors = [
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.teal,
    Colors.pink,
  ];

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _themeMode = ThemeMode.values[prefs.getInt(_themeKey) ?? 0];
      _languageCode = prefs.getString(_languageKey) ?? 'zh';
      _accentColor = Color(prefs.getInt(_accentColorKey) ?? Colors.blue.value);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading settings: $e');
      // Use default values if loading fails
      _themeMode = ThemeMode.system;
      _languageCode = 'zh';
      _accentColor = Colors.blue;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    try {
      _themeMode = mode;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, mode.index);
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving theme mode: $e');
    }
  }

  Future<void> setLanguage(String languageCode) async {
    try {
      _languageCode = languageCode;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving language: $e');
    }
  }

  Future<void> setAccentColor(Color color) async {
    try {
      _accentColor = color;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_accentColorKey, color.value);
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving accent color: $e');
    }
  }

  Future<void> toggleTheme() async {
    final newMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await setThemeMode(newMode);
  }

  Future<void> toggleLanguage() async {
    final newLanguage = _languageCode == 'zh' ? 'en' : 'zh';
    await setLanguage(newLanguage);
  }

  // Helper method to get localized text
  String getLocalizedText(String englishText, String chineseText) {
    return isEnglish ? englishText : chineseText;
  }
}
