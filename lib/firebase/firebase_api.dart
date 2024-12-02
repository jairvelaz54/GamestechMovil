import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:gamestech/main.dart';

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotification() async {
    try {
      // Solicitar permisos para notificaciones
      NotificationSettings settings = await _firebaseMessaging.requestPermission();
      print('Permisos de notificaciones: ${settings.authorizationStatus}');

      // Obtener el token del dispositivo
      final token = await _firebaseMessaging.getToken();
      print('Token del dispositivo: $token');

      // Inicializar listeners para notificaciones
      initPushNotification();
    } catch (e) {
      print('Error al inicializar notificaciones: $e');
    }
  }

  void handleMessage(RemoteMessage? message) {
    if (message == null) return;

    // Extraer título y cuerpo de la notificación
    final title = message.notification?.title ?? 'Nueva notificación';
    final body = message.notification?.body ?? 'Sin contenido disponible';

    // Navegar o mostrar contenido según el tipo de mensaje
    navigatorKey.currentState?.pushNamed(
      '/login',
      arguments: message,
    );

    // Mostrar diálogo para el usuario
    _showNotificationDialog(title, body);
  }

  Future<void> initPushNotification() async {
    // Notificaciones cuando la app está cerrada o en background
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);

    // Notificaciones abiertas por el usuario
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);

    // Notificaciones en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        final title = message.notification!.title ?? 'Nueva notificación';
        final body = message.notification!.body ?? 'Sin contenido disponible';

        // Mostrar un Snackbar
        _showNotificationSnackbar(title, body);
      }
    });
  }

  void _showNotificationDialog(String title, String body) {
    showDialog(
      context: navigatorKey.currentContext!,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          title,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        content: Text(
          body,
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Aceptar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showNotificationSnackbar(String title, String body) {
    final snackBar = SnackBar(
      content: Text('$title\n$body'),
      duration: Duration(seconds: 5),
      action: SnackBarAction(
        label: 'Ver',
        onPressed: () {
          navigatorKey.currentState?.pushNamed('/login');
        },
      ),
    );

    ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(snackBar);
  }
}
