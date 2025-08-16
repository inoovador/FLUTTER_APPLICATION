class UserModel {
  final String id;
  final String email;
  final String name;
  final String? photoUrl;
  final String role;
  final DateTime createdAt;
  final List<String> teamIds;
  final Map<String, dynamic>? playerProfile;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
    required this.role,
    required this.createdAt,
    required this.teamIds,
    this.playerProfile,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      photoUrl: json['photoUrl'],
      role: json['role'] ?? 'player',
      createdAt: DateTime.parse(json['createdAt']),
      teamIds: List<String>.from(json['teamIds'] ?? []),
      playerProfile: json['playerProfile'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'teamIds': teamIds,
      'playerProfile': playerProfile,
    };
  }
}