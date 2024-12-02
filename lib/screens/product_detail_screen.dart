import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gamestech/components/SlideToBuyButton.dart';

class ProductDetail extends StatelessWidget {
  final String image;
  final String modelo;
  final String marca;
  final double precio;
  final String status;
  final String productId;

  const ProductDetail({
    Key? key,
    required this.image,
    required this.modelo,
    required this.marca,
    required this.precio,
    required this.status,
    required this.productId,
  }) : super(key: key);

 Future<void> _addToCart(BuildContext context) async {
  // Verificar si el producto está "vendido"
  if (status == 'vendido') {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Este producto ya está vendido y no se puede agregar al carrito.")),
    );
    return;
  }

  final currentUser = FirebaseAuth.instance.currentUser;
  final cartRef = FirebaseFirestore.instance
      .collection('users')
      .doc(currentUser?.uid)
      .collection('cart');

  // Verifica si el producto ya existe en el carrito
  final existingProduct = await cartRef.doc(productId).get();

  if (existingProduct.exists) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Este producto ya está en el carrito.")),
    );
    return;
  }

  // Agrega el producto al carrito
  await cartRef.doc(productId).set({
    'image': image,
    'modelo': modelo,
    'marca': marca,
    'precio': precio,
    'status': status,
    'quantity': 1,
  });

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Producto agregado al carrito.")),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Imagen del producto con bordes redondeados
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
                child: Image.network(
                  image,
                  height: 300,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 40,
                left: 16,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new),
                  color: Colors.white,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              Positioned(
                top: 40,
                right: 16,
                child: IconButton(
                  icon: const Icon(Icons.favorite_border),
                  color: Colors.white,
                  onPressed: () {
                    // Acción para agregar a favoritos
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Producto agregado a favoritos.")),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Detalles del producto
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    modelo,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    marca,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: status == 'Disponible'
                              ? Colors.green.withOpacity(0.2)
                              : Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: status == 'Disponible'
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Informacion del producto",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Descubre el modelo $modelo, diseñado para superar tus expectativas. Este producto, parte de la prestigiosa marca $marca. ¡Transforma tu experiencia diaria con este increíble producto!",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const Spacer(),
                  // Precio y botón deslizable
                  Column(
                    children: [
                      const SizedBox(height: 16),
                      Column(
                        children: [
                          Text(
                            '\$${precio.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SlideToBuyButton(
                            price: precio,
                            onBuy: () => _addToCart(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
