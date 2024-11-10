import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmailAuth {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<bool> createUser(String firstName, String lastName, String email, String password) async {
    try {
      final credentials = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await credentials.user!.sendEmailVerification();

      // Almacenar la información del usuario en Firestore
      await firestore.collection('users').doc(credentials.user!.uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'createdAt': DateTime.now(),
      });

      return true;
    } on FirebaseAuthException catch (e) {
      print(e.message);
    }
    return false;
  }

Future<bool> validateUser(String email, String password) async {
    try {
      final userCredential = await auth.signInWithEmailAndPassword(
          email: email, password: password);
      if (userCredential.user!.emailVerified) {
        return true; 
      } else {
        print("Email not verified. Please verify your email before logging in.");
        return false;
      }
    } on FirebaseAuthException catch (e) {
      print("Error: ${e.message}");
      return false;
    }
  }
}