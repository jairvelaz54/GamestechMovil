import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({Key? key}) : super(key: key);

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _nameController = TextEditingController();
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      final DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(currentUser.uid).get();
      final data = userDoc.data() as Map<String, dynamic>;
      _nameController.text = data['name'] ?? currentUser.displayName ?? '';
    }
  }

  Future<void> _updateProfile() async {
    final User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      final String newName = _nameController.text.trim();
      // Subir nueva información a Firestore
      await _firestore.collection('users').doc(currentUser.uid).update({
        'name': newName,
        if (_selectedImage != null) 'photoUrl': await _uploadImage(currentUser),
      });

      // Actualizar el perfil de FirebaseAuth
      await currentUser.updateDisplayName(newName);

      // Refrescar el UI
      setState(() {
        _selectedImage = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado exitosamente')),
      );
    }
  }

  Future<String> _uploadImage(User user) async {
    // Simulación de subida de imagen. Reemplázalo por tu lógica de almacenamiento.
    final String photoUrl = "path/to/your/image";
    return photoUrl;
  }

  Future<void> _selectImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? currentUser = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración del Perfil'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Foto de perfil
            GestureDetector(
              onTap: _selectImage,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: _selectedImage != null
                        ? FileImage(_selectedImage!)
                        : (currentUser?.photoURL != null
                            ? NetworkImage(currentUser!.photoURL!)
                            : const AssetImage('assets/default_user.png'))
                            as ImageProvider,
                  ),
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.edit, color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Nombre
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Correo
            ListTile(
              leading: const Icon(Icons.email),
              title: Text(currentUser?.email ?? 'Correo no disponible'),
              subtitle: const Text('Conectado con este correo'),
            ),
            const SizedBox(height: 20),

            // Botón de guardar cambios
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _updateProfile,
              icon: const Icon(Icons.save),
              label: const Text('Guardar Cambios'),
            ),
          ],
        ),
      ),
    );
  }
}
