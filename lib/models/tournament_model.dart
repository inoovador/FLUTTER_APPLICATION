class TournamentModel {
  final String id;
  final String organizerId;
  final String organizerName;
  final String organizerYape;
  final String name;
  final String description;
  final String sport;
  final String category;
  final DateTime date;
  final String location;
  final double pricePerPlayer;
  final int maxTeams;
  final int registeredTeams;
  final String status; // 'draft', 'published', 'in_progress', 'finished'
  final DateTime createdAt;
  final List<String> paymentMethods;

  TournamentModel({
    required this.id,
    required this.organizerId,
    required this.organizerName,
    required this.organizerYape,
    required this.name,
    required this.description,
    required this.sport,
    required this.category,
    required this.date,
    required this.location,
    required this.pricePerPlayer,
    required this.maxTeams,
    this.registeredTeams = 0,
    this.status = 'published',
    required this.createdAt,
    this.paymentMethods = const ['yape', 'visa', 'mastercard', 'transfer'],
  });

  // Para mostrar el deporte en español
  String get sportDisplay {
    switch (sport) {
      case 'futbol':
        return 'Fútbol';
      case 'futsal':
        return 'Futsal';
      case 'voley':
        return 'Vóley';
      case 'basket':
        return 'Básquet';
      default:
        return sport;
    }
  }

  // Para mostrar la categoría en español
  String get categoryDisplay {
    switch (category) {
      case 'libre':
        return 'Libre';
      case 'sub15':
        return 'Sub-15';
      case 'sub17':
        return 'Sub-17';
      case 'senior':
        return 'Senior (35+)';
      case 'femenino':
        return 'Femenino';
      default:
        return category;
    }
  }

  // Verificar si hay cupos disponibles
  bool get hasAvailableSpots => registeredTeams < maxTeams;

  // Calcular progreso de inscripciones
  double get registrationProgress => registeredTeams / maxTeams;

  // Verificar si el torneo ya pasó
  bool get isExpired => date.isBefore(DateTime.now());

  // Crear desde JSON (para cuando tengas backend)
  factory TournamentModel.fromJson(Map<String, dynamic> json) {
    return TournamentModel(
      id: json['id'],
      organizerId: json['organizerId'],
      organizerName: json['organizerName'],
      organizerYape: json['organizerYape'],
      name: json['name'],
      description: json['description'],
      sport: json['sport'],
      category: json['category'],
      date: DateTime.parse(json['date']),
      location: json['location'],
      pricePerPlayer: json['pricePerPlayer'].toDouble(),
      maxTeams: json['maxTeams'],
      registeredTeams: json['registeredTeams'] ?? 0,
      status: json['status'] ?? 'published',
      createdAt: DateTime.parse(json['createdAt']),
      paymentMethods: List<String>.from(json['paymentMethods'] ?? []),
    );
  }

  // Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organizerId': organizerId,
      'organizerName': organizerName,
      'organizerYape': organizerYape,
      'name': name,
      'description': description,
      'sport': sport,
      'category': category,
      'date': date.toIso8601String(),
      'location': location,
      'pricePerPlayer': pricePerPlayer,
      'maxTeams': maxTeams,
      'registeredTeams': registeredTeams,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'paymentMethods': paymentMethods,
    };
  }
}