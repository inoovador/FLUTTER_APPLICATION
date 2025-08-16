class Venue {
  final String id;
  final String name;
  final String address;
  final String sport;
  final double pricePerHour;
  final double rating;
  final int reviewCount;
  final bool isAvailable;
  final double distance; // en km
  final List<String> amenities;
  final List<TimeSlot> availableSlots;
  final String? imageUrl;
  final String ownerId;
  final String ownerName;
  final String phone;
  final String email;
  final Map<String, dynamic> location; // lat, lng
  
  Venue({
    required this.id,
    required this.name,
    required this.address,
    required this.sport,
    required this.pricePerHour,
    required this.rating,
    required this.reviewCount,
    required this.isAvailable,
    required this.distance,
    required this.amenities,
    required this.availableSlots,
    this.imageUrl,
    required this.ownerId,
    required this.ownerName,
    required this.phone,
    required this.email,
    required this.location,
  });
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'address': address,
    'sport': sport,
    'pricePerHour': pricePerHour,
    'rating': rating,
    'reviewCount': reviewCount,
    'isAvailable': isAvailable,
    'distance': distance,
    'amenities': amenities,
    'availableSlots': availableSlots.map((slot) => slot.toJson()).toList(),
    'imageUrl': imageUrl,
    'ownerId': ownerId,
    'ownerName': ownerName,
    'phone': phone,
    'email': email,
    'location': location,
  };
  
  factory Venue.fromJson(Map<String, dynamic> json) => Venue(
    id: json['id'],
    name: json['name'],
    address: json['address'],
    sport: json['sport'],
    pricePerHour: json['pricePerHour'].toDouble(),
    rating: json['rating'].toDouble(),
    reviewCount: json['reviewCount'],
    isAvailable: json['isAvailable'],
    distance: json['distance'].toDouble(),
    amenities: List<String>.from(json['amenities']),
    availableSlots: (json['availableSlots'] as List)
        .map((slot) => TimeSlot.fromJson(slot))
        .toList(),
    imageUrl: json['imageUrl'],
    ownerId: json['ownerId'],
    ownerName: json['ownerName'],
    phone: json['phone'],
    email: json['email'],
    location: json['location'],
  );
}

class TimeSlot {
  final String id;
  final String startTime;
  final String endTime;
  final double price;
  final bool isBooked;
  final String? bookedBy;
  
  TimeSlot({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.price,
    required this.isBooked,
    this.bookedBy,
  });
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'startTime': startTime,
    'endTime': endTime,
    'price': price,
    'isBooked': isBooked,
    'bookedBy': bookedBy,
  };
  
  factory TimeSlot.fromJson(Map<String, dynamic> json) => TimeSlot(
    id: json['id'],
    startTime: json['startTime'],
    endTime: json['endTime'],
    price: json['price'].toDouble(),
    isBooked: json['isBooked'],
    bookedBy: json['bookedBy'],
  );
}

class VenueBooking {
  final String id;
  final String venueId;
  final String venueName;
  final String userId;
  final String userName;
  final DateTime date;
  final TimeSlot timeSlot;
  final double totalPrice;
  final BookingStatus status;
  final DateTime createdAt;
  final String? notes;
  final PaymentInfo? paymentInfo;
  
  VenueBooking({
    required this.id,
    required this.venueId,
    required this.venueName,
    required this.userId,
    required this.userName,
    required this.date,
    required this.timeSlot,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    this.notes,
    this.paymentInfo,
  });
}

class PaymentInfo {
  final String method;
  final String transactionId;
  final DateTime paidAt;
  final double amount;
  
  PaymentInfo({
    required this.method,
    required this.transactionId,
    required this.paidAt,
    required this.amount,
  });
}

enum BookingStatus {
  pending,
  confirmed,
  cancelled,
  completed,
}

class VenueReview {
  final String id;
  final String venueId;
  final String userId;
  final String userName;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final List<String> photos;
  
  VenueReview({
    required this.id,
    required this.venueId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.photos,
  });
}