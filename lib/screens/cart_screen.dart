import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gamestech/screens/historial_screen.dart';
import 'package:gamestech/screens/map_screen.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:flutter_paypal_payment/flutter_paypal_payment.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  int _selectedIndex = 1;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
  }

  void _navigateTo(int index) {
    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/home');
    } else if (index == 1) {
      // Ya estamos en el carrito
    } else if (index == 2) {
      Navigator.pushReplacementNamed(context, '/favorites');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: myDrawer(),
      appBar: AppBar(
        title: Text(
          'Carrito',
          style:
              theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('users')
            .doc(_currentUser?.uid)
            .collection('cart')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Tu carrito está vacío.'));
          }

          final cartItems = snapshot.data!.docs;

          final total = cartItems.fold<double>(
            0.0,
            (sum, item) => sum + (item['precio'] as num).toDouble(),
          );
          final items = cartItems.map((item) {
            return {
              "name": item['modelo'],
              "quantity": 1,
              "price": (item['precio'] as num).toStringAsFixed(2),
              "currency": "USD",
            };
          }).toList();

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(15),
                              bottomLeft: Radius.circular(15),
                            ),
                            child: Image.network(
                              item['image'],
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['modelo'],
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    item['marca'],
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '\$${(item['precio'] as num).toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await _firestore
                                  .collection('users')
                                  .doc(_currentUser?.uid)
                                  .collection('cart')
                                  .doc(item.id)
                                  .delete();
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const MapScreen(),
                        ));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(color: Colors.blue),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.map, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            "Ver Sucursal",
                            style: TextStyle(color: Colors.blue),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) => PaypalCheckoutView(
                            sandboxMode: true,
                            clientId:
                                "AaC5uvWzdZ5ATnEgvR81r6IJQynfIw2aT7pADFKrSQ55OejISvvrTrycwlio3AXsYb0r6RcEPcKkRj0V",
                            secretKey:
                                "EO5Hw6twCWw4U1LgfvxDglArd-AL5gYKORKpfOXq2z3Pgc3fPgTIN_SoRKFDQFwlLXhIAxZs8sYMaFok",
                            transactions: [
                              {
                                "amount": {
                                  "total": total.toStringAsFixed(2),
                                  "currency": "USD",
                                  "details": {
                                    "subtotal": total.toStringAsFixed(2),
                                    "shipping": '0',
                                    "shipping_discount": 0,
                                  }
                                },
                                "description":
                                    "Pago de productos en el carrito.",
                                "item_list": {
                                  "items": items,
                                },
                              }
                            ],
                            note: "Gracias por tu compra.",
                            onSuccess: (Map params) async {
                              log("onSuccess: $params");
                              try {
                                final cartRef = _firestore
                                    .collection('users')
                                    .doc(_currentUser?.uid)
                                    .collection('cart');
                                final cartItems = await cartRef.get();
                                List<Map<String, dynamic>> purchasedItems = [];
                                for (var item in cartItems.docs) {
                                  final productId = item.id;
                                  final productData = item.data();
                                  await _firestore
                                      .collection('iphone')
                                      .doc(productId)
                                      .update({'stats.status': 'vendido'});
                                  purchasedItems.add({
                                    'productId': productId,
                                    'modelo': productData['modelo'],
                                    'marca': productData['marca'],
                                    'precio': productData['precio'],
                                  });
                                }
                                await _firestore.collection('buys').add({
                                  'userId': _currentUser?.uid,
                                  'purchaseDate': Timestamp.now(),
                                  'items': purchasedItems,
                                  'total': total,
                                });
                                for (var item in cartItems.docs) {
                                  await cartRef.doc(item.id).delete();
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("Pago exitoso con PayPal")),
                                );
                              } catch (e) {
                                log("Error al procesar la compra: $e");
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          "Ocurrió un error al procesar la compra")),
                                );
                              }
                              Navigator.pop(context);
                            },
                            onError: (error) {
                              log("onError: $error");
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text("Error en el pago con PayPal")),
                              );
                              Navigator.pop(context);
                            },
                            onCancel: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Pago cancelado")),
                              );
                              Navigator.pop(context);
                            },
                          ),
                        ));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.payment, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            "Pagar con PayPal",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const PurchaseHistoryScreen()),
              );
            },
            title: const Text('Historial'),
            leading: const Icon(Icons.history),
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
