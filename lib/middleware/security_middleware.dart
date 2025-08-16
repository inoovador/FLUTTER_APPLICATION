import 'package:flutter/material.dart';
import '../services/security/security_service.dart';
import '../services/security/encryption_service.dart';

class SecurityMiddleware {
  final SecurityService _securityService = SecurityService();
  final EncryptionService _encryptionService = EncryptionService();
  
  // Middleware para validar todas las entradas de usuario
  Future<T> validateAndProcess<T>({
    required Map<String, dynamic> input,
    required Future<T> Function(Map<String, dynamic>) processor,
    required String userId,
    required String action,
  }) async {
    try {
      // 1. Validar y sanitizar todas las entradas
      final sanitizedInput = <String, dynamic>{};
      for (final entry in input.entries) {
        if (entry.value is String) {
          sanitizedInput[entry.key] = _securityService.sanitizeInput(entry.value);
        } else {
          sanitizedInput[entry.key] = entry.value;
        }
      }
      
      // 2. Verificar sesión activa
      final sessionId = sanitizedInput['sessionId'] as String?;
      if (sessionId != null && !_securityService.isSessionValid(sessionId)) {
        throw SecurityException('Sesión inválida o expirada');
      }
      
      // 3. Verificar comportamiento anómalo
      await _securityService.checkForAnomalies(userId, action);
      
      // 4. Encriptar datos sensibles antes de procesamiento
      final encryptedInput = _prepareSensitiveData(sanitizedInput);
      
      // 5. Procesar la solicitud
      final result = await processor(encryptedInput);
      
      // 6. Registrar actividad exitosa
      _logSuccessfulAction(userId, action);
      
      return result;
      
    } catch (e) {
      // Registrar intento fallido o sospechoso
      _logFailedAction(userId, action, e.toString());
      rethrow;
    }
  }
  
  // Preparar datos sensibles para procesamiento
  Map<String, dynamic> _prepareSensitiveData(Map<String, dynamic> input) {
    final sensitiveFields = ['password', 'cardNumber', 'cvv', 'dni'];
    final prepared = Map<String, dynamic>.from(input);
    
    for (final field in sensitiveFields) {
      if (prepared.containsKey(field) && prepared[field] != null) {
        // No almacenar contraseñas en texto plano
        if (field == 'password') {
          final salt = _encryptionService.generateSecureToken(length: 16);
          prepared['passwordHash'] = _securityService.hashPassword(
            prepared[field],
            salt,
          );
          prepared['salt'] = salt;
          prepared.remove('password');
        } else {
          // Encriptar otros datos sensibles
          prepared[field] = _encryptionService.encryptData(prepared[field]);
        }
      }
    }
    
    return prepared;
  }
  
  // Widget wrapper para formularios seguros
  Widget buildSecureForm({
    required Widget child,
    required GlobalKey<FormState> formKey,
    required Function() onSubmit,
  }) {
    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        children: [
          child,
          // Agregar captcha o verificación adicional si es necesario
          _buildSecurityVerification(),
        ],
      ),
    );
  }
  
  // Validador de campos de texto seguro
  String? secureTextValidator(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Este campo es requerido';
    }
    
    try {
      // Validar contra inyecciones
      _securityService.sanitizeInput(value);
      
      // Validaciones específicas por campo
      switch (fieldName) {
        case 'email':
          if (!_securityService.isValidEmail(value)) {
            return 'Email inválido';
          }
          break;
        case 'password':
          if (value.length < SecurityService.MIN_PASSWORD_LENGTH) {
            return 'La contraseña debe tener al menos ${SecurityService.MIN_PASSWORD_LENGTH} caracteres';
          }
          if (!_isStrongPassword(value)) {
            return 'La contraseña debe contener mayúsculas, minúsculas y números';
          }
          break;
        case 'phone':
          if (!_isValidPhone(value)) {
            return 'Número de teléfono inválido';
          }
          break;
      }
      
      return null;
    } catch (e) {
      return 'Entrada inválida';
    }
  }
  
  // Interceptor para peticiones HTTP
  Future<Map<String, String>> getSecureHeaders(String sessionId) async {
    final timestamp = DateTime.now().toIso8601String();
    final nonce = _encryptionService.generateSecureToken(length: 16);
    
    // Generar firma para la petición
    final signature = _encryptionService.generateDigitalSignature(
      '$sessionId$timestamp$nonce',
      'app-private-key', // En producción usar key management
    );
    
    return {
      'X-Session-ID': sessionId,
      'X-Timestamp': timestamp,
      'X-Nonce': nonce,
      'X-Signature': signature,
      'X-App-Version': '1.0.0',
    };
  }
  
  // Verificar respuesta del servidor
  bool verifyServerResponse(Map<String, dynamic> response) {
    // Verificar firma del servidor
    final serverSignature = response['signature'] as String?;
    final data = response['data'] as Map<String, dynamic>?;
    
    if (serverSignature == null || data == null) {
      return false;
    }
    
    // Verificar integridad de los datos
    final dataString = data.toString();
    return _encryptionService.verifyDigitalSignature(
      dataString,
      serverSignature,
      'server-public-key', // En producción usar certificado real
    );
  }
  
  // Widget de verificación de seguridad (puede ser captcha, biométrico, etc)
  Widget _buildSecurityVerification() {
    // Implementar según necesidades
    return Container();
  }
  
  // Validar contraseña fuerte
  bool _isStrongPassword(String password) {
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasNumbers = password.contains(RegExp(r'[0-9]'));
    final hasSpecialChars = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    
    return hasUppercase && hasLowercase && hasNumbers && password.length >= 8;
  }
  
  // Validar número de teléfono
  bool _isValidPhone(String phone) {
    // Validación para números peruanos
    final phoneRegex = RegExp(r'^9\d{8}$');
    return phoneRegex.hasMatch(phone.replaceAll(RegExp(r'[^\d]'), ''));
  }
  
  // Registrar acción exitosa
  void _logSuccessfulAction(String userId, String action) {
    debugPrint('ACTION SUCCESS: User $userId performed $action');
  }
  
  // Registrar acción fallida
  void _logFailedAction(String userId, String action, String error) {
    debugPrint('ACTION FAILED: User $userId failed $action - $error');
  }
}