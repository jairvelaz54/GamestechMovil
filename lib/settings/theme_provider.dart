import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  String _fontFamily = 'Roboto'; // Fuente predeterminada

  bool get isDarkMode => _isDarkMode;
  String get fontFamily => _fontFamily;

  ThemeData get currentTheme {
    final baseTheme = _isDarkMode ? ThemeData.dark() : ThemeData.light();
    return baseTheme.copyWith(
      textTheme: GoogleFonts.getTextTheme(
        _fontFamily,
        baseTheme.textTheme,
      ),
    );
  }

  ThemeProvider() {
    _loadPreferences();
  }

  void toggleTheme(bool isDark) async {
    _isDarkMode = isDark;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
  }

  void setFontFamily(String font) async {
    _fontFamily = font;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fontFamily', _fontFamily);
  }

  void _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _fontFamily = prefs.getString('fontFamily') ?? 'Roboto';
    notifyListeners();
  }
}
