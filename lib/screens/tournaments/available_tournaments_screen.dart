import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/tournament_model.dart';
import 'tournament_detail_player_screen.dart';

class AvailableTournamentsScreen extends StatefulWidget {
  const AvailableTournamentsScreen({super.key});

  @override
  State<AvailableTournamentsScreen> createState() => _AvailableTournamentsScreenState();
}

class _AvailableTournamentsScreenState extends State<AvailableTournamentsScreen> {
  String _selectedSport = 'todos';
  String _selectedCategory = 'todos';
  
  // Lista de torneos disponibles (mismos que el organizador)
  final List<TournamentModel> _allTournaments = [
    TournamentModel(
      id: '1',
      organizerId: 'org1',
      organizerName: 'Academia Deportiva Juan',
      organizerYape: '932744546',
      name: 'Copa Verano 2024',
      description: 'Torneo relámpago de fútbol 7. Gran premio para el campeón. Canchas de césped sintético de primera calidad.',
      sport: 'futbol',
      category: 'libre',
      date: DateTime.now().add(const Duration(days: 15)),
      location: 'Estadio Municipal - Av. Principal 123',
      pricePerPlayer: 50.0,
      maxTeams: 16,
      registeredTeams: 12,
      status: 'published',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    TournamentModel(
      id: '2',
      organizerId: 'org1',
      organizerName: 'Academia Deportiva Juan',
      organizerYape: '932744546',
      name: 'Liga Amateur Sub-17',
      description: 'Liga competitiva para jóvenes talentos. Oportunidad de ser visto por scouts.',
      sport: 'futbol',
      category: 'sub17',
      date: DateTime.now().add(const Duration(days: 30)),
      location: 'Complejo Deportivo Norte',
      pricePerPlayer: 75.0,
      maxTeams: 20,
      registeredTeams: 8,
      status: 'published',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    TournamentModel(
      id: '3',
      organizerId: 'org2',
      organizerName: 'Club Voley Masters',
      organizerYape: '987654321',
      name: 'Torneo Mixto de Vóley',
      description: 'Torneo de vóley mixto. Mínimo 2 mujeres en cancha.',
      sport: 'voley',
      category: 'libre',
      date: DateTime.now().add(const Duration(days: 20)),
      location: 'Coliseo Cerrado San Miguel',
      pricePerPlayer: 40.0,
      maxTeams: 12,
      registeredTeams: 10,
      status: 'published',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
  ];

  List<TournamentModel> get _filteredTournaments {
    return _allTournaments.where((tournament) {
      final sportMatch = _selectedSport == 'todos' || tournament.sport == _selectedSport;
      final categoryMatch = _selectedCategory == 'todos' || tournament.category == _selectedCategory;
      return sportMatch && categoryMatch && tournament.hasAvailableSpots;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Torneos Disponibles'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filtros
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                // Filtro de deporte
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: const Text('Todos'),
                    selected: _selectedSport == 'todos',
                    onSelected: (selected) {
                      setState(() => _selectedSport = 'todos');
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: const Text('Fútbol'),
                    selected: _selectedSport == 'futbol',
                    onSelected: (selected) {
                      setState(() => _selectedSport = selected ? 'futbol' : 'todos');
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: const Text('Vóley'),
                    selected: _selectedSport == 'voley',
                    onSelected: (selected) {
                      setState(() => _selectedSport = selected ? 'voley' : 'todos');
                    },
                  ),
                ),
                const VerticalDivider(),
                // Filtro de categoría
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: const Text('Libre'),
                    selected: _selectedCategory == 'libre',
                    onSelected: (selected) {
                      setState(() => _selectedCategory = selected ? 'libre' : 'todos');
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: const Text('Sub-17'),
                    selected: _selectedCategory == 'sub17',
                    onSelected: (selected) {
                      setState(() => _selectedCategory = selected ? 'sub17' : 'todos');
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Lista de torneos
          Expanded(
            child: _filteredTournaments.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.sports_soccer,
                          size: 80,
                          color: const Color(0xFF909090),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay torneos disponibles',
                          style: TextStyle(
                            fontSize: 18,
                            color: const Color(0xFF909090),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Intenta cambiar los filtros',
                          style: TextStyle(
                            fontSize: 14,
                            color: const Color(0xFF909090).withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredTournaments.length,
                    itemBuilder: (context, index) {
                      return _buildTournamentCard(_filteredTournaments[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTournamentCard(TournamentModel tournament) {
    final dateFormat = DateFormat('dd MMM');
    final daysUntil = tournament.date.difference(DateTime.now()).inDays;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TournamentDetailPlayerScreen(
                tournament: tournament,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con imagen simulada
            Container(
              height: 150,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF97FB57).withOpacity(0.8),
                    const Color(0xFF97FB57).withOpacity(0.4),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Icon(
                      _getSportIcon(tournament.sport),
                      size: 100,
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        tournament.categoryDisplay,
                        style: TextStyle(
                          color: const Color(0xFF121212),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$daysUntil días',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Contenido
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre y organizador
                  Text(
                    tournament.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.business, size: 16, color: Color(0xFF909090)),
                      const SizedBox(width: 4),
                      Text(
                        tournament.organizerName,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF909090),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Fecha y ubicación
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: Color(0xFF909090)),
                      const SizedBox(width: 4),
                      Text(
                        dateFormat.format(tournament.date),
                        style: const TextStyle(fontSize: 14, color: Color(0xFF909090)),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.location_on, size: 16, color: Color(0xFF909090)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          tournament.location,
                          style: const TextStyle(fontSize: 14, color: Color(0xFF909090)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Precio y disponibilidad
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF97FB57).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.attach_money,
                                  size: 16,
                                  color: const Color(0xFF97FB57),
                                ),
                                Text(
                                  'S/ ${tournament.pricePerPlayer.toStringAsFixed(0)} por jugador',
                                  style: const TextStyle(
                                    color: Color(0xFF97FB57),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.group,
                            size: 16,
                            color: tournament.registrationProgress > 0.8
                                ? const Color(0xFFFF6B6B)
                                : const Color(0xFF97FB57),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${tournament.maxTeams - tournament.registeredTeams} cupos',
                            style: TextStyle(
                              fontSize: 14,
                              color: tournament.registrationProgress > 0.8
                                  ? const Color(0xFFFF6B6B)
                                  : const Color(0xFF97FB57),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getSportColor(String sport) {
    switch (sport) {
      case 'futbol':
      case 'futsal':
        return Colors.green;
      case 'voley':
        return Colors.blue;
      case 'basket':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getSportIcon(String sport) {
    switch (sport) {
      case 'futbol':
      case 'futsal':
        return Icons.sports_soccer;
      case 'voley':
        return Icons.sports_volleyball;
      case 'basket':
        return Icons.sports_basketball;
      default:
        return Icons.sports;
    }
  }
}