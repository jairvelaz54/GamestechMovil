import 'package:flutter/material.dart';
import 'package:gamestech/firebase/email_auth.dart';
import 'package:gamestech/google/githubAuth.dart';
import 'package:gamestech/google/google_auth.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final EmailAuth emailAuth = EmailAuth();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();
  final GitHubAuth githubAuth = GitHubAuth();
  final GoogleAuth googleAuth = GoogleAuth();

  bool _obscureText = true;
  // Variable para controlar la visibilidad de la contraseña
  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/logo.png',
                  height: 120), // Logo en la parte superior
              SizedBox(height: 30),
              Text(
                "Bienvenido a GAMESTECH de nuevo!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              // Campo de correo electrónico
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: "Enter your email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color: Colors.blue), // Borde azul cuando está enfocado
                  ),
                  filled: false,
                ),
              ),
              SizedBox(height: 15),
              // Campo de contraseña
              TextField(
                controller: passwordController,
                obscureText: _obscureText,
                decoration: InputDecoration(
                  hintText: "Enter your password",
                  suffixIcon: IconButton(
                    icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off),
                    onPressed: _togglePasswordVisibility,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  filled: false,
                ),
              ),
              SizedBox(height: 20),
              // Botón de inicio de sesión
              ElevatedButton(
                onPressed: () async {
                  String email = emailController.text.trim();
                  String password = passwordController.text.trim();

                  bool isLoggedIn =
                      await emailAuth.validateUser(email, password);

                  if (isLoggedIn) {
                    //Navigator.pushReplacementNamed(context, '/dashboard');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Todo correcto aqui envia')),
                    );
                  } else {
                    // Mostrar un mensaje de error si el inicio de sesión falla
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Verificar contraseña o correo.')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Cambiar el color si lo deseas
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),

                  minimumSize: Size(double.infinity, 50), // Ancho completo
                ),
                child: Text(
                  "Login",
                  style: TextStyle(color: Colors.white),
                ),
              ),

              SizedBox(height: 20),
              // Texto de registro
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("No tienes cuenta?",
                      style: TextStyle(color: Colors.grey)),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: Text("Registrate",
                        style: TextStyle(color: Colors.blue)),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("O Inicia sesion con: "),
                  IconButton(
                    icon: Icon(Icons.g_mobiledata, color: Colors.red),
                    onPressed: () async {
                      // Llamada para el inicio de sesión con Google
                      final user = await googleAuth.signInWithGoogle();
                      if (user != null) {
                        // Navegar a la pantalla principal o dashboard
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Todo correcto aqui envia')),
                        );
                      } else {
                        // Mostrar un mensaje de error si falla el inicio de sesión
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Failed to sign in with Google')),
                        );
                      }
                    },
                  ),
                  IconButton(
                    onPressed: () async {
                      final user = await githubAuth.signInWithGitHub();

                      // Aquí puedes implementar la autenticación con GitHub
                      if (user != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('Inicio de sesión con GitHub exitoso')),
                        );
                        Navigator.pop(
                            context); // Regresar a la pantalla principal o dashboard
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('Falló el inicio de sesión con GitHub')),
                        );
                      }
                    },
                    icon: Icon(Icons.code, size: 32, color: Colors.black),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
