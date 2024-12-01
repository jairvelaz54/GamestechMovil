import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({Key? key}) : super(key: key);

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _nameController = TextEditingController();
  File? _selectedImage;
  bool _canUpdatePhoto = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final firebase_auth.User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      final DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(currentUser.uid).get();
      final data = userDoc.data() as Map<String, dynamic>;

      setState(() {
        _nameController.text = data['name'] ?? currentUser.displayName ?? '';
        currentUser.updatePhotoURL(data['photoUrl'] ?? currentUser.photoURL);

        // Verificar si el proveedor de autenticación es correo electrónico
        _canUpdatePhoto = currentUser.providerData.any((provider) =>
            provider.providerId == 'password'); // 'password' es el ID del correo electrónico
      });
    }
  }

  Future<void> _updateProfile() async {
    if (!_canUpdatePhoto) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No puedes actualizar la foto porque no usaste correo electrónico.'),
        ),
      );
      return;
    }

    final firebase_auth.User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      final String newName = _nameController.text.trim();
      String? newPhotoUrl;

      if (_selectedImage != null) {
        newPhotoUrl = await _uploadImage(currentUser);
      }

      await _firestore.collection('users').doc(currentUser.uid).update({
        'name': newName,
        if (newPhotoUrl != null) 'photoUrl': newPhotoUrl,
      });

      if (newPhotoUrl != null) {
        await currentUser.updatePhotoURL(newPhotoUrl);
      }
      await currentUser.updateDisplayName(newName);

      setState(() {
        _selectedImage = null;
      });

      // Recargar los datos del usuario para reflejar los cambios
      await _loadUserData();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado exitosamente')),
      );
    }
  }

  Future<String> _uploadImage(firebase_auth.User user) async {
    if (_selectedImage == null) {
      throw Exception("No hay imagen seleccionada para subir.");
    }

    final String fileName =
        '${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final String filePath = '$fileName';

    try {
      final String response = await Supabase.instance.client.storage
          .from('profile')
          .upload(filePath, _selectedImage!);

      if (response.isEmpty) {
        throw Exception('Error al subir imagen: Respuesta vacía.');
      }

      final String publicUrl = Supabase.instance.client.storage
          .from('profile')
          .getPublicUrl(filePath);

      if (publicUrl.isEmpty) {
        throw Exception('No se pudo obtener la URL pública de la imagen.');
      }

      return publicUrl;
    } catch (e) {
      print('Error al subir la imagen: $e');
      throw Exception('No se pudo subir la imagen');
    }
  }

  Future<void> _selectImage() async {
    if (!_canUpdatePhoto) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No puedes seleccionar una foto porque no usaste correo electrónico.'),
        ),
      );
      return;
    }

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
    final firebase_auth.User? currentUser = _auth.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Configuración del Perfil',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _selectImage,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 70,
                    backgroundImage: _selectedImage != null
                        ? FileImage(_selectedImage!)
                        : (currentUser?.photoURL != null
                            ? NetworkImage(currentUser!.photoURL!)
                            : const AssetImage('assets/default_user.jpg'))
                            as ImageProvider,
                  ),
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: _canUpdatePhoto ? Colors.blue : Colors.grey,
                    child: Icon(
                      Icons.camera_alt,
                      color: _canUpdatePhoto ? Colors.white : Colors.black26,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre',
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ListTile(
                      leading: const Icon(Icons.email),
                      title: Text(currentUser?.email ?? 'Correo no disponible'),
                      subtitle: const Text('Conectado con este correo'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _updateProfile,
              child: const Text(
                'Guardar Cambios',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
