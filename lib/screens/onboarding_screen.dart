import 'package:flutter/material.dart';
import 'package:gamestech/settings/global_values.dart';
import 'package:gamestech/settings/theme_setting.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: IntroductionScreen(
          pages: [
            PageViewModel(
              title: "Bienvenido a Gamestech",
              body: "Esta app esta diseñada para poder comprar artículos de Apple",
              image: Center(
                child: Lottie.asset('assets/lottie/welcome.json', height: 300.0),
              ),
            ),
            PageViewModel(
              title: "Productos de calidad",
              body: "Esta app esta diseñada para poder comprar artículos de Apple",
              image: Center(
                child: Lottie.asset('assets/lottie/apple_animation.json', height: 300.0),
              ),
            ),
            PageViewModel(
              title: "Configura el tema",
              bodyWidget: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Selecciona el tema que prefieras:"),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          GlobalValues.themeMode.value = 0;
                          ThemeSettings.lightTheme();
                        },
                        child: Text("Claro"),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          GlobalValues.themeMode.value = 1;
                          ThemeSettings.darkTheme();
                        },
                        child: Text("Oscuro"),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          GlobalValues.themeMode.value = 2;
                          ThemeSettings.customTheme();
                        },
                        child: Text("Naranja"),
                      ),
                    ],
                  ),
                ],
              ),
              image: Center(
                child: Lottie.asset('assets/lottie/theme_animation.json', height: 175.0),
              ),
            ),
            PageViewModel(
              title: "Permisos de la App",
              body: "Para ofrecerte la mejor experiencia, la app necesita acceso a la cámara y a tu ubicación.",
              image: Center(
                child: Lottie.asset('assets/lottie/permissions_animation.json', height: 200.0),
              ),
              footer: ElevatedButton(
                onPressed: () async {
                  Map<Permission, PermissionStatus> statuses = await [
                    Permission.camera,
                    Permission.location,
                  ].request();

                  if (statuses[Permission.camera]!.isGranted &&
                      statuses[Permission.location]!.isGranted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("¡Permisos otorgados!")),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Algunos permisos fueron denegados.")),
                    );
                  }
                },
                child: Text("Otorgar permisos"),
              ),
            ),
          ],
          onDone: () async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('onboardingSeen', true);
            Navigator.of(context).pushReplacementNamed('/login');
          },
          onSkip: () async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('onboardingSeen', true);
            Navigator.of(context).pushReplacementNamed('/login');
          },
          showSkipButton: true,
          skip: const Text("Saltar"),
          next: const Icon(Icons.arrow_forward),
          done: const Text("Empezar", style: TextStyle(fontWeight: FontWeight.w600)),
          dotsDecorator: DotsDecorator(
            size: const Size.square(10.0),
            activeSize: const Size(22.0, 10.0),
            activeColor: Theme.of(context).primaryColor,
            color: Colors.black26,
            spacing: const EdgeInsets.symmetric(horizontal: 3.0),
            activeShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.0),
            ),
          ),
        ),
      ),
    );
  }
}