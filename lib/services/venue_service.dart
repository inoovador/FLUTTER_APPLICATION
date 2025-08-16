import '../models/venue_model.dart';

class VenueService {
  // Datos de ejemplo de canchas
  static final List<Venue> _venues = [
    Venue(
      id: 'venue1',
      name: 'Complejo Deportivo San Marcos',
      address: 'Av. Venezuela 3412, Lima',
      sport: 'Fútbol',
      pricePerHour: 80.0,
      rating: 4.5,
      reviewCount: 124,
      isAvailable: true,
      distance: 2.3,
      amenities: ['Estacionamiento', 'Vestuarios', 'Ducha', 'Iluminación LED'],
      availableSlots: [
        TimeSlot(
          id: 'slot1',
          startTime: '08:00',
          endTime: '10:00',
          price: 160.0,
          isBooked: false,
        ),
        TimeSlot(
          id: 'slot2',
          startTime: '10:00',
          endTime: '12:00',
          price: 160.0,
          isBooked: false,
        ),
        TimeSlot(
          id: 'slot3',
          startTime: '14:00',
          endTime: '16:00',
          price: 160.0,
          isBooked: false,
        ),
        TimeSlot(
          id: 'slot4',
          startTime: '18:00',
          endTime: '20:00',
          price: 200.0,
          isBooked: false,
        ),
      ],
      ownerId: 'owner1',
      ownerName: 'Carlos Mendoza',
      phone: '987654321',
      email: 'carlos@sanmarcos.com',
      location: {'lat': -12.0464, 'lng': -77.0428},
    ),
    Venue(
      id: 'venue2',
      name: 'Cancha Municipal Los Olivos',
      address: 'Jr. Los Alisos 456, Los Olivos',
      sport: 'Fútsal',
      pricePerHour: 60.0,
      rating: 4.2,
      reviewCount: 89,
      isAvailable: true,
      distance: 4.1,
      amenities: ['Estacionamiento', 'Vestuarios', 'Cafetería'],
      availableSlots: [
        TimeSlot(
          id: 'slot5',
          startTime: '09:00',
          endTime: '11:00',
          price: 120.0,
          isBooked: false,
        ),
        TimeSlot(
          id: 'slot6',
          startTime: '15:00',
          endTime: '17:00',
          price: 120.0,
          isBooked: false,
        ),
        TimeSlot(
          id: 'slot7',
          startTime: '19:00',
          endTime: '21:00',
          price: 140.0,
          isBooked: false,
        ),
      ],
      ownerId: 'owner2',
      ownerName: 'Ana Torres',
      phone: '923456789',
      email: 'ana@losolivos.gob.pe',
      location: {'lat': -11.9609, 'lng': -77.0637},
    ),
    Venue(
      id: 'venue3',
      name: 'Club Deportivo Miraflores',
      address: 'Av. Larco 1234, Miraflores',
      sport: 'Tenis',
      pricePerHour: 120.0,
      rating: 4.8,
      reviewCount: 201,
      isAvailable: true,
      distance: 8.7,
      amenities: ['Vestuarios', 'Ducha', 'Pro Shop', 'Instructor', 'Sauna'],
      availableSlots: [
        TimeSlot(
          id: 'slot8',
          startTime: '07:00',
          endTime: '08:00',
          price: 120.0,
          isBooked: false,
        ),
        TimeSlot(
          id: 'slot9',
          startTime: '08:00',
          endTime: '09:00',
          price: 120.0,
          isBooked: false,
        ),
        TimeSlot(
          id: 'slot10',
          startTime: '17:00',
          endTime: '18:00',
          price: 150.0,
          isBooked: false,
        ),
        TimeSlot(
          id: 'slot11',
          startTime: '18:00',
          endTime: '19:00',
          price: 150.0,
          isBooked: false,
        ),
      ],
      ownerId: 'owner3',
      ownerName: 'Roberto Silva',
      phone: '912345678',
      email: 'roberto@clubmiraflores.com',
      location: {'lat': -12.1196, 'lng': -77.0365},
    ),
    Venue(
      id: 'venue4',
      name: 'Polideportivo La Victoria',
      address: 'Av. México 789, La Victoria',
      sport: 'Básquet',
      pricePerHour: 70.0,
      rating: 4.0,
      reviewCount: 56,
      isAvailable: true,
      distance: 5.2,
      amenities: ['Estacionamiento', 'Vestuarios', 'Tablero electrónico'],
      availableSlots: [
        TimeSlot(
          id: 'slot12',
          startTime: '16:00',
          endTime: '18:00',
          price: 140.0,
          isBooked: false,
        ),
        TimeSlot(
          id: 'slot13',
          startTime: '20:00',
          endTime: '22:00',
          price: 160.0,
          isBooked: false,
        ),
      ],
      ownerId: 'owner4',
      ownerName: 'Luis Herrera',
      phone: '945678912',
      email: 'luis@lavictoria.gob.pe',
      location: {'lat': -12.0678, 'lng': -77.0221},
    ),
  ];

  Future<List<Venue>> getAvailableVenues({
    DateTime? date,
    String? sport,
    String? location,
  }) async {
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 800));
    
    var filteredVenues = List<Venue>.from(_venues);
    
    // Filtrar por deporte
    if (sport != null && sport.isNotEmpty) {
      filteredVenues = filteredVenues
          .where((venue) => venue.sport.toLowerCase().contains(sport.toLowerCase()))
          .toList();
    }
    
    // Filtrar por ubicación
    if (location != null && location.isNotEmpty) {
      filteredVenues = filteredVenues
          .where((venue) => venue.address.toLowerCase().contains(location.toLowerCase()))
          .toList();
    }
    
    // Ordenar por distancia
    filteredVenues.sort((a, b) => a.distance.compareTo(b.distance));
    
    return filteredVenues;
  }

  Future<Venue?> getVenueById(String venueId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    try {
      return _venues.firstWhere((venue) => venue.id == venueId);
    } catch (e) {
      return null;
    }
  }

  Future<List<Venue>> searchVenues(String query) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final lowerQuery = query.toLowerCase();
    return _venues.where((venue) {
      return venue.name.toLowerCase().contains(lowerQuery) ||
             venue.address.toLowerCase().contains(lowerQuery) ||
             venue.sport.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  Future<VenueBooking> bookVenue({
    required String venueId,
    required String userId,
    required String userName,
    required DateTime date,
    required TimeSlot timeSlot,
    String? notes,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    
    final venue = await getVenueById(venueId);
    if (venue == null) {
      throw Exception('Cancha no encontrada');
    }
    
    // Verificar disponibilidad
    final slot = venue.availableSlots.firstWhere(
      (s) => s.id == timeSlot.id,
      orElse: () => throw Exception('Horario no disponible'),
    );
    
    if (slot.isBooked) {
      throw Exception('Este horario ya está reservado');
    }
    
    // Crear reserva
    final booking = VenueBooking(
      id: 'booking_${DateTime.now().millisecondsSinceEpoch}',
      venueId: venueId,
      venueName: venue.name,
      userId: userId,
      userName: userName,
      date: date,
      timeSlot: timeSlot,
      totalPrice: timeSlot.price,
      status: BookingStatus.pending,
      createdAt: DateTime.now(),
      notes: notes,
    );
    
    // Marcar slot como reservado (simulación)
    // En una app real, esto se haría en el backend
    
    return booking;
  }

  Future<List<VenueBooking>> getUserBookings(String userId) async {
    await Future.delayed(const Duration(milliseconds: 600));
    
    // Datos de ejemplo
    return [
      VenueBooking(
        id: 'booking1',
        venueId: 'venue1',
        venueName: 'Complejo Deportivo San Marcos',
        userId: userId,
        userName: 'Usuario Demo',
        date: DateTime.now().add(const Duration(days: 2)),
        timeSlot: TimeSlot(
          id: 'slot1',
          startTime: '18:00',
          endTime: '20:00',
          price: 200.0,
          isBooked: true,
          bookedBy: userId,
        ),
        totalPrice: 200.0,
        status: BookingStatus.confirmed,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ];
  }

  Future<bool> cancelBooking(String bookingId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Lógica de cancelación
    // En una app real, verificar políticas de cancelación
    return true;
  }

  Future<List<VenueReview>> getVenueReviews(String venueId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    // Datos de ejemplo
    return [
      VenueReview(
        id: 'review1',
        venueId: venueId,
        userId: 'user1',
        userName: 'Juan Pérez',
        rating: 5.0,
        comment: 'Excelentes instalaciones, muy limpio y bien mantenido.',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        photos: [],
      ),
      VenueReview(
        id: 'review2',
        venueId: venueId,
        userId: 'user2',
        userName: 'María García',
        rating: 4.0,
        comment: 'Buena cancha, el único problema es el estacionamiento.',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        photos: [],
      ),
    ];
  }

  Future<VenueReview> addReview({
    required String venueId,
    required String userId,
    required String userName,
    required double rating,
    required String comment,
    List<String> photos = const [],
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));
    
    final review = VenueReview(
      id: 'review_${DateTime.now().millisecondsSinceEpoch}',
      venueId: venueId,
      userId: userId,
      userName: userName,
      rating: rating,
      comment: comment,
      createdAt: DateTime.now(),
      photos: photos,
    );
    
    return review;
  }

  Future<List<Venue>> getNearbyVenues({
    required double lat,
    required double lng,
    double radiusKm = 10.0,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    
    // Filtrar por distancia (simulación básica)
    return _venues.where((venue) => venue.distance <= radiusKm).toList();
  }

  Future<List<Venue>> getPopularVenues() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Ordenar por rating y número de reseñas
    final popular = List<Venue>.from(_venues);
    popular.sort((a, b) {
      final scoreA = a.rating * a.reviewCount;
      final scoreB = b.rating * b.reviewCount;
      return scoreB.compareTo(scoreA);
    });
    
    return popular.take(5).toList();
  }
}