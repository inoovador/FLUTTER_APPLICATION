import 'package:flutter/material.dart';
import 'dart:math';

// Modelo de pago
class Payment {
  final String id;
  final String userId;
  final String tournamentId;
  final double amount;
  final String method; // yape, visa, mastercard, plin
  final String status; // pending, completed, failed
  final DateTime createdAt;
  final String? transactionId;
  final Map<String, dynamic>? metadata;

  Payment({
    required this.id,
    required this.userId,
    required this.tournamentId,
    required this.amount,
    required this.method,
    required this.status,
    required this.createdAt,
    this.transactionId,
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'tournamentId': tournamentId,
    'amount': amount,
    'method': method,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
    'transactionId': transactionId,
    'metadata': metadata,
  };
}

// Modelo de método de pago
class PaymentMethod {
  final String id;
  final String type; // yape, card, bank
  final String name;
  final String? lastFourDigits;
  final String? phoneNumber;
  final String? cardBrand; // visa, mastercard
  final bool isDefault;

  PaymentMethod({
    required this.id,
    required this.type,
    required this.name,
    this.lastFourDigits,
    this.phoneNumber,
    this.cardBrand,
    this.isDefault = false,
  });
}

class PaymentService extends ChangeNotifier {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  final List<Payment> _payments = [];
  final List<PaymentMethod> _savedMethods = [];
  bool _isProcessing = false;

  List<Payment> get payments => List.unmodifiable(_payments);
  List<PaymentMethod> get savedMethods => List.unmodifiable(_savedMethods);
  bool get isProcessing => _isProcessing;

  // Configuración de Yape
  static const String YAPE_NUMBER = '987654321'; // Número del organizador
  static const String YAPE_NAME = 'TORNEOS APP SAC';
  
  // Inicializar métodos de pago guardados (simulado)
  Future<void> initializeSavedMethods() async {
    _savedMethods.clear();
    _savedMethods.addAll([
      PaymentMethod(
        id: '1',
        type: 'yape',
        name: 'Mi Yape',
        phoneNumber: '912345678',
        isDefault: true,
      ),
      PaymentMethod(
        id: '2',
        type: 'card',
        name: 'Visa Personal',
        lastFourDigits: '4242',
        cardBrand: 'visa',
      ),
    ]);
    notifyListeners();
  }

  // Procesar pago con Yape
  Future<Payment?> processYapePayment({
    required String tournamentId,
    required double amount,
    required String phoneNumber,
    String? voucherImage,
  }) async {
    _isProcessing = true;
    notifyListeners();

    try {
      // Simulación de procesamiento
      await Future.delayed(const Duration(seconds: 2));
      
      // Generar código de transacción
      final transactionCode = _generateTransactionCode();
      
      final payment = Payment(
        id: 'pay_${DateTime.now().millisecondsSinceEpoch}',
        userId: 'current_user', // En producción obtener del auth
        tournamentId: tournamentId,
        amount: amount,
        method: 'yape',
        status: 'pending', // Pendiente hasta que el organizador confirme
        createdAt: DateTime.now(),
        transactionId: transactionCode,
        metadata: {
          'phoneNumber': phoneNumber,
          'voucherImage': voucherImage,
          'yapeName': YAPE_NAME,
          'yapeNumber': YAPE_NUMBER,
        },
      );
      
      _payments.add(payment);
      notifyListeners();
      
      // Simular confirmación automática después de 3 segundos
      Future.delayed(const Duration(seconds: 3), () {
        _confirmPayment(payment.id);
      });
      
      return payment;
    } catch (e) {
      debugPrint('Error procesando pago Yape: $e');
      return null;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  // Procesar pago con tarjeta
  Future<Payment?> processCardPayment({
    required String tournamentId,
    required double amount,
    required String cardNumber,
    required String cardHolder,
    required String expiryDate,
    required String cvv,
    bool saveCard = false,
  }) async {
    _isProcessing = true;
    notifyListeners();

    try {
      // Validar tarjeta
      if (!_validateCard(cardNumber, expiryDate, cvv)) {
        throw Exception('Tarjeta inválida');
      }
      
      // Simulación de procesamiento con pasarela de pago
      await Future.delayed(const Duration(seconds: 3));
      
      final payment = Payment(
        id: 'pay_${DateTime.now().millisecondsSinceEpoch}',
        userId: 'current_user',
        tournamentId: tournamentId,
        amount: amount,
        method: _getCardBrand(cardNumber),
        status: 'completed', // Con tarjeta es instantáneo
        createdAt: DateTime.now(),
        transactionId: _generateTransactionCode(),
        metadata: {
          'lastFourDigits': cardNumber.substring(cardNumber.length - 4),
          'cardHolder': cardHolder,
          'cardBrand': _getCardBrand(cardNumber),
        },
      );
      
      _payments.add(payment);
      
      // Guardar tarjeta si el usuario lo solicita
      if (saveCard) {
        _savePaymentMethod(
          type: 'card',
          name: '${_getCardBrand(cardNumber)} ***${cardNumber.substring(cardNumber.length - 4)}',
          lastFourDigits: cardNumber.substring(cardNumber.length - 4),
          cardBrand: _getCardBrand(cardNumber),
        );
      }
      
      notifyListeners();
      return payment;
    } catch (e) {
      debugPrint('Error procesando pago con tarjeta: $e');
      return null;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  // Procesar pago con Plin
  Future<Payment?> processPlinPayment({
    required String tournamentId,
    required double amount,
    required String phoneNumber,
  }) async {
    _isProcessing = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 2));
      
      final payment = Payment(
        id: 'pay_${DateTime.now().millisecondsSinceEpoch}',
        userId: 'current_user',
        tournamentId: tournamentId,
        amount: amount,
        method: 'plin',
        status: 'pending',
        createdAt: DateTime.now(),
        transactionId: _generateTransactionCode(),
        metadata: {
          'phoneNumber': phoneNumber,
        },
      );
      
      _payments.add(payment);
      notifyListeners();
      
      return payment;
    } catch (e) {
      debugPrint('Error procesando pago Plin: $e');
      return null;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  // Confirmar pago (para métodos que requieren confirmación manual)
  void _confirmPayment(String paymentId) {
    final index = _payments.indexWhere((p) => p.id == paymentId);
    if (index != -1) {
      final payment = _payments[index];
      _payments[index] = Payment(
        id: payment.id,
        userId: payment.userId,
        tournamentId: payment.tournamentId,
        amount: payment.amount,
        method: payment.method,
        status: 'completed',
        createdAt: payment.createdAt,
        transactionId: payment.transactionId,
        metadata: payment.metadata,
      );
      notifyListeners();
    }
  }

  // Obtener pagos del usuario
  Future<List<Payment>> getUserPayments(String userId) async {
    return _payments.where((p) => p.userId == userId).toList();
  }

  // Obtener pago por ID
  Payment? getPaymentById(String paymentId) {
    try {
      return _payments.firstWhere((p) => p.id == paymentId);
    } catch (e) {
      return null;
    }
  }

  // Validar tarjeta (básico)
  bool _validateCard(String cardNumber, String expiryDate, String cvv) {
    // Remover espacios
    cardNumber = cardNumber.replaceAll(' ', '');
    
    // Validar longitud
    if (cardNumber.length < 13 || cardNumber.length > 19) return false;
    if (cvv.length != 3 && cvv.length != 4) return false;
    
    // Validar que sean números
    if (!RegExp(r'^\d+$').hasMatch(cardNumber)) return false;
    if (!RegExp(r'^\d+$').hasMatch(cvv)) return false;
    
    // Validar fecha (MM/YY)
    if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(expiryDate)) return false;
    
    // Algoritmo de Luhn para validar número de tarjeta
    int sum = 0;
    bool alternate = false;
    for (int i = cardNumber.length - 1; i >= 0; i--) {
      int digit = int.parse(cardNumber[i]);
      if (alternate) {
        digit *= 2;
        if (digit > 9) digit -= 9;
      }
      sum += digit;
      alternate = !alternate;
    }
    
    return sum % 10 == 0;
  }

  // Obtener marca de tarjeta
  String _getCardBrand(String cardNumber) {
    cardNumber = cardNumber.replaceAll(' ', '');
    
    if (cardNumber.startsWith('4')) return 'visa';
    if (cardNumber.startsWith('5')) return 'mastercard';
    if (cardNumber.startsWith('3')) return 'amex';
    if (cardNumber.startsWith('6')) return 'discover';
    
    return 'unknown';
  }

  // Generar código de transacción
  String _generateTransactionCode() {
    final random = Random();
    return 'TXN${DateTime.now().millisecondsSinceEpoch}${random.nextInt(9999).toString().padLeft(4, '0')}';
  }

  // Guardar método de pago
  void _savePaymentMethod({
    required String type,
    required String name,
    String? lastFourDigits,
    String? phoneNumber,
    String? cardBrand,
  }) {
    final method = PaymentMethod(
      id: 'method_${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      name: name,
      lastFourDigits: lastFourDigits,
      phoneNumber: phoneNumber,
      cardBrand: cardBrand,
    );
    
    _savedMethods.add(method);
    notifyListeners();
  }

  // Eliminar método de pago
  void removePaymentMethod(String methodId) {
    _savedMethods.removeWhere((m) => m.id == methodId);
    notifyListeners();
  }

  // Calcular comisiones
  double calculateFees(double amount, String method) {
    switch (method) {
      case 'yape':
      case 'plin':
        return 0; // Sin comisión para transferencias
      case 'visa':
      case 'mastercard':
        return amount * 0.039; // 3.9% de comisión
      default:
        return 0;
    }
  }

  // Obtener total con comisiones
  double getTotalWithFees(double amount, String method) {
    return amount + calculateFees(amount, method);
  }
}