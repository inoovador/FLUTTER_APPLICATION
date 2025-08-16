class OrganizerModel {
  final String id;
  final String businessName;
  final String ruc;
  final String ownerName;
  final String ownerDni;
  final String email;
  final String phone;
  
  // Métodos de pago del organizador
  final PaymentMethods paymentMethods;
  
  // Verificación
  final bool isVerified;
  final DateTime? verificationDate;
  final String status; // 'pending', 'verified', 'suspended'
  
  // Estadísticas
  final int totalTournaments;
  final double rating;
  
  OrganizerModel({
    required this.id,
    required this.businessName,
    required this.ruc,
    required this.ownerName,
    required this.ownerDni,
    required this.email,
    required this.phone,
    required this.paymentMethods,
    this.isVerified = false,
    this.verificationDate,
    this.status = 'pending',
    this.totalTournaments = 0,
    this.rating = 0.0,
  });
}

class PaymentMethods {
  // Yape
  final String? yapeNumber;
  final String? yapeName;
  
  // Plin
  final String? plinNumber;
  
  // Transferencia bancaria
  final BankAccount? bankAccount;
  
  // Billeteras digitales
  final String? mercadoPagoAlias;
  
  PaymentMethods({
    this.yapeNumber,
    this.yapeName,
    this.plinNumber,
    this.bankAccount,
    this.mercadoPagoAlias,
  });
  
  // Verificar si tiene al menos un método configurado
  bool get hasPaymentMethod {
    return yapeNumber != null || 
           plinNumber != null || 
           bankAccount != null || 
           mercadoPagoAlias != null;
  }
}

class BankAccount {
  final String bankName;
  final String accountNumber;
  final String cci;
  final String accountType; // 'corriente', 'ahorros'
  
  BankAccount({
    required this.bankName,
    required this.accountNumber,
    required this.cci,
    required this.accountType,
  });
}