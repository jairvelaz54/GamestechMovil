import 'package:cloud_firestore/cloud_firestore.dart';
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
  
  // Función para obtener los productos
  Stream<List<Product>> getProducts() {
    return _firestore.collection('products').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Product.fromFirestore(doc); // Asegúrate de que tu clase Product tiene el método fromFirestore
      }).toList();
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
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () {},
                  ),
                  Text(
                    'Nuestros productos',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: () => _signOut(context),
                    child: Icon(Icons.exit_to_app, size: 28, color: theme.primaryColor),
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
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    // Búsqueda de productos
                    Container(
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Buscar Productos',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: Container(
                            margin: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.tune),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
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
                            icon: Icons.phone_iphone,
                            label: 'iPhones',
                            isSelected: true,
                          ),
                          CategoryChip(
                            icon: Icons.watch,
                            label: 'Smartwatch',
                          ),
                          // Aquí puedes agregar más categorías dinámicamente si lo deseas
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // StreamBuilder para cargar productos de Firebase
                    Expanded(
                      child: StreamBuilder<List<Product>>(
                        stream: getProducts(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Center(child: Text("No hay productos disponibles."));
                          }
                          final products = snapshot.data!;
                          return GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.8,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
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
                                onFavoritePressed: () => onFavoritePressed(product),
                                onBuyPressed: () => onBuyPressed(product),
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
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          SalomonBottomBarItem(
            icon: const Icon(Icons.store),
            title: const Text("Store"),
            selectedColor: theme.primaryColor,
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.search),
            title: const Text("Search"),
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
}
