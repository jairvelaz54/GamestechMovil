import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GitHubAuth {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserCredential> signInWithGitHub() async {
    try {
      // Iniciar el proveedor de autenticación de GitHub
      GithubAuthProvider githubAuthProvider = GithubAuthProvider();
      
      // Autenticar con Firebase usando GitHub
      UserCredential userCredential = await FirebaseAuth.instance.signInWithProvider(githubAuthProvider);

      // Obtener información del usuario autenticado
      User? user = userCredential.user;

      if (user != null) {
        // Guardar la información del usuario en Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'displayName': user.displayName ?? 'Sin nombre',
          'email': user.email ?? 'Sin correo',
          'photoURL': user.photoURL ?? '',
          'provider': 'github',
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      
      return userCredential;
    } catch (e) {
      print('Error al autenticar con GitHub: $e');
      rethrow;
    }
  }
}
