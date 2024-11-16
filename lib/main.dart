import 'package:flutter/material.dart';
import 'package:gamestech/screens/reset_password_screen.dart';
import 'package:gamestech/settings/global_values.dart';
import 'package:gamestech/settings/theme_preferences.dart';
import 'package:gamestech/settings/theme_setting.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  int savedTheme = await ThemePreference().getTheme();
  GlobalValues.themeMode.value = savedTheme;

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  Future<bool> _checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboardingSeen') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: GlobalValues.themeMode,
      builder: (context, themeMode, _) {
        return FutureBuilder<bool>(
          future: _checkOnboardingStatus(),
          builder: (context, snapshot) {
            // Mostrar una pantalla de carga mientras esperamos
            if (!snapshot.hasData) {
              return MaterialApp(
                home: Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                ),
              );
            }

            // Decidir la pantalla inicial según el estado de onboarding
            final bool onboardingSeen = snapshot.data!;
            return MaterialApp(
              title: 'Gamestech',
              debugShowCheckedModeBanner: false,
              theme: getThemeByMode(themeMode),
              home: onboardingSeen ? LoginScreen() : OnboardingScreen(),
              routes: {
                "/login": (context) => LoginScreen(),
                "/register": (context) => RegisterScreen(),
                "/home": (context) => HomeScreen(),
                "/resetPassword": (context) => ResetPasswordScreen(),
              },
            );
          },
        );
      },
    );
  }

  ThemeData getThemeByMode(int mode) {
    switch (mode) {
      case 1:
        return ThemeSettings.darkTheme();
      case 2:
        return ThemeSettings.customTheme();
      default:
        return ThemeSettings.lightTheme();
    }
  }
}
