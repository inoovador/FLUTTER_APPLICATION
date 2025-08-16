import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';

class EncryptionService {
  static final EncryptionService _instance = EncryptionService._internal();
  factory EncryptionService() => _instance;
  EncryptionService._internal();

  // Claves de encriptación (en producción usar key management seguro)
  late final Key _key;
  late final IV _iv;
  late final Encrypter _encrypter;

  // Inicializar servicio de encriptación
  void initialize() {
    // En producción, estas claves deben venir de un servicio seguro
    final keyString = 'my32lengthsupersecretnooneknows'; // 32 chars
    _key = Key.fromUtf8(keyString);
    _iv = IV.fromLength(16);
    _encrypter = Encrypter(AES(_key));
  }

  // Encriptar datos sensibles
  String encryptData(String plainText) {
    if (plainText.isEmpty) return plainText;
    
    try {
      final encrypted = _encrypter.encrypt(plainText, iv: _iv);
      return encrypted.base64;
    } catch (e) {
      print('Error encriptando datos: $e');
      throw EncryptionException('Failed to encrypt data');
    }
  }

  // Desencriptar datos
  String decryptData(String encryptedText) {
    if (encryptedText.isEmpty) return encryptedText;
    
    try {
      final encrypted = Encrypted.fromBase64(encryptedText);
      final decrypted = _encrypter.decrypt(encrypted, iv: _iv);
      return decrypted;
    } catch (e) {
      print('Error desencriptando datos: $e');
      throw EncryptionException('Failed to decrypt data');
    }
  }

  // Encriptar objeto JSON
  String encryptJson(Map<String, dynamic> data) {
    final jsonString = json.encode(data);
    return encryptData(jsonString);
  }

  // Desencriptar objeto JSON
  Map<String, dynamic> decryptJson(String encryptedData) {
    final jsonString = decryptData(encryptedData);
    return json.decode(jsonString);
  }

  // Hash de datos para verificación de integridad
  String generateHash(String data) {
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Verificar integridad de datos
  bool verifyDataIntegrity(String data, String expectedHash) {
    final actualHash = generateHash(data);
    return actualHash == expectedHash;
  }

  // Generar firma digital
  String generateDigitalSignature(String data, String privateKey) {
    final message = data + privateKey;
    final hmac = Hmac(sha256, utf8.encode(privateKey));
    final digest = hmac.convert(utf8.encode(message));
    return digest.toString();
  }

  // Verificar firma digital
  bool verifyDigitalSignature(String data, String signature, String privateKey) {
    final expectedSignature = generateDigitalSignature(data, privateKey);
    return expectedSignature == signature;
  }

  // Encriptar datos de pago (PCI compliance)
  Map<String, String> encryptPaymentData({
    required String cardNumber,
    required String cvv,
    required String expiryDate,
  }) {
    return {
      'encryptedCardNumber': encryptData(cardNumber),
      'encryptedCVV': encryptData(cvv),
      'encryptedExpiryDate': encryptData(expiryDate),
      'timestamp': DateTime.now().toIso8601String(),
      'hash': generateHash(cardNumber + cvv + expiryDate),
    };
  }

  // Ofuscar datos sensibles para logs
  String obfuscateSensitiveData(String data, {int visibleChars = 4}) {
    if (data.length <= visibleChars) {
      return '*' * data.length;
    }
    
    final visible = data.substring(data.length - visibleChars);
    final hidden = '*' * (data.length - visibleChars);
    return hidden + visible;
  }

  // Encriptar archivo
  Future<Uint8List> encryptFile(Uint8List fileBytes) async {
    try {
      final base64String = base64.encode(fileBytes);
      final encrypted = encryptData(base64String);
      return utf8.encode(encrypted);
    } catch (e) {
      print('Error encriptando archivo: $e');
      throw EncryptionException('Failed to encrypt file');
    }
  }

  // Desencriptar archivo
  Future<Uint8List> decryptFile(Uint8List encryptedBytes) async {
    try {
      final encryptedString = utf8.decode(encryptedBytes);
      final decrypted = decryptData(encryptedString);
      return base64.decode(decrypted);
    } catch (e) {
      print('Error desencriptando archivo: $e');
      throw EncryptionException('Failed to decrypt file');
    }
  }

  // Generar token seguro
  String generateSecureToken({int length = 32}) {
    final random = List<int>.generate(length, (i) => 
      DateTime.now().millisecondsSinceEpoch + i
    );
    final bytes = utf8.encode(random.join());
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Encriptar datos de usuario para almacenamiento
  Map<String, dynamic> encryptUserData(Map<String, dynamic> userData) {
    final sensitiveFields = ['email', 'phone', 'address', 'dni'];
    final encryptedData = Map<String, dynamic>.from(userData);
    
    for (final field in sensitiveFields) {
      if (encryptedData.containsKey(field) && encryptedData[field] != null) {
        encryptedData[field] = encryptData(encryptedData[field].toString());
      }
    }
    
    // Agregar metadata de encriptación
    encryptedData['_encrypted'] = true;
    encryptedData['_encryptionVersion'] = '1.0';
    encryptedData['_encryptedAt'] = DateTime.now().toIso8601String();
    
    return encryptedData;
  }

  // Desencriptar datos de usuario
  Map<String, dynamic> decryptUserData(Map<String, dynamic> encryptedData) {
    if (!encryptedData.containsKey('_encrypted') || 
        encryptedData['_encrypted'] != true) {
      return encryptedData; // No está encriptado
    }
    
    final decryptedData = Map<String, dynamic>.from(encryptedData);
    final sensitiveFields = ['email', 'phone', 'address', 'dni'];
    
    for (final field in sensitiveFields) {
      if (decryptedData.containsKey(field) && decryptedData[field] != null) {
        try {
          decryptedData[field] = decryptData(decryptedData[field].toString());
        } catch (e) {
          print('Error desencriptando campo $field: $e');
        }
      }
    }
    
    // Remover metadata
    decryptedData.remove('_encrypted');
    decryptedData.remove('_encryptionVersion');
    decryptedData.remove('_encryptedAt');
    
    return decryptedData;
  }
}

class EncryptionException implements Exception {
  final String message;
  EncryptionException(this.message);
  
  @override
  String toString() => 'EncryptionException: $message';
}