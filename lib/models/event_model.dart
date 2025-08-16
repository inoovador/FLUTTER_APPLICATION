class EventModel {
  final String id;
  final String name;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime registrationDeadline;
  final double price;
  final int maxParticipants;
  final int currentParticipants;
  final String location;
  final String imageUrl;
  final String status;
  final List<String> categories;

  EventModel({
    required this.id,
    required this.name,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.registrationDeadline,
    required this.price,
    required this.maxParticipants,
    required this.currentParticipants,
    required this.location,
    required this.imageUrl,
    required this.status,
    required this.categories,
  });

  bool get isFull => currentParticipants >= maxParticipants;
  
  bool get isRegistrationOpen => 
      DateTime.now().isBefore(registrationDeadline) && !isFull;

  double get occupancyRate => currentParticipants / maxParticipants;

  int get spotsAvailable => maxParticipants - currentParticipants;

  bool get isUpcoming => status == 'upcoming';
  bool get isOngoing => status == 'ongoing';
  bool get isFinished => status == 'finished';
}