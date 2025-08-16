import 'package:flutter/foundation.dart';
import '../models/tournament_model.dart';

class TournamentService extends ChangeNotifier {
  static final TournamentService _instance = TournamentService._internal();
  factory TournamentService() => _instance;
  TournamentService._internal();

  final List<TournamentModel> _tournaments = [];
  bool _isLoading = false;

  List<TournamentModel> get tournaments => List.unmodifiable(_tournaments);
  bool get isLoading => _isLoading;

  // Obtener todos los torneos
  Future<List<TournamentModel>> getAllTournaments() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulación temporal - en producción conectar con API
      await Future.delayed(const Duration(seconds: 1));
      
      // Datos de ejemplo
      _tournaments.clear();
      _tournaments.addAll([
        TournamentModel(
          id: '1',
          organizerId: 'org1',
          organizerName: 'Club Deportivo Central',
          organizerYape: '987654321',
          name: 'Torneo de Fútbol Amateur',
          description: 'Torneo de fútbol para equipos amateur de la ciudad',
          sport: 'futbol',
          category: 'libre',
          date: DateTime.now().add(const Duration(days: 7)),
          location: 'Estadio Municipal',
          pricePerPlayer: 25.0,
          maxTeams: 16,
          registeredTeams: 8,
          status: 'published',
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
        TournamentModel(
          id: '2',
          organizerId: 'org2',
          organizerName: 'Asociación de Básquet',
          organizerYape: '912345678',
          name: 'Campeonato de Básquetbol',
          description: 'Torneo de básquetbol categoría senior',
          sport: 'basket',
          category: 'senior',
          date: DateTime.now().add(const Duration(days: 14)),
          location: 'Polideportivo Central',
          pricePerPlayer: 30.0,
          maxTeams: 8,
          registeredTeams: 3,
          status: 'published',
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
      ]);

      return _tournaments;
    } catch (e) {
      debugPrint('Error cargando torneos: $e');
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Buscar torneos
  Future<List<TournamentModel>> searchTournaments({
    String? query,
    String? sport,
    String? location,
    double? minPrice,
    double? maxPrice,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final allTournaments = await getAllTournaments();
    
    return allTournaments.where((tournament) {
      if (query != null && query.isNotEmpty) {
        final searchLower = query.toLowerCase();
        if (!tournament.name.toLowerCase().contains(searchLower) &&
            !tournament.description.toLowerCase().contains(searchLower)) {
          return false;
        }
      }
      
      if (sport != null && sport.isNotEmpty) {
        if (tournament.sport != sport) {
          return false;
        }
      }
      
      if (location != null && location.isNotEmpty) {
        if (!tournament.location.toLowerCase().contains(location.toLowerCase())) {
          return false;
        }
      }
      
      if (minPrice != null && tournament.pricePerPlayer < minPrice) {
        return false;
      }
      
      if (maxPrice != null && tournament.pricePerPlayer > maxPrice) {
        return false;
      }
      
      if (startDate != null && tournament.date.isBefore(startDate)) {
        return false;
      }
      
      if (endDate != null && tournament.date.isAfter(endDate)) {
        return false;
      }
      
      return true;
    }).toList();
  }

  // Obtener torneo por ID
  Future<TournamentModel?> getTournamentById(String id) async {
    try {
      await getAllTournaments();
      return _tournaments.firstWhere((t) => t.id == id);
    } catch (e) {
      debugPrint('Error obteniendo torneo $id: $e');
      return null;
    }
  }

  // Crear nuevo torneo
  Future<TournamentModel?> createTournament(TournamentModel tournament) async {
    try {
      // Simulación temporal
      await Future.delayed(const Duration(seconds: 1));
      
      final newTournament = TournamentModel(
        id: 'tournament_${DateTime.now().millisecondsSinceEpoch}',
        organizerId: tournament.organizerId,
        organizerName: tournament.organizerName,
        organizerYape: tournament.organizerYape,
        name: tournament.name,
        description: tournament.description,
        sport: tournament.sport,
        category: tournament.category,
        date: tournament.date,
        location: tournament.location,
        pricePerPlayer: tournament.pricePerPlayer,
        maxTeams: tournament.maxTeams,
        registeredTeams: 0,
        status: 'published',
        createdAt: DateTime.now(),
      );
      
      _tournaments.add(newTournament);
      notifyListeners();
      
      return newTournament;
    } catch (e) {
      debugPrint('Error creando torneo: $e');
      return null;
    }
  }

  // Actualizar torneo
  Future<bool> updateTournament(TournamentModel tournament) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      final index = _tournaments.indexWhere((t) => t.id == tournament.id);
      if (index != -1) {
        _tournaments[index] = tournament;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error actualizando torneo: $e');
      return false;
    }
  }

  // Eliminar torneo
  Future<bool> deleteTournament(String id) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      final initialLength = _tournaments.length;
      _tournaments.removeWhere((t) => t.id == id);
      final removed = _tournaments.length < initialLength;
      if (removed) {
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error eliminando torneo: $e');
      return false;
    }
  }

  // Inscribirse a torneo
  Future<bool> registerForTournament(String tournamentId, String teamId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      final tournament = await getTournamentById(tournamentId);
      if (tournament != null && tournament.hasAvailableSpots && !tournament.isExpired) {
        // Aquí iría la lógica de inscripción
        debugPrint('Equipo $teamId inscrito en torneo $tournamentId');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error inscribiendo en torneo: $e');
      return false;
    }
  }

  // Obtener torneos por organizador
  Future<List<TournamentModel>> getTournamentsByOrganizer(String organizerId) async {
    await getAllTournaments();
    return _tournaments.where((t) => t.organizerId == organizerId).toList();
  }

  // Obtener torneos disponibles (no expirados y con cupos)
  Future<List<TournamentModel>> getAvailableTournaments() async {
    await getAllTournaments();
    return _tournaments.where((t) => !t.isExpired && t.hasAvailableSpots).toList();
  }

  // Limpiar cache
  void clearCache() {
    _tournaments.clear();
    notifyListeners();
  }
}