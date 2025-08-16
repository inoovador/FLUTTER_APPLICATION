import 'dart:convert';
import 'package:http/http.dart' as http;
import '../security/security_service.dart';

class SecurityApiService {
  // URL base para comunicación con MCP/N8N
  static const String MCP_BASE_URL = 'https://your-mcp-endpoint.com/api';
  static const String N8N_WEBHOOK_URL = 'https://your-n8n-webhook.com/security';
  
  // Headers seguros
  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'X-API-Key': 'your-secure-api-key', // Cambiar en producción
    'X-App-Version': '1.0.0',
  };

  // Enviar evento de seguridad a MCP/N8N
  Future<void> sendSecurityEvent(SecurityEvent event) async {
    try {
      final response = await http.post(
        Uri.parse('$MCP_BASE_URL/security/events'),
        headers: _headers,
        body: json.encode({
          'event': event.toJson(),
          'timestamp': DateTime.now().toIso8601String(),
          'appId': 'torneos_app',
        }),
      );
      
      if (response.statusCode != 200) {
        print('Error enviando evento de seguridad: ${response.statusCode}');
      }
    } catch (e) {
      print('Error de conexión con MCP: $e');
    }
  }

  // Reportar anomalía detectada
  Future<void> reportAnomalyToMCP(Map<String, dynamic> anomaly) async {
    try {
      final response = await http.post(
        Uri.parse('$N8N_WEBHOOK_URL/anomaly'),
        headers: _headers,
        body: json.encode({
          'anomaly': anomaly,
          'severity': _calculateSeverity(anomaly),
          'timestamp': DateTime.now().toIso8601String(),
          'requiresAction': true,
        }),
      );
      
      if (response.statusCode == 200) {
        // N8N procesará la anomalía y tomará acciones
        final responseData = json.decode(response.body);
        if (responseData['action'] == 'block') {
          // Implementar bloqueo inmediato
          await _executeSecurityAction(responseData['actionData']);
        }
      }
    } catch (e) {
      print('Error reportando anomalía: $e');
    }
  }

  // Reportar amenazas detectadas
  Future<void> reportThreatsToMCP(List<Map<String, dynamic>> threats) async {
    try {
      final response = await http.post(
        Uri.parse('$MCP_BASE_URL/security/threats'),
        headers: _headers,
        body: json.encode({
          'threats': threats,
          'timestamp': DateTime.now().toIso8601String(),
          'appId': 'torneos_app',
        }),
      );
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        // Aplicar medidas de seguridad recomendadas por MCP
        if (responseData['recommendations'] != null) {
          await _applySecurityRecommendations(
            List<Map<String, dynamic>>.from(responseData['recommendations'])
          );
        }
      }
    } catch (e) {
      print('Error reportando amenazas: $e');
    }
  }

  // Verificar dispositivo con MCP
  Future<bool> verifyDeviceWithMCP(String deviceId, String fingerprint) async {
    try {
      final response = await http.post(
        Uri.parse('$MCP_BASE_URL/device/verify'),
        headers: _headers,
        body: json.encode({
          'deviceId': deviceId,
          'fingerprint': fingerprint,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['trusted'] == true;
      }
      
      return false;
    } catch (e) {
      print('Error verificando dispositivo: $e');
      return false;
    }
  }

  // Obtener reglas de seguridad actualizadas
  Future<Map<String, dynamic>> getSecurityRules() async {
    try {
      final response = await http.get(
        Uri.parse('$MCP_BASE_URL/security/rules'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      
      return {};
    } catch (e) {
      print('Error obteniendo reglas de seguridad: $e');
      return {};
    }
  }

  // Calcular severidad de la anomalía
  String _calculateSeverity(Map<String, dynamic> anomaly) {
    final type = anomaly['type'] as String?;
    
    if (type == 'sql_injection' || type == 'multiple_sql_injection_attempts') {
      return 'critical';
    } else if (type == 'rapid_actions' || type == 'multiple_unknown_devices') {
      return 'high';
    } else if (type == 'unknown_device') {
      return 'medium';
    }
    
    return 'low';
  }

  // Ejecutar acción de seguridad
  Future<void> _executeSecurityAction(Map<String, dynamic> actionData) async {
    final action = actionData['action'] as String?;
    
    switch (action) {
      case 'block_user':
        // Implementar bloqueo de usuario
        await _blockUser(actionData['userId']);
        break;
      case 'invalidate_sessions':
        // Invalidar todas las sesiones del usuario
        await _invalidateUserSessions(actionData['userId']);
        break;
      case 'require_2fa':
        // Forzar autenticación de dos factores
        await _enforce2FA(actionData['userId']);
        break;
    }
  }

  // Aplicar recomendaciones de seguridad
  Future<void> _applySecurityRecommendations(
    List<Map<String, dynamic>> recommendations
  ) async {
    for (final recommendation in recommendations) {
      final type = recommendation['type'] as String?;
      
      switch (type) {
        case 'update_rules':
          // Actualizar reglas de validación
          await _updateValidationRules(recommendation['rules']);
          break;
        case 'increase_monitoring':
          // Aumentar nivel de monitoreo
          await _increaseMonitoringLevel(recommendation['level']);
          break;
        case 'enable_rate_limiting':
          // Activar limitación de tasa
          await _enableRateLimiting(recommendation['config']);
          break;
      }
    }
  }

  // Métodos auxiliares de implementación
  Future<void> _blockUser(String userId) async {
    // Implementar bloqueo de usuario
    print('Bloqueando usuario: $userId');
  }

  Future<void> _invalidateUserSessions(String userId) async {
    // Implementar invalidación de sesiones
    print('Invalidando sesiones del usuario: $userId');
  }

  Future<void> _enforce2FA(String userId) async {
    // Implementar 2FA obligatorio
    print('Activando 2FA para usuario: $userId');
  }

  Future<void> _updateValidationRules(Map<String, dynamic> rules) async {
    // Actualizar reglas de validación
    print('Actualizando reglas de validación: $rules');
  }

  Future<void> _increaseMonitoringLevel(int level) async {
    // Aumentar nivel de monitoreo
    print('Aumentando nivel de monitoreo a: $level');
  }

  Future<void> _enableRateLimiting(Map<String, dynamic> config) async {
    // Activar limitación de tasa
    print('Activando rate limiting: $config');
  }
}