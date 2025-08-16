import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:convert';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();
  
  late FirebaseMessaging _messaging;
  String? _fcmToken;
  
  // Callbacks
  Function(RemoteMessage)? onMessageReceived;
  Function(Map<String, dynamic>)? onNotificationTapped;

  Future<void> initialize() async {
    // Inicializar Firebase Messaging
    _messaging = FirebaseMessaging.instance;
    
    // Solicitar permisos
    await _requestPermissions();
    
    // Obtener token FCM
    _fcmToken = await _messaging.getToken();
    debugPrint('FCM Token: $_fcmToken');
    
    // Configurar notificaciones locales
    await _initializeLocalNotifications();
    
    // Configurar handlers de mensajes
    _configureMessageHandlers();
  }

  Future<void> _requestPermissions() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    
    debugPrint('Notification permissions: ${settings.authorizationStatus}');
  }

  Future<void> _initializeLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const settings = InitializationSettings(
      android: android,
      iOS: iOS,
    );
    
    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  void _configureMessageHandlers() {
    // Mensajes en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Mensaje recibido en primer plano: ${message.messageId}');
      
      // Mostrar notificación local
      _showLocalNotification(message);
      
      // Callback personalizado
      onMessageReceived?.call(message);
    });
    
    // Mensajes en segundo plano
    FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);
    
    // Cuando se toca una notificación
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Notificación tocada: ${message.messageId}');
      _handleNotificationNavigation(message.data);
    });
  }

  // Handler estático para mensajes en segundo plano
  static Future<void> _backgroundMessageHandler(RemoteMessage message) async {
    debugPrint('Mensaje en segundo plano: ${message.messageId}');
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;
    
    const androidDetails = AndroidNotificationDetails(
      'torneos_channel',
      'Torneos Notificaciones',
      channelDescription: 'Notificaciones de la app de torneos',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      color: Color(0xFF97FB57),
    );
    
    const iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );
    
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      notification.title ?? 'Torneos App',
      notification.body ?? '',
      details,
      payload: json.encode(message.data),
    );
  }

  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      final data = json.decode(response.payload!);
      _handleNotificationNavigation(data);
    }
  }

  void _handleNotificationNavigation(Map<String, dynamic> data) {
    // Navegar según el tipo de notificación
    final type = data['type'] as String?;
    
    switch (type) {
      case 'tournament':
        // Navegar a detalles del torneo
        final tournamentId = data['tournamentId'];
        onNotificationTapped?.call({
          'action': 'navigate',
          'screen': 'tournament_detail',
          'id': tournamentId,
        });
        break;
        
      case 'match':
        // Navegar a detalles del partido
        final matchId = data['matchId'];
        onNotificationTapped?.call({
          'action': 'navigate',
          'screen': 'match_detail',
          'id': matchId,
        });
        break;
        
      case 'payment':
        // Navegar a pagos
        onNotificationTapped?.call({
          'action': 'navigate',
          'screen': 'payments',
        });
        break;
        
      case 'chat':
        // Navegar al chat
        final chatId = data['chatId'];
        onNotificationTapped?.call({
          'action': 'navigate',
          'screen': 'chat',
          'id': chatId,
        });
        break;
        
      default:
        // Navegar al home
        onNotificationTapped?.call({
          'action': 'navigate',
          'screen': 'home',
        });
    }
  }

  // Suscribirse a tópicos
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    debugPrint('Suscrito al tópico: $topic');
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    debugPrint('Desuscrito del tópico: $topic');
  }

  // Enviar notificación local programada
  Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
    Map<String, dynamic>? data,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'scheduled_channel',
      'Notificaciones Programadas',
      channelDescription: 'Notificaciones programadas de torneos',
      importance: Importance.high,
      priority: Priority.high,
      color: Color(0xFF97FB57),
    );
    
    const iOSDetails = DarwinNotificationDetails();
    
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );
    
    await _localNotifications.zonedSchedule(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      scheduledDate,
      details,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: data != null ? json.encode(data) : null,
    );
  }

  // Cancelar notificación programada
  Future<void> cancelScheduledNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  // Cancelar todas las notificaciones
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  // Obtener token FCM
  String? get fcmToken => _fcmToken;

  // Actualizar token FCM
  Future<void> refreshFCMToken() async {
    _fcmToken = await _messaging.getToken();
    debugPrint('Nuevo FCM Token: $_fcmToken');
  }

  // Notificaciones específicas de la app
  Future<void> notifyTournamentStart(String tournamentName, DateTime startTime) async {
    await scheduleNotification(
      title: '¡Tu torneo comienza pronto!',
      body: '$tournamentName empieza a las ${_formatTime(startTime)}',
      scheduledDate: startTime.subtract(const Duration(hours: 1)),
      data: {'type': 'tournament', 'name': tournamentName},
    );
  }

  Future<void> notifyPaymentReminder(String tournamentName, double amount) async {
    await _showLocalNotification(RemoteMessage(
      notification: RemoteNotification(
        title: 'Recordatorio de Pago',
        body: 'Tienes un pago pendiente de S/ $amount para $tournamentName',
      ),
      data: {'type': 'payment', 'tournament': tournamentName, 'amount': amount},
    ));
  }

  Future<void> notifyMatchResult(String matchName, String result) async {
    await _showLocalNotification(RemoteMessage(
      notification: RemoteNotification(
        title: 'Resultado del Partido',
        body: '$matchName: $result',
      ),
      data: {'type': 'match', 'name': matchName, 'result': result},
    ));
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}