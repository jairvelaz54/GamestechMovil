import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String capacidad;
  final String color;
  final Timestamp createAt; // Firestore Timestamp
  final String image;
  final String marca;
  final String modelo;
  final Map<String, dynamic> settingIphone; // Mapa para configuraciones específicas del iPhone
  final Map<String, dynamic> stats; // Mapa para estadísticas, que contiene descuento, precio, status, tipo

  Product({
    required this.capacidad,
    required this.color,
    required this.createAt,
    required this.image,
    required this.marca,
    required this.modelo,
    required this.settingIphone,
    required this.stats,
  });

  // Método para convertir de un mapa de Firestore a un objeto de tipo Product
  factory Product.fromFirestore(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;
    return Product(
      capacidad: data['capacidad'],
      color: data['color'],
      createAt: data['createAt'],
      image: data['image'],
      marca: data['marca'],
      modelo: data['modelo'],
      settingIphone: data['setting_iphone'] ?? {},
      stats: data['stats'] ?? {},
    );
  }

  // Método para convertir un objeto Product a un mapa, útil para agregar a Firestore
  Map<String, dynamic> toMap() {
    return {
      'capacidad': capacidad,
      'color': color,
      'createAt': createAt,
      'image': image,
      'marca': marca,
      'modelo': modelo,
      'setting_iphone': settingIphone,
      'stats': stats,
    };
  }

  // Métodos de acceso para obtener los campos dentro de setting_iphone
  String get bateria => settingIphone['Bateria'] ?? 'Desconocido';
  String get company => settingIphone['company'] ?? 'Desconocido';
  String get imei => settingIphone['imei'] ?? 'Desconocido';
  String get imei2 => settingIphone['imei2'] ?? 'Desconocido';
  bool get reacondicionado => settingIphone['reacondicionado'] ?? false;
  String get serialNumber => settingIphone['serialNumber'] ?? 'Desconocido';

  // Métodos de acceso para obtener los campos dentro de stats
  double get descuento => stats['descuento'] ?? 0.0;
  double get precio => stats['precio'] ?? 0.0;
  String get status => stats['status'] ?? 'Desconocido';
  String get tipo => stats['tipo'] ?? 'Desconocido';
}
