import '../models/team_model.dart';
import '../models/rating_model.dart' as rating;

class TeamService {
  // Datos de ejemplo
  static final List<Team> _teams = [
    Team(
      id: 'team1',
      name: 'Los Halcones',
      sport: 'Fútbol',
      description: 'Equipo competitivo de fútbol amateur',
      members: [
        TeamMember(
          userId: 'user123',
          name: 'Juan Pérez',
          email: 'juan@email.com',
          role: TeamRole.captain,
          joinedAt: DateTime.now().subtract(const Duration(days: 30)),
          preferredPosition: PlayerPosition.striker,
          jerseyNumber: 10,
          isActive: true,
          playerStats: PlayerStats(
            goalsScored: 15,
            assists: 8,
            matchesPlayed: 20,
            yellowCards: 2,
            redCards: 0,
            averageRating: 4.3,
          ),
        ),
        TeamMember(
          userId: 'user456',
          name: 'Carlos López',
          email: 'carlos@email.com',
          role: TeamRole.viceCaptain,
          joinedAt: DateTime.now().subtract(const Duration(days: 25)),
          preferredPosition: PlayerPosition.centerBack,
          jerseyNumber: 4,
          isActive: true,
          playerStats: PlayerStats(
            goalsScored: 2,
            assists: 5,
            matchesPlayed: 18,
            yellowCards: 3,
            redCards: 0,
            averageRating: 4.1,
          ),
        ),
        TeamMember(
          userId: 'user789',
          name: 'Miguel Silva',
          email: 'miguel@email.com',
          role: TeamRole.member,
          joinedAt: DateTime.now().subtract(const Duration(days: 20)),
          preferredPosition: PlayerPosition.goalkeeper,
          jerseyNumber: 1,
          isActive: true,
          playerStats: PlayerStats(
            goalsScored: 0,
            assists: 0,
            matchesPlayed: 15,
            yellowCards: 1,
            redCards: 0,
            averageRating: 4.5,
          ),
        ),
      ],
      maxMembers: 18,
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      stats: TeamStats(
        matchesPlayed: 25,
        wins: 18,
        draws: 4,
        losses: 3,
        goalsFor: 45,
        goalsAgainst: 18,
        tournamentsWon: 2,
        lastMatch: DateTime.now().subtract(const Duration(days: 3)),
      ),
      rating: 4.3,
      isPublic: true,
      defaultFormation: TeamFormation(
        id: 'formation1',
        name: '4-4-2 Clásico',
        formation: '4-4-2',
        positions: {
          'gk': FormationPosition(
            position: PlayerPosition.goalkeeper,
            x: 0.1,
            y: 0.5,
            assignedPlayerId: 'user789',
          ),
          'cb1': FormationPosition(
            position: PlayerPosition.centerBack,
            x: 0.25,
            y: 0.3,
            assignedPlayerId: 'user456',
          ),
          'cb2': FormationPosition(
            position: PlayerPosition.centerBack,
            x: 0.25,
            y: 0.7,
          ),
          'lb': FormationPosition(
            position: PlayerPosition.leftBack,
            x: 0.25,
            y: 0.1,
          ),
          'rb': FormationPosition(
            position: PlayerPosition.rightBack,
            x: 0.25,
            y: 0.9,
          ),
          'cm1': FormationPosition(
            position: PlayerPosition.centralMidfielder,
            x: 0.5,
            y: 0.35,
          ),
          'cm2': FormationPosition(
            position: PlayerPosition.centralMidfielder,
            x: 0.5,
            y: 0.65,
          ),
          'lm': FormationPosition(
            position: PlayerPosition.leftMidfielder,
            x: 0.5,
            y: 0.15,
          ),
          'rm': FormationPosition(
            position: PlayerPosition.rightMidfielder,
            x: 0.5,
            y: 0.85,
          ),
          'st1': FormationPosition(
            position: PlayerPosition.striker,
            x: 0.8,
            y: 0.4,
            assignedPlayerId: 'user123',
          ),
          'st2': FormationPosition(
            position: PlayerPosition.striker,
            x: 0.8,
            y: 0.6,
          ),
        },
        isDefault: true,
      ),
    ),
  ];

  static final List<TeamInvitation> _invitations = [
    TeamInvitation(
      id: 'inv1',
      teamId: 'team2',
      teamName: 'Águilas FC',
      inviterId: 'user999',
      inviterName: 'Roberto Sánchez',
      inviteeId: 'user123',
      inviteeEmail: 'juan@email.com',
      sentAt: DateTime.now().subtract(const Duration(hours: 2)),
      status: InvitationStatus.pending,
      message: '¡Te invitamos a unirte a nuestro equipo!',
    ),
  ];

  Future<List<Team>> getUserTeams(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    return _teams.where((team) => 
      team.members.any((member) => member.userId == userId)
    ).toList();
  }

  Future<Team> createTeam({
    required String name,
    required String sport,
    required String description,
    required String captainId,
    int maxMembers = 18,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    final team = Team(
      id: 'team_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      sport: sport,
      description: description,
      members: [
        TeamMember(
          userId: captainId,
          name: 'Usuario Demo', // En la app real obtener del perfil
          email: 'demo@email.com',
          role: TeamRole.captain,
          joinedAt: DateTime.now(),
          jerseyNumber: 1,
          isActive: true,
        ),
      ],
      maxMembers: maxMembers,
      createdAt: DateTime.now(),
      stats: TeamStats(
        matchesPlayed: 0,
        wins: 0,
        draws: 0,
        losses: 0,
        goalsFor: 0,
        goalsAgainst: 0,
        tournamentsWon: 0,
        lastMatch: DateTime.now(),
      ),
      rating: 0.0,
      isPublic: true,
    );
    
    _teams.add(team);
    return team;
  }

  Future<List<TeamInvitation>> getPendingInvitations(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    return _invitations.where((invitation) => 
      invitation.inviteeId == userId && 
      invitation.status == InvitationStatus.pending
    ).toList();
  }

  Future<TeamInvitation> invitePlayer({
    required String teamId,
    required String inviterId,
    required String inviterName,
    required String inviteeEmail,
    String? message,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    
    final team = _teams.firstWhere((t) => t.id == teamId);
    
    final invitation = TeamInvitation(
      id: 'inv_${DateTime.now().millisecondsSinceEpoch}',
      teamId: teamId,
      teamName: team.name,
      inviterId: inviterId,
      inviterName: inviterName,
      inviteeId: 'user_temp', // En la app real buscar por email
      inviteeEmail: inviteeEmail,
      sentAt: DateTime.now(),
      status: InvitationStatus.pending,
      message: message,
    );
    
    _invitations.add(invitation);
    return invitation;
  }

  Future<bool> respondToInvitation(
    String invitationId,
    String userId,
    bool accept,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final invitationIndex = _invitations.indexWhere((inv) => inv.id == invitationId);
    if (invitationIndex == -1) {
      throw Exception('Invitación no encontrada');
    }
    
    final invitation = _invitations[invitationIndex];
    
    if (accept) {
      // Agregar al equipo
      final teamIndex = _teams.indexWhere((t) => t.id == invitation.teamId);
      if (teamIndex != -1) {
        final team = _teams[teamIndex];
        if (team.isFull()) {
          throw Exception('El equipo está lleno');
        }
        
        final newMember = TeamMember(
          userId: userId,
          name: 'Usuario Demo', // Obtener del perfil
          email: invitation.inviteeEmail,
          role: TeamRole.member,
          joinedAt: DateTime.now(),
          jerseyNumber: _getNextJerseyNumber(team),
          isActive: true,
        );
        
        team.members.add(newMember);
      }
      
      _invitations[invitationIndex] = TeamInvitation(
        id: invitation.id,
        teamId: invitation.teamId,
        teamName: invitation.teamName,
        inviterId: invitation.inviterId,
        inviterName: invitation.inviterName,
        inviteeId: invitation.inviteeId,
        inviteeEmail: invitation.inviteeEmail,
        sentAt: invitation.sentAt,
        status: InvitationStatus.accepted,
        message: invitation.message,
      );
    } else {
      _invitations[invitationIndex] = TeamInvitation(
        id: invitation.id,
        teamId: invitation.teamId,
        teamName: invitation.teamName,
        inviterId: invitation.inviterId,
        inviterName: invitation.inviterName,
        inviteeId: invitation.inviteeId,
        inviteeEmail: invitation.inviteeEmail,
        sentAt: invitation.sentAt,
        status: InvitationStatus.rejected,
        message: invitation.message,
      );
    }
    
    return true;
  }

  Future<bool> removeTeamMember(String teamId, String memberId, String requesterId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    final teamIndex = _teams.indexWhere((t) => t.id == teamId);
    if (teamIndex == -1) {
      throw Exception('Equipo no encontrado');
    }
    
    final team = _teams[teamIndex];
    final requester = team.members.firstWhere((m) => m.userId == requesterId);
    
    // Solo capitán o vice-capitán pueden remover miembros
    if (requester.role != TeamRole.captain && requester.role != TeamRole.viceCaptain) {
      throw Exception('No tienes permisos para remover miembros');
    }
    
    team.members.removeWhere((member) => member.userId == memberId);
    return true;
  }

  Future<TeamFormation> saveFormation(String teamId, TeamFormation formation) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    // En la app real, guardar en base de datos
    return formation;
  }

  Future<List<TeamFormation>> getTeamFormations(String teamId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Formaciones predefinidas
    return [
      TeamFormation(
        id: 'formation_442',
        name: '4-4-2 Clásico',
        formation: '4-4-2',
        positions: _get442Formation(),
        isDefault: true,
      ),
      TeamFormation(
        id: 'formation_433',
        name: '4-3-3 Ofensivo',
        formation: '4-3-3',
        positions: _get433Formation(),
        isDefault: false,
      ),
      TeamFormation(
        id: 'formation_352',
        name: '3-5-2 Flexible',
        formation: '3-5-2',
        positions: _get352Formation(),
        isDefault: false,
      ),
    ];
  }

  Future<List<Team>> searchTeams({
    String? query,
    String? sport,
    bool onlyPublic = true,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    
    var results = List<Team>.from(_teams);
    
    if (onlyPublic) {
      results = results.where((team) => team.isPublic).toList();
    }
    
    if (query != null && query.isNotEmpty) {
      final lowerQuery = query.toLowerCase();
      results = results.where((team) => 
        team.name.toLowerCase().contains(lowerQuery) ||
        team.description.toLowerCase().contains(lowerQuery)
      ).toList();
    }
    
    if (sport != null && sport.isNotEmpty) {
      results = results.where((team) => 
        team.sport.toLowerCase() == sport.toLowerCase()
      ).toList();
    }
    
    return results;
  }

  int _getNextJerseyNumber(Team team) {
    final usedNumbers = team.members.map((m) => m.jerseyNumber).toSet();
    for (int i = 1; i <= 99; i++) {
      if (!usedNumbers.contains(i)) {
        return i;
      }
    }
    return 99; // Fallback
  }

  Map<String, FormationPosition> _get442Formation() {
    return {
      'gk': FormationPosition(position: PlayerPosition.goalkeeper, x: 0.1, y: 0.5),
      'lb': FormationPosition(position: PlayerPosition.leftBack, x: 0.25, y: 0.15),
      'cb1': FormationPosition(position: PlayerPosition.centerBack, x: 0.25, y: 0.35),
      'cb2': FormationPosition(position: PlayerPosition.centerBack, x: 0.25, y: 0.65),
      'rb': FormationPosition(position: PlayerPosition.rightBack, x: 0.25, y: 0.85),
      'lm': FormationPosition(position: PlayerPosition.leftMidfielder, x: 0.5, y: 0.2),
      'cm1': FormationPosition(position: PlayerPosition.centralMidfielder, x: 0.5, y: 0.4),
      'cm2': FormationPosition(position: PlayerPosition.centralMidfielder, x: 0.5, y: 0.6),
      'rm': FormationPosition(position: PlayerPosition.rightMidfielder, x: 0.5, y: 0.8),
      'st1': FormationPosition(position: PlayerPosition.striker, x: 0.8, y: 0.35),
      'st2': FormationPosition(position: PlayerPosition.striker, x: 0.8, y: 0.65),
    };
  }

  Map<String, FormationPosition> _get433Formation() {
    return {
      'gk': FormationPosition(position: PlayerPosition.goalkeeper, x: 0.1, y: 0.5),
      'lb': FormationPosition(position: PlayerPosition.leftBack, x: 0.25, y: 0.15),
      'cb1': FormationPosition(position: PlayerPosition.centerBack, x: 0.25, y: 0.35),
      'cb2': FormationPosition(position: PlayerPosition.centerBack, x: 0.25, y: 0.65),
      'rb': FormationPosition(position: PlayerPosition.rightBack, x: 0.25, y: 0.85),
      'dm': FormationPosition(position: PlayerPosition.defensiveMidfielder, x: 0.45, y: 0.5),
      'cm1': FormationPosition(position: PlayerPosition.centralMidfielder, x: 0.55, y: 0.35),
      'cm2': FormationPosition(position: PlayerPosition.centralMidfielder, x: 0.55, y: 0.65),
      'lw': FormationPosition(position: PlayerPosition.leftWinger, x: 0.8, y: 0.2),
      'st': FormationPosition(position: PlayerPosition.centerForward, x: 0.8, y: 0.5),
      'rw': FormationPosition(position: PlayerPosition.rightWinger, x: 0.8, y: 0.8),
    };
  }

  Map<String, FormationPosition> _get352Formation() {
    return {
      'gk': FormationPosition(position: PlayerPosition.goalkeeper, x: 0.1, y: 0.5),
      'cb1': FormationPosition(position: PlayerPosition.centerBack, x: 0.25, y: 0.25),
      'cb2': FormationPosition(position: PlayerPosition.centerBack, x: 0.25, y: 0.5),
      'cb3': FormationPosition(position: PlayerPosition.centerBack, x: 0.25, y: 0.75),
      'lwb': FormationPosition(position: PlayerPosition.leftBack, x: 0.45, y: 0.1),
      'cm1': FormationPosition(position: PlayerPosition.centralMidfielder, x: 0.5, y: 0.35),
      'cm2': FormationPosition(position: PlayerPosition.centralMidfielder, x: 0.5, y: 0.5),
      'cm3': FormationPosition(position: PlayerPosition.centralMidfielder, x: 0.5, y: 0.65),
      'rwb': FormationPosition(position: PlayerPosition.rightBack, x: 0.45, y: 0.9),
      'st1': FormationPosition(position: PlayerPosition.striker, x: 0.8, y: 0.4),
      'st2': FormationPosition(position: PlayerPosition.striker, x: 0.8, y: 0.6),
    };
  }
}