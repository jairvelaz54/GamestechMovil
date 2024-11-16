import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final String image;
  final String modelo;
  final String marca;
  final double precio;
  final String status; // Usamos el estado del producto para mostrar disponibilidad o algo similar.
  final Function onFavoritePressed; // Acción cuando se presiona el corazón para agregar a favoritos
  final Function onBuyPressed; // Acción cuando se presiona el botón de compra

  const ProductCard({
    Key? key,
    required this.image,
    required this.modelo,
    required this.marca,
    required this.precio,
    required this.status,
    required this.onFavoritePressed,
    required this.onBuyPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              // Imagen del producto
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Center(
                  child: Image.network(
                    image,
                    height: 100,
                  ),
                ),
              ),
              // Corazón para agregar a favoritos
              Positioned(
                right: 8,
                top: 8,
                child: IconButton(
                  icon: const Icon(Icons.favorite_border, color: Colors.red),
                  onPressed: () => onFavoritePressed(), // Acción de agregar a favoritos
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Modelo y marca
                Text(
                  '$modelo - $marca',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                // Estado del producto (Disponible, fuera de stock, etc.)
                Text(
                  status,
                  style: TextStyle(
                    color: Colors.green[800],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                // Precio
                Text(
                  '\$$precio',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                // Botón de compra
                ElevatedButton(
                  onPressed: () => onBuyPressed(), // Acción de compra
                  child: const Text('Comprar'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Colors.orange, // Color de fondo
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), // Bordes redondeados
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
