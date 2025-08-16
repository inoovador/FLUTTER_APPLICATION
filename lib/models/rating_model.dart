import 'package:flutter/material.dart';

class PlayerRating {
  final String id;
  final String playerId;
  final String playerName;
  final String evaluatorId;
  final String evaluatorName;
  final String tournamentId;
  final String matchId;
  final double skillRating;
  final double sportsmanshipRating;
  final double punctualityRating;
  final double teamworkRating;
  final String? comment;
  final DateTime createdAt;
  
  PlayerRating({
    required this.id,
    required this.playerId,
    required this.playerName,
    required this.evaluatorId,
    required this.evaluatorName,
    required this.tournamentId,
    required this.matchId,
    required this.skillRating,
    required this.sportsmanshipRating,
    required this.punctualityRating,
    required this.teamworkRating,
    this.comment,
    required this.createdAt,
  });
  
  double get overallRating {
    return (skillRating + sportsmanshipRating + punctualityRating + teamworkRating) / 4;
  }
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'playerId': playerId,
    'playerName': playerName,
    'evaluatorId': evaluatorId,
    'evaluatorName': evaluatorName,
    'tournamentId': tournamentId,
    'matchId': matchId,
    'skillRating': skillRating,
    'sportsmanshipRating': sportsmanshipRating,
    'punctualityRating': punctualityRating,
    'teamworkRating': teamworkRating,
    'comment': comment,
    'createdAt': createdAt.toIso8601String(),
  };
  
  factory PlayerRating.fromJson(Map<String, dynamic> json) => PlayerRating(
    id: json['id'],
    playerId: json['playerId'],
    playerName: json['playerName'],
    evaluatorId: json['evaluatorId'],
    evaluatorName: json['evaluatorName'],
    tournamentId: json['tournamentId'],
    matchId: json['matchId'],
    skillRating: json['skillRating'].toDouble(),
    sportsmanshipRating: json['sportsmanshipRating'].toDouble(),
    punctualityRating: json['punctualityRating'].toDouble(),
    teamworkRating: json['teamworkRating'].toDouble(),
    comment: json['comment'],
    createdAt: DateTime.parse(json['createdAt']),
  );
}

class PlayerStats {
  final String playerId;
  final String playerName;
  final int totalMatches;
  final int wins;
  final int losses;
  final int draws;
  final int goalsScored;
  final int goalsReceived;
  final double averageRating;
  final int totalRatings;
  final Map<String, double> categoryRatings;
  final List<Achievement> achievements;
  final int ranking;
  final String tier; // Bronce, Plata, Oro, Diamante
  
  PlayerStats({
    required this.playerId,
    required this.playerName,
    required this.totalMatches,
    required this.wins,
    required this.losses,
    required this.draws,
    required this.goalsScored,
    required this.goalsReceived,
    required this.averageRating,
    required this.totalRatings,
    required this.categoryRatings,
    required this.achievements,
    required this.ranking,
    required this.tier,
  });
  
  double get winRate => totalMatches > 0 ? (wins / totalMatches) * 100 : 0;
  
  String get tierIcon {
    switch (tier) {
      case 'Diamante':
        return '💎';
      case 'Oro':
        return '🏆';
      case 'Plata':
        return '🥈';
      case 'Bronce':
        return '🥉';
      default:
        return '⚽';
    }
  }
  
  Color get tierColor {
    switch (tier) {
      case 'Diamante':
        return const Color(0xFF00D4FF);
      case 'Oro':
        return const Color(0xFFFFD700);
      case 'Plata':
        return const Color(0xFFC0C0C0);
      case 'Bronce':
        return const Color(0xFFCD7F32);
      default:
        return const Color(0xFF909090);
    }
  }
}

class Achievement {
  final String id;
  final String name;
  final String description;
  final String icon;
  final DateTime unlockedAt;
  final AchievementType type;
  final int progress;
  final int maxProgress;
  
  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.unlockedAt,
    required this.type,
    required this.progress,
    required this.maxProgress,
  });
  
  bool get isUnlocked => progress >= maxProgress;
  double get progressPercentage => (progress / maxProgress) * 100;
}

enum AchievementType {
  matches,
  wins,
  goals,
  ratings,
  tournaments,
  special,
}

class Leaderboard {
  final String tournamentId;
  final String tournamentName;
  final List<LeaderboardEntry> entries;
  final DateTime lastUpdated;
  
  Leaderboard({
    required this.tournamentId,
    required this.tournamentName,
    required this.entries,
    required this.lastUpdated,
  });
}

class LeaderboardEntry {
  final int position;
  final String playerId;
  final String playerName;
  final String teamName;
  final int points;
  final int matchesPlayed;
  final int wins;
  final int draws;
  final int losses;
  final int goalsFor;
  final int goalsAgainst;
  final double rating;
  
  LeaderboardEntry({
    required this.position,
    required this.playerId,
    required this.playerName,
    required this.teamName,
    required this.points,
    required this.matchesPlayed,
    required this.wins,
    required this.draws,
    required this.losses,
    required this.goalsFor,
    required this.goalsAgainst,
    required this.rating,
  });
  
  int get goalDifference => goalsFor - goalsAgainst;
}