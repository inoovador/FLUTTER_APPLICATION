class InscriptionModel {
  final String id;
  final String userId;
  final String eventId;
  final String eventName;
  final DateTime inscriptionDate;
  final String status; // pending, confirmed, cancelled
  final String paymentStatus; // pending, paid, refunded
  final double amount;
  final DateTime? paymentDate;
  final String? paymentMethod;
  final String? transactionId;
  final String? teamId;
  final Map<String, dynamic>? additionalInfo;

  InscriptionModel({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.eventName,
    required this.inscriptionDate,
    required this.status,
    required this.paymentStatus,
    required this.amount,
    this.paymentDate,
    this.paymentMethod,
    this.transactionId,
    this.teamId,
    this.additionalInfo,
  });

  factory InscriptionModel.fromJson(Map<String, dynamic> json) {
    return InscriptionModel(
      id: json['id'],
      userId: json['userId'],
      eventId: json['eventId'],
      eventName: json['eventName'],
      inscriptionDate: DateTime.parse(json['inscriptionDate']),
      status: json['status'],
      paymentStatus: json['paymentStatus'],
      amount: json['amount'].toDouble(),
      paymentDate: json['paymentDate'] != null 
          ? DateTime.parse(json['paymentDate']) 
          : null,
      paymentMethod: json['paymentMethod'],
      transactionId: json['transactionId'],
      teamId: json['teamId'],
      additionalInfo: json['additionalInfo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'eventId': eventId,
      'eventName': eventName,
      'inscriptionDate': inscriptionDate.toIso8601String(),
      'status': status,
      'paymentStatus': paymentStatus,
      'amount': amount,
      'paymentDate': paymentDate?.toIso8601String(),
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
      'teamId': teamId,
      'additionalInfo': additionalInfo,
    };
  }

  bool get isPaid => paymentStatus == 'paid';
  bool get isPending => paymentStatus == 'pending';
  bool get isConfirmed => status == 'confirmed';
}