import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gamestech/models/product.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

import '../models/product_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  int _selectedIndex = 2; // Índice para la navegación (Favoritos)
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
  }
  /* */
  Stream<List<String>> favoritesStream() {
    // Asegúrate de que el usuario esté autenticado
    if (_currentUser != null) {
      return _firestore
          .collection('users') // Colección de usuarios
          .doc(_currentUser!.uid) // Documento del usuario actual
          .snapshots()
          .map((snapshot) {
        if (snapshot.exists) {
          // Obtiene el campo 'favorites' como una lista de IDs de productos
          List<dynamic> favorites = snapshot.data()?['favorites'] ?? [];
          return List<String>.from(
              favorites); // Convierte a una lista de Strings
        }
        return []; // Si no existe el campo favorites, devuelve una lista vacía
      });
    } else {
      // Si el usuario no está autenticado, devuelve un stream vacío
      return Stream.value([]);
    }
  }

  void onAddFavorite(String productId) async {
    if (_currentUser != null) {
      try {
        DocumentReference userDoc =
            _firestore.collection('users').doc(_currentUser!.uid);
        await userDoc.update({
          'favorites': FieldValue.arrayUnion(
              [productId]), // Agrega el productId al array 'favorites'
        });
        print('Producto agregado a favoritos');
      } catch (e) {
        print('Error al agregar favorito: $e');
      }
    } else {
      print('Usuario no autenticado');
    }
  }

  void onRemoveFavorite(String productId) async {
    if (_currentUser != null) {
      try {
        DocumentReference userDoc =
            _firestore.collection('users').doc(_currentUser!.uid);
        await userDoc.update({
          'favorites': FieldValue.arrayRemove(
              [productId]), // Elimina el productId del array 'favorites'
        });
        print('Producto eliminado de favoritos');
      } catch (e) {
        print('Error al eliminar favorito: $e');
      }
    } else {
      print('Usuario no autenticado');
    }
  }

/* */
  Stream<List<Product>> getFavoriteProducts() {
    if (_currentUser != null) {
      return _firestore
          .collection('users')
          .doc(_currentUser!.uid)
          .snapshots()
          .asyncMap((snapshot) async {
        if (snapshot.exists) {
          List<dynamic> favorites = snapshot.data()?['favorites'] ?? [];
          List<Product> products = [];
          for (var productId in favorites) {
            var productSnapshot =
                await _firestore.collection('iphone').doc(productId).get();
            if (productSnapshot.exists) {
              products.add(Product.fromFirestore(productSnapshot));
            }
          }
          return products;
        }
        return [];
      });
    } else {
      return Stream.value([]);
    }
  }

  void _navigateTo(int index) {
    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/home');
    } else if (index == 1) {
      Navigator.pushReplacementNamed(context, '/cart');
    } else if (index == 2) {
      // Ya estamos en FavoritesScreen
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: myDrawer(),
      appBar: AppBar(
        title: Text('Productos Favoritos',
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          CircleAvatar(
            backgroundImage: _currentUser?.photoURL != null
                ? NetworkImage(_currentUser!.photoURL!)
                : const AssetImage('assets/default_user.png') as ImageProvider,
          ),
          const SizedBox(width: 16),
        ],
      ),
        body: StreamBuilder<List<Product>>(
      stream: getFavoriteProducts(), // Cambiar el stream aquí
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No hay productos disponibles."));
        }
        final products = snapshot.data!;
        return GridView.builder(
          padding: const EdgeInsets.symmetric(vertical: 16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 20,
            childAspectRatio: 0.7,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return ProductCard(
              image: product.image,
              modelo: product.modelo,
              marca: product.marca,
              precio: product.precio,
              status: product.status,
              productId: product.id,
              favoritesStream: favoritesStream(), 
              onAddFavorite: (productId) => onAddFavorite(productId),
              onRemoveFavorite: (productId) => onRemoveFavorite(productId),
            );
          },
        );
      },
    ),
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: _selectedIndex,
        onTap: (index) => _navigateTo(index),
        items: [
          SalomonBottomBarItem(
            icon: const Icon(Icons.store),
            title: const Text("Store"),
            selectedColor: theme.primaryColor,
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.shopping_cart),
            title: const Text("Cart"),
            selectedColor: theme.primaryColor,
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.favorite_border),
            title: const Text("Favorites"),
            selectedColor: theme.primaryColor,
          ),
        ],
      ),
    );
  }

   Widget myDrawer() {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            currentAccountPicture: CircleAvatar(
              backgroundImage: _currentUser?.photoURL != null
                  ? NetworkImage(_currentUser!.photoURL!)
                  : const AssetImage('assets/default_user.png')
                      as ImageProvider,
            ),
            accountName: Text(_currentUser?.displayName ?? 'Usuario'),
            accountEmail: Text(_currentUser?.email ?? 'Correo no disponible'),
            decoration: BoxDecoration(
              color: Colors.blue, // Cambiar el fondo del header a azul
            ),
          ),
          ListTile(
            onTap: () => Navigator.pushNamed(context, '/profile'),
            title: const Text('Configuración del perfil'),
            leading: const Icon(Icons.person),
          ),
          ListTile(
            title: const Text('Configuración de Tema'),
            leading: const Icon(Icons.color_lens),
            onTap: () {
              Navigator.pushNamed(context, '/theme');
            },
          ),
          ListTile(
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacementNamed('/login');
            },
            title: const Text('Salir'),
            leading: const Icon(Icons.exit_to_app),
          ),
        ],
      ),
    );
  }
}
