enum TeamRole {
  captain,
  viceCaptain,
  member,
}

class Team {
  final String id;
  final String name;
  final String sport;
  final String description;
  final List<TeamMember> members;
  final int maxMembers;
  final DateTime createdAt;
  final TeamStats stats;
  final double rating;
  final bool isPublic;
  final String? logoUrl;
  final TeamFormation? defaultFormation;
  
  Team({
    required this.id,
    required this.name,
    required this.sport,
    required this.description,
    required this.members,
    required this.maxMembers,
    required this.createdAt,
    required this.stats,
    required this.rating,
    required this.isPublic,
    this.logoUrl,
    this.defaultFormation,
  });
  
  TeamMember? getCaptain() {
    try {
      return members.firstWhere((member) => member.role == TeamRole.captain);
    } catch (e) {
      return null;
    }
  }
  
  TeamRole getUserRole(String userId) {
    try {
      final member = members.firstWhere((m) => m.userId == userId);
      return member.role;
    } catch (e) {
      return TeamRole.member;
    }
  }
  
  bool isFull() => members.length >= maxMembers;
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'sport': sport,
    'description': description,
    'members': members.map((m) => m.toJson()).toList(),
    'maxMembers': maxMembers,
    'createdAt': createdAt.toIso8601String(),
    'stats': stats.toJson(),
    'rating': rating,
    'isPublic': isPublic,
    'logoUrl': logoUrl,
    'defaultFormation': defaultFormation?.toJson(),
  };
  
  factory Team.fromJson(Map<String, dynamic> json) => Team(
    id: json['id'],
    name: json['name'],
    sport: json['sport'],
    description: json['description'],
    members: (json['members'] as List)
        .map((m) => TeamMember.fromJson(m))
        .toList(),
    maxMembers: json['maxMembers'],
    createdAt: DateTime.parse(json['createdAt']),
    stats: TeamStats.fromJson(json['stats']),
    rating: json['rating'].toDouble(),
    isPublic: json['isPublic'],
    logoUrl: json['logoUrl'],
    defaultFormation: json['defaultFormation'] != null
        ? TeamFormation.fromJson(json['defaultFormation'])
        : null,
  );
}

class TeamMember {
  final String userId;
  final String name;
  final String email;
  final TeamRole role;
  final DateTime joinedAt;
  final PlayerPosition? preferredPosition;
  final int jerseyNumber;
  final bool isActive;
  final PlayerStats? playerStats;
  
  TeamMember({
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    required this.joinedAt,
    this.preferredPosition,
    required this.jerseyNumber,
    required this.isActive,
    this.playerStats,
  });
  
  Map<String, dynamic> toJson() => {
    'userId': userId,
    'name': name,
    'email': email,
    'role': role.toString(),
    'joinedAt': joinedAt.toIso8601String(),
    'preferredPosition': preferredPosition?.toString(),
    'jerseyNumber': jerseyNumber,
    'isActive': isActive,
    'playerStats': playerStats?.toJson(),
  };
  
  factory TeamMember.fromJson(Map<String, dynamic> json) => TeamMember(
    userId: json['userId'],
    name: json['name'],
    email: json['email'],
    role: TeamRole.values.firstWhere(
      (r) => r.toString() == json['role'],
    ),
    joinedAt: DateTime.parse(json['joinedAt']),
    preferredPosition: json['preferredPosition'] != null
        ? PlayerPosition.values.firstWhere(
            (p) => p.toString() == json['preferredPosition'],
          )
        : null,
    jerseyNumber: json['jerseyNumber'],
    isActive: json['isActive'],
    playerStats: json['playerStats'] != null
        ? PlayerStats.fromJson(json['playerStats'])
        : null,
  );
}

class TeamStats {
  final int matchesPlayed;
  final int wins;
  final int draws;
  final int losses;
  final int goalsFor;
  final int goalsAgainst;
  final int tournamentsWon;
  final DateTime lastMatch;
  
  TeamStats({
    required this.matchesPlayed,
    required this.wins,
    required this.draws,
    required this.losses,
    required this.goalsFor,
    required this.goalsAgainst,
    required this.tournamentsWon,
    required this.lastMatch,
  });
  
  double get winRate => matchesPlayed > 0 ? (wins / matchesPlayed) * 100 : 0;
  int get goalDifference => goalsFor - goalsAgainst;
  
  Map<String, dynamic> toJson() => {
    'matchesPlayed': matchesPlayed,
    'wins': wins,
    'draws': draws,
    'losses': losses,
    'goalsFor': goalsFor,
    'goalsAgainst': goalsAgainst,
    'tournamentsWon': tournamentsWon,
    'lastMatch': lastMatch.toIso8601String(),
  };
  
  factory TeamStats.fromJson(Map<String, dynamic> json) => TeamStats(
    matchesPlayed: json['matchesPlayed'],
    wins: json['wins'],
    draws: json['draws'],
    losses: json['losses'],
    goalsFor: json['goalsFor'],
    goalsAgainst: json['goalsAgainst'],
    tournamentsWon: json['tournamentsWon'],
    lastMatch: DateTime.parse(json['lastMatch']),
  );
}

class PlayerStats {
  final int goalsScored;
  final int assists;
  final int matchesPlayed;
  final int yellowCards;
  final int redCards;
  final double averageRating;
  
  PlayerStats({
    required this.goalsScored,
    required this.assists,
    required this.matchesPlayed,
    required this.yellowCards,
    required this.redCards,
    required this.averageRating,
  });
  
  Map<String, dynamic> toJson() => {
    'goalsScored': goalsScored,
    'assists': assists,
    'matchesPlayed': matchesPlayed,
    'yellowCards': yellowCards,
    'redCards': redCards,
    'averageRating': averageRating,
  };
  
  factory PlayerStats.fromJson(Map<String, dynamic> json) => PlayerStats(
    goalsScored: json['goalsScored'],
    assists: json['assists'],
    matchesPlayed: json['matchesPlayed'],
    yellowCards: json['yellowCards'],
    redCards: json['redCards'],
    averageRating: json['averageRating'].toDouble(),
  );
}

class TeamFormation {
  final String id;
  final String name;
  final String formation; // e.g., "4-4-2", "3-5-2"
  final Map<String, FormationPosition> positions;
  final bool isDefault;
  
  TeamFormation({
    required this.id,
    required this.name,
    required this.formation,
    required this.positions,
    required this.isDefault,
  });
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'formation': formation,
    'positions': positions.map((key, value) => MapEntry(key, value.toJson())),
    'isDefault': isDefault,
  };
  
  factory TeamFormation.fromJson(Map<String, dynamic> json) => TeamFormation(
    id: json['id'],
    name: json['name'],
    formation: json['formation'],
    positions: (json['positions'] as Map<String, dynamic>).map(
      (key, value) => MapEntry(key, FormationPosition.fromJson(value)),
    ),
    isDefault: json['isDefault'],
  );
}

class FormationPosition {
  final PlayerPosition position;
  final double x; // Coordenada X en el campo (0-1)
  final double y; // Coordenada Y en el campo (0-1)
  final String? assignedPlayerId;
  
  FormationPosition({
    required this.position,
    required this.x,
    required this.y,
    this.assignedPlayerId,
  });
  
  Map<String, dynamic> toJson() => {
    'position': position.toString(),
    'x': x,
    'y': y,
    'assignedPlayerId': assignedPlayerId,
  };
  
  factory FormationPosition.fromJson(Map<String, dynamic> json) => FormationPosition(
    position: PlayerPosition.values.firstWhere(
      (p) => p.toString() == json['position'],
    ),
    x: json['x'].toDouble(),
    y: json['y'].toDouble(),
    assignedPlayerId: json['assignedPlayerId'],
  );
}

enum PlayerPosition {
  goalkeeper,
  centerBack,
  leftBack,
  rightBack,
  defensiveMidfielder,
  centralMidfielder,
  attackingMidfielder,
  leftMidfielder,
  rightMidfielder,
  leftWinger,
  rightWinger,
  striker,
  centerForward,
}

class TeamInvitation {
  final String id;
  final String teamId;
  final String teamName;
  final String inviterId;
  final String inviterName;
  final String inviteeId;
  final String inviteeEmail;
  final DateTime sentAt;
  final InvitationStatus status;
  final String? message;
  
  TeamInvitation({
    required this.id,
    required this.teamId,
    required this.teamName,
    required this.inviterId,
    required this.inviterName,
    required this.inviteeId,
    required this.inviteeEmail,
    required this.sentAt,
    required this.status,
    this.message,
  });
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'teamId': teamId,
    'teamName': teamName,
    'inviterId': inviterId,
    'inviterName': inviterName,
    'inviteeId': inviteeId,
    'inviteeEmail': inviteeEmail,
    'sentAt': sentAt.toIso8601String(),
    'status': status.toString(),
    'message': message,
  };
  
  factory TeamInvitation.fromJson(Map<String, dynamic> json) => TeamInvitation(
    id: json['id'],
    teamId: json['teamId'],
    teamName: json['teamName'],
    inviterId: json['inviterId'],
    inviterName: json['inviterName'],
    inviteeId: json['inviteeId'],
    inviteeEmail: json['inviteeEmail'],
    sentAt: DateTime.parse(json['sentAt']),
    status: InvitationStatus.values.firstWhere(
      (s) => s.toString() == json['status'],
    ),
    message: json['message'],
  );
}

enum InvitationStatus {
  pending,
  accepted,
  rejected,
  expired,
}