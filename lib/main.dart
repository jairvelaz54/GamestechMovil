import 'package:flutter/material.dart';
import 'package:gamestech/settings/theme_setting.dart';
import 'package:provider/provider.dart';
import 'package:gamestech/settings/theme_provider.dart';
import 'package:gamestech/screens/cart_screen.dart';
import 'package:gamestech/screens/favorite_sreen.dart';
import 'package:gamestech/screens/reset_password_screen.dart';
import 'package:gamestech/screens/theme_settings_screend.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> _checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboardingSeen') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkOnboardingStatus(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          // Mostrar un indicador de carga mientras se obtiene el estado del onboarding
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        final bool onboardingSeen = snapshot.data!;

        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, _) {
            // Generar ThemeData dinámicamente con fuentes de Google Fonts
            final ThemeData themeData = themeProvider.isDarkMode
                ? ThemeData.dark().copyWith(
                    textTheme: GoogleFonts.getTextTheme(
                      themeProvider.fontFamily,
                      ThemeData.dark().textTheme,
                    ),
                  )
                : ThemeData.light().copyWith(
                    textTheme: GoogleFonts.getTextTheme(
                      themeProvider.fontFamily,
                      ThemeData.light().textTheme,
                    ),
                  );

            return MaterialApp(
              title: 'Gamestech',
              debugShowCheckedModeBanner: false,
              theme: themeData,
              home: onboardingSeen ? LoginScreen() : OnboardingScreen(),
              routes: {
                "/login": (context) => LoginScreen(),
                "/register": (context) => RegisterScreen(),
                "/home": (context) => HomeScreen(),
                "/resetPassword": (context) => ResetPasswordScreen(),
                "/cart": (context) => const CartScreen(),
                "/favorites": (context) => const FavoritesScreen(),
                "/theme": (context) => const ThemeSettingsScreen(),
              },
            );
          },
        );
      },
    );
  }
}
