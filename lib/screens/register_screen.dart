import 'package:flutter/material.dart';
import 'package:gamestech/firebase/email_auth.dart';
import 'package:gamestech/google/githubAuth.dart';
import 'package:gamestech/google/google_auth.dart';

class RegisterScreen extends StatelessWidget {
  final EmailAuth emailAuth = EmailAuth();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GitHubAuth githubAuth = GitHubAuth();
  final GoogleAuth googleAuth = GoogleAuth();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/logo.png', height: 120),
              SizedBox(height: 30),
              Text(
                "Hello! Comienza Registrandote",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              // Campo de nombre
              TextField(
                controller: firstNameController,
                decoration: InputDecoration(
                  hintText: "First Name",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.black)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  filled: false,
                ),
              ),
              SizedBox(height: 15),
              // Campo de apellido
              TextField(
                controller: lastNameController,
                decoration: InputDecoration(
                  hintText: "Last Name",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.black)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  filled: false,
                ),
              ),
              SizedBox(height: 15),
              // Campo de correo electrónico
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: "Email",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.black)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  filled: false,
                ),
              ),
              SizedBox(height: 15),
              // Campo de contraseña
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "Password",
                  suffixIcon: Icon(Icons.visibility),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.black)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  filled: false,
                ),
              ),
              SizedBox(height: 20),
              // Botón de registro
              ElevatedButton(
                onPressed: () async {
                  String firstName = firstNameController.text.trim();
                  String lastName = lastNameController.text.trim();
                  String email = emailController.text.trim();
                  String password = passwordController.text.trim();

                  // Llama a la función para crear el usuario
                  bool result = await emailAuth.createUser(
                      firstName, lastName, email, password);

                  if (result) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('Registro existoso, verificar su correo')),
                    );
                    Navigator.pop(context); // Regresar a la pantalla de login
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Fallo el registro')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text(
                  "Registrar",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(height: 20),
              // Botón para registrarse con GitHub
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("O regístrate con: "),
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
