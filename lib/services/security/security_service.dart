import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../api/security_api_service.dart';

class SecurityService {
  static final SecurityService _instance = SecurityService._internal();
  factory SecurityService() => _instance;
  SecurityService._internal();

  // Configuración de seguridad
  static const int MIN_PASSWORD_LENGTH = 8;
  static const int MAX_LOGIN_ATTEMPTS = 3;
  static const int LOCKOUT_DURATION_MINUTES = 30;
  static const int SESSION_TIMEOUT_MINUTES = 30;
  
  // Detección de patrones maliciosos
  final List<String> _sqlInjectionPatterns = [
    r"('\s*OR\s*'1'\s*=\s*'1)",
    r"(--\s*$)",
    r"(;\s*DROP\s+TABLE)",
    r"(;\s*DELETE\s+FROM)",
    r"(UNION\s+SELECT)",
    r"(<script[^>]*>)",
    r"(javascript:)",
    r"(onload\s*=)",
    r"(onclick\s*=)",
    r"(onerror\s*=)",
  ];

  final Map<String, DeviceInfo> _trustedDevices = {};
  final Map<String, int> _failedLoginAttempts = {};
  final Map<String, DateTime> _lockedAccounts = {};
  final Map<String, SessionInfo> _activeSessions = {};
  
  // Sistema de detección de anomalías - limitado para reducir memoria
  final List<SecurityEvent> _securityEvents = [];
  static const int MAX_EVENTS_IN_MEMORY = 100;
  
  // API para comunicación con MCP/N8N
  late final SecurityApiService _apiService;

  Future<void> initialize() async {
    _apiService = SecurityApiService();
    await _loadTrustedDevices();
    _startSecurityMonitoring();
  }

  // Validación y sanitización de inputs
  String sanitizeInput(String input) {
    if (input.isEmpty) return input;
    
    // Remover caracteres peligrosos
    String sanitized = input
        .replaceAll(RegExp(r'[<>"]'), '')
        .replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '') // Control characters
        .trim();
    
    // Verificar patrones de inyección SQL
    for (String pattern in _sqlInjectionPatterns) {
      if (RegExp(pattern, caseSensitive: false).hasMatch(sanitized)) {
        _reportSecurityEvent(SecurityEventType.sqlInjectionAttempt, {
          'input': input,
          'pattern': pattern,
        });
        throw SecurityException('Input validation failed');
      }
    }
    
    return sanitized;
  }

  // Validación de email segura
  bool isValidEmail(String email) {
    final sanitized = sanitizeInput(email);
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+$',
    );
    return emailRegex.hasMatch(sanitized);
  }

  // Hash seguro de contraseñas - optimizado
  String hashPassword(String password, String salt) {
    final bytes = utf8.encode(password + salt);
    final digest = sha256.convert(bytes);
    // Reducir iteraciones para mejorar rendimiento (1000 en lugar de 10000)
    var result = digest;
    for (int i = 0; i < 1000; i++) {
      result = sha256.convert(result.bytes);
    }
    return result.toString();
  }

  // Generación de salt único
  String generateSalt() {
    final random = Random.secure();
    final saltBytes = List<int>.generate(32, (i) => random.nextInt(256));
    return base64.encode(saltBytes);
  }

  // Verificación de dispositivo
  Future<bool> verifyDevice() async {
    final deviceInfo = await _getDeviceInfo();
    final deviceId = deviceInfo.id;
    
    if (_trustedDevices.containsKey(deviceId)) {
      final trusted = _trustedDevices[deviceId]!;
      if (trusted.fingerprint == deviceInfo.fingerprint) {
        return true;
      }
    }
    
    // Dispositivo no reconocido
    _reportSecurityEvent(SecurityEventType.unknownDevice, {
      'deviceId': deviceId,
      'fingerprint': deviceInfo.fingerprint,
    });
    
    return false;
  }

  // Control de intentos de login
  Future<bool> canAttemptLogin(String email) async {
    final sanitizedEmail = sanitizeInput(email);
    
    // Verificar si la cuenta está bloqueada
    if (_lockedAccounts.containsKey(sanitizedEmail)) {
      final lockTime = _lockedAccounts[sanitizedEmail]!;
      final unlockTime = lockTime.add(Duration(minutes: LOCKOUT_DURATION_MINUTES));
      
      if (DateTime.now().isBefore(unlockTime)) {
        final remainingMinutes = unlockTime.difference(DateTime.now()).inMinutes;
        throw SecurityException(
          'Cuenta bloqueada. Intenta nuevamente en $remainingMinutes minutos.'
        );
      } else {
        _lockedAccounts.remove(sanitizedEmail);
        _failedLoginAttempts.remove(sanitizedEmail);
      }
    }
    
    return true;
  }

  // Registrar intento fallido
  void recordFailedLogin(String email) {
    final sanitizedEmail = sanitizeInput(email);
    _failedLoginAttempts[sanitizedEmail] = 
        (_failedLoginAttempts[sanitizedEmail] ?? 0) + 1;
    
    if (_failedLoginAttempts[sanitizedEmail]! >= MAX_LOGIN_ATTEMPTS) {
      _lockedAccounts[sanitizedEmail] = DateTime.now();
      _reportSecurityEvent(SecurityEventType.accountLocked, {
        'email': sanitizedEmail,
        'attempts': _failedLoginAttempts[sanitizedEmail],
      });
    }
  }

  // Limpiar intentos después de login exitoso
  void clearFailedAttempts(String email) {
    final sanitizedEmail = sanitizeInput(email);
    _failedLoginAttempts.remove(sanitizedEmail);
  }

  // Gestión de sesiones seguras
  String createSecureSession(String userId, String deviceId) {
    final sessionId = _generateSecureToken();
    final session = SessionInfo(
      id: sessionId,
      userId: userId,
      deviceId: deviceId,
      createdAt: DateTime.now(),
      lastActivity: DateTime.now(),
    );
    
    _activeSessions[sessionId] = session;
    _reportSecurityEvent(SecurityEventType.sessionCreated, {
      'userId': userId,
      'deviceId': deviceId,
    });
    
    return sessionId;
  }

  // Validar sesión activa
  bool isSessionValid(String sessionId) {
    if (!_activeSessions.containsKey(sessionId)) {
      return false;
    }
    
    final session = _activeSessions[sessionId]!;
    final now = DateTime.now();
    final timeout = session.lastActivity.add(
      Duration(minutes: SESSION_TIMEOUT_MINUTES)
    );
    
    if (now.isAfter(timeout)) {
      _activeSessions.remove(sessionId);
      _reportSecurityEvent(SecurityEventType.sessionTimeout, {
        'sessionId': sessionId,
      });
      return false;
    }
    
    // Actualizar última actividad
    session.lastActivity = now;
    return true;
  }

  // Detección de comportamiento anómalo
  Future<void> checkForAnomalies(String userId, String action) async {
    final recentEvents = _securityEvents
        .where((e) => e.userId == userId)
        .where((e) => e.timestamp.isAfter(
          DateTime.now().subtract(Duration(minutes: 5))
        ))
        .toList();
    
    // Detectar acciones rápidas sospechosas
    if (recentEvents.length > 50) {
      _reportSecurityEvent(SecurityEventType.suspiciousActivity, {
        'userId': userId,
        'action': action,
        'eventCount': recentEvents.length,
      });
      
      // Notificar a MCP/N8N
      await _apiService.reportAnomalyToMCP({
        'type': 'rapid_actions',
        'userId': userId,
        'eventCount': recentEvents.length,
      });
    }
  }

  // Reportar eventos de seguridad - con límite de memoria
  void _reportSecurityEvent(SecurityEventType type, Map<String, dynamic> data) {
    final event = SecurityEvent(
      type: type,
      timestamp: DateTime.now(),
      data: data,
      userId: data['userId'] ?? 'unknown',
    );
    
    _securityEvents.add(event);
    
    // Limitar eventos en memoria para evitar consumo excesivo
    if (_securityEvents.length > MAX_EVENTS_IN_MEMORY) {
      _securityEvents.removeRange(0, _securityEvents.length - MAX_EVENTS_IN_MEMORY);
    }
    
    // Enviar a MCP/N8N para análisis
    _apiService.sendSecurityEvent(event);
    
    // Log local reducido
    if (type == SecurityEventType.sqlInjectionAttempt || 
        type == SecurityEventType.accountLocked) {
      debugPrint('SECURITY EVENT: ${type.toString()}');
    }
  }

  // Monitoreo bajo demanda de seguridad
  void _startSecurityMonitoring() {
    // Monitoreo reducido para mejorar rendimiento
    // Verificar sesiones cada 5 minutos en lugar de cada minuto
    Stream.periodic(Duration(minutes: 5)).listen((_) {
      _cleanupExpiredSessions();
      // _checkForSecurityThreats(); // Deshabilitado para reducir carga
    });
  }

  void _cleanupExpiredSessions() {
    final now = DateTime.now();
    _activeSessions.removeWhere((id, session) {
      final expired = now.isAfter(
        session.lastActivity.add(Duration(minutes: SESSION_TIMEOUT_MINUTES))
      );
      if (expired) {
        _reportSecurityEvent(SecurityEventType.sessionExpired, {
          'sessionId': id,
          'userId': session.userId,
        });
      }
      return expired;
    });
  }

  Future<void> _checkForSecurityThreats() async {
    // Analizar patrones de eventos recientes
    final recentEvents = _securityEvents
        .where((e) => e.timestamp.isAfter(
          DateTime.now().subtract(Duration(hours: 1))
        ))
        .toList();
    
    // Detectar patrones sospechosos
    final suspiciousPatterns = _analyzeSuspiciousPatterns(recentEvents);
    
    if (suspiciousPatterns.isNotEmpty) {
      await _apiService.reportThreatsToMCP(suspiciousPatterns);
    }
  }

  List<Map<String, dynamic>> _analyzeSuspiciousPatterns(
    List<SecurityEvent> events
  ) {
    final patterns = <Map<String, dynamic>>[];
    
    // Detectar múltiples intentos de SQL injection
    final sqlAttempts = events
        .where((e) => e.type == SecurityEventType.sqlInjectionAttempt)
        .toList();
    if (sqlAttempts.length > 3) {
      patterns.add({
        'type': 'multiple_sql_injection_attempts',
        'count': sqlAttempts.length,
        'events': sqlAttempts.map((e) => e.toJson()).toList(),
      });
    }
    
    // Detectar múltiples dispositivos desconocidos
    final unknownDevices = events
        .where((e) => e.type == SecurityEventType.unknownDevice)
        .toList();
    if (unknownDevices.length > 5) {
      patterns.add({
        'type': 'multiple_unknown_devices',
        'count': unknownDevices.length,
        'events': unknownDevices.map((e) => e.toJson()).toList(),
      });
    }
    
    return patterns;
  }

  // Obtener información del dispositivo
  Future<DeviceInfo> _getDeviceInfo() async {
    // Implementación específica por plataforma
    return DeviceInfo(
      id: 'device_${DateTime.now().millisecondsSinceEpoch}',
      fingerprint: _generateDeviceFingerprint(),
      platform: 'flutter',
      lastSeen: DateTime.now(),
    );
  }

  String _generateDeviceFingerprint() {
    // Generar fingerprint único del dispositivo
    final data = '${DateTime.now().millisecondsSinceEpoch}_device';
    return sha256.convert(utf8.encode(data)).toString();
  }

  String _generateSecureToken() {
    final random = Random.secure();
    final values = List<int>.generate(32, (i) => random.nextInt(256));
    return base64Url.encode(values);
  }

  Future<void> _loadTrustedDevices() async {
    // Cargar dispositivos confiables desde almacenamiento seguro
  }
}

// Excepciones de seguridad
class SecurityException implements Exception {
  final String message;
  SecurityException(this.message);
  
  @override
  String toString() => 'SecurityException: $message';
}

// Modelos de datos
class DeviceInfo {
  final String id;
  final String fingerprint;
  final String platform;
  final DateTime lastSeen;
  
  DeviceInfo({
    required this.id,
    required this.fingerprint,
    required this.platform,
    required this.lastSeen,
  });
}

class SessionInfo {
  final String id;
  final String userId;
  final String deviceId;
  final DateTime createdAt;
  DateTime lastActivity;
  
  SessionInfo({
    required this.id,
    required this.userId,
    required this.deviceId,
    required this.createdAt,
    required this.lastActivity,
  });
}

class SecurityEvent {
  final SecurityEventType type;
  final DateTime timestamp;
  final Map<String, dynamic> data;
  final String userId;
  
  SecurityEvent({
    required this.type,
    required this.timestamp,
    required this.data,
    required this.userId,
  });
  
  Map<String, dynamic> toJson() => {
    'type': type.toString(),
    'timestamp': timestamp.toIso8601String(),
    'data': data,
    'userId': userId,
  };
}

enum SecurityEventType {
  sqlInjectionAttempt,
  unknownDevice,
  accountLocked,
  sessionCreated,
  sessionTimeout,
  sessionExpired,
  suspiciousActivity,
  loginSuccess,
  loginFailed,
}