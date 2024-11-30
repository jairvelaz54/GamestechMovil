import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gamestech/models/category_chip.dart';
import 'package:gamestech/models/product.dart';
import 'package:gamestech/models/product_card.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;
  int _selectedBottomNavIndex = 0; // Índice para SalomonBottomBar
  int _cartItemCount = 0;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser; // Obtiene el usuario actual
    _fetchCartItemCount();
  }

  void _fetchCartItemCount() {
    _firestore
        .collection('users')
        .doc(_currentUser?.uid)
        .collection('cart')
        .snapshots()
        .listen((snapshot) {
      setState(() {
        _cartItemCount = snapshot.docs.length;
      });
    });
  }

  String _selectedFilter = 'Todos'; // 'Todos', 'smartphone', 'smartwatch'

  // Función para obtener los productos con un filtro
  Stream<List<Product>> getProducts({String filter = 'Todos'}) {
    final collection = _firestore.collection('iphone');
    if (filter == 'Todos') {
      return collection.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
      });
    } else {
      return collection
          .where('stats.tipo', isEqualTo: filter)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
      });
    }
  }

  String _searchText = ''; // Almacena el texto del buscador.
/* favoritos inicio */
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

/*fin */
  // Método para obtener los productos con filtro y búsqueda.
  Stream<List<Product>> setProductsFilter(String tipo) {
    Query query = _firestore.collection('iphone');

    if (tipo != "all") {
      query = query.where('stats.tipo', isEqualTo: tipo);
    }
    if (_searchText.isNotEmpty) {
      query = query
          .where('modelo', isGreaterThanOrEqualTo: _searchText)
          .where('modelo', isLessThanOrEqualTo: '$_searchText\uf8ff');
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    });
  }

  // Función para manejar el cambio de filtro
  void _updateFilter(String filter, int index) {
    setState(() {
      _selectedFilter = filter;
      _selectedBottomNavIndex = index; // Resetea el índice de SalomonBottomBar
    });
  }

  // Función para manejar el producto favorito
  void onFavoritePressed(Product product) {
    // Lógica para agregar el producto a favoritos (guardar en Firebase)
    print('Producto agregado a favoritos: ${product.modelo}');
  }

  // Función para manejar la compra
  void onBuyPressed(Product product) {
    // Lógica para manejar la compra (ej. redirigir a una pantalla de pago)
    print('Comprando: ${product.modelo}');
  }

  // Método para cerrar sesión
  void _signOut(BuildContext context) {
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: myDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.shopping_cart),
                        onPressed: () {
                          Navigator.pushNamed(context, '/cart');
                        },
                      ),
                      if (_cartItemCount > 0)
                        Positioned(
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '$_cartItemCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nuestros',
                      style: theme.textTheme.titleLarge,
                    ),
                    Text(
                      'Productos',
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    // Búsqueda de productos
                    Container(
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            _searchText = value
                                .trim(); // Actualiza el texto del buscador.
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Buscar Productos',
                          suffixIcon: Container(
                            margin: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.search),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Categorías
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          CategoryChip(
                            icon: Icons.all_inclusive,
                            label: 'Todos',
                            isSelected: _selectedIndex == 0,
                            onTap: () {
                              setState(() {
                                _selectedIndex = 0;
                              });
                              setProductsFilter("all");
                            },
                          ),
                          CategoryChip(
                            icon: Icons.phone_iphone,
                            label: 'iPhones',
                            isSelected: _selectedIndex == 1,
                            onTap: () {
                              setState(() {
                                _selectedIndex = 1;
                                setProductsFilter("smartphone");
                              });
                            },
                          ),
                          CategoryChip(
                            icon: Icons.watch,
                            label: 'Smartwatch',
                            isSelected: _selectedIndex == 2,
                            onTap: () {
                              setState(() {
                                _selectedIndex = 2;
                              });
                              setProductsFilter("smartwatch");
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // StreamBuilder para cargar productos de Firebase
                    Expanded(
                      child: StreamBuilder<List<Product>>(
                        stream: setProductsFilter(
                          _selectedIndex == 0
                              ? "all"
                              : _selectedIndex == 1
                                  ? "smartphone"
                                  : "smartwatch",
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Center(
                                child: Text("No hay productos disponibles."));
                          }
                          final products = snapshot.data!;
                          return GridView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
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
                                productId: product
                                    .id, // Asegúrate de tener el productId en tu modelo
                                favoritesStream:
                                    favoritesStream(), // Este es tu stream de favoritos
                                onAddFavorite: (productId) =>
                                    onAddFavorite(productId),
                                onRemoveFavorite: (productId) =>
                                    onRemoveFavorite(productId),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: _selectedBottomNavIndex,
        onTap: (index) {
          if (index == 1) {
            Navigator.pushNamed(context, '/cart');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/favorites');
          } else {
            setState(() {
              _selectedBottomNavIndex = index;
            });
          }
        },
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
