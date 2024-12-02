import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;

  final LatLng _sucursalLocation = const LatLng(20.5139939, -100.9951458); // Cambia las coordenadas de tu sucursal

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubicación de la Sucursal'),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _sucursalLocation,
          zoom: 15.0,
        ),
        markers: {
          Marker(
            markerId: const MarkerId('sucursal'),
            position: _sucursalLocation,
            infoWindow: const InfoWindow(title: 'Sucursal', snippet: 'Sucursal Principal'),
          ),
        },
      ),
    );
  }
}
