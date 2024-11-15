import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gamestech/firebase_options.dart';
import 'package:gamestech/screens/home_screen.dart';
import 'package:gamestech/screens/login_screen.dart';
import 'package:gamestech/screens/register_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        "/login": (context) => LoginScreen(),
        "/register": (context) => RegisterScreen(),
        "/home": (context) => HomeScreen(),
      },
    );
  }
}
