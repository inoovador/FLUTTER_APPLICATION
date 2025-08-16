import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/venue_model.dart';
import '../../services/venue_service.dart';

class VenueBookingScreen extends StatefulWidget {
  const VenueBookingScreen({super.key});

  @override
  State<VenueBookingScreen> createState() => _VenueBookingScreenState();
}

class _VenueBookingScreenState extends State<VenueBookingScreen> {
  final VenueService _venueService = VenueService();
  List<Venue> _venues = [];
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();
  String? _selectedSport;
  String? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _loadVenues();
  }

  Future<void> _loadVenues() async {
    setState(() => _isLoading = true);
    
    try {
      final venues = await _venueService.getAvailableVenues(
        date: _selectedDate,
        sport: _selectedSport,
        location: _selectedLocation,
      );
      
      setState(() {
        _venues = venues;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Error al cargar canchas');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFFF6B6B),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF97FB57),
              surface: Color(0xFF1A1A1A),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      _loadVenues();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Reservar Cancha'),
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () {
              // Mostrar mapa de canchas
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtros
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A1A),
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFF2A2A2A),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                // Selector de fecha
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _selectDate,
                        icon: const Icon(Icons.calendar_today),
                        label: Text(
                          DateFormat('EEEE, dd MMM', 'es').format(_selectedDate),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Filtros de deporte y ubicación
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedSport,
                        hint: const Text('Deporte'),
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          border: OutlineInputBorder(),
                        ),
                        dropdownColor: const Color(0xFF2A2A2A),
                        items: ['Fútbol', 'Básquet', 'Vóley', 'Tenis', 'Fútsal']
                            .map((sport) => DropdownMenuItem(
                                  value: sport,
                                  child: Text(sport),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() => _selectedSport = value);
                          _loadVenues();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedLocation,
                        hint: const Text('Ubicación'),
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          border: OutlineInputBorder(),
                        ),
                        dropdownColor: const Color(0xFF2A2A2A),
                        items: ['Lima Norte', 'Lima Sur', 'Lima Este', 'Lima Centro']
                            .map((location) => DropdownMenuItem(
                                  value: location,
                                  child: Text(location),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() => _selectedLocation = value);
                          _loadVenues();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Lista de canchas
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF97FB57),
                    ),
                  )
                : _venues.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.sports_tennis,
                              size: 80,
                              color: const Color(0xFF909090).withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No hay canchas disponibles',
                              style: TextStyle(
                                fontSize: 18,
                                color: const Color(0xFF909090).withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Intenta cambiar la fecha o filtros',
                              style: TextStyle(
                                fontSize: 14,
                                color: const Color(0xFF909090).withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _venues.length,
                        itemBuilder: (context, index) {
                          final venue = _venues[index];
                          return _buildVenueCard(venue);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildVenueCard(Venue venue) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen de la cancha
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF97FB57).withOpacity(0.3),
                  const Color(0xFF97FB57).withOpacity(0.1),
                ],
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    _getSportIcon(venue.sport),
                    size: 80,
                    color: const Color(0xFF97FB57),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: venue.isAvailable 
                          ? const Color(0xFF97FB57)
                          : const Color(0xFFFF6B6B),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      venue.isAvailable ? 'Disponible' : 'Ocupado',
                      style: const TextStyle(
                        color: Color(0xFF121212),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < venue.rating.floor()
                            ? Icons.star
                            : Icons.star_border,
                        color: const Color(0xFFFFD93D),
                        size: 20,
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
          
          // Información de la cancha
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            venue.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 16, color: Color(0xFF909090)),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  venue.address,
                                  style: const TextStyle(
                                    color: Color(0xFF909090),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'S/ ${venue.pricePerHour}/h',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF97FB57),
                          ),
                        ),
                        Text(
                          '${venue.distance.toStringAsFixed(1)} km',
                          style: const TextStyle(
                            color: Color(0xFF909090),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Características
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: venue.amenities.map((amenity) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        amenity,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF909090),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: 16),
                
                // Horarios disponibles
                Text(
                  'Horarios disponibles:',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: venue.availableSlots.length,
                    itemBuilder: (context, index) {
                      final slot = venue.availableSlots[index];
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: OutlinedButton(
                          onPressed: () => _bookSlot(venue, slot),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF97FB57)),
                          ),
                          child: Text(
                            '${slot.startTime} - ${slot.endTime}',
                            style: const TextStyle(
                              color: Color(0xFF97FB57),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Botones de acción
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showVenueDetails(venue),
                        icon: const Icon(Icons.info_outline),
                        label: const Text('Detalles'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: venue.isAvailable 
                            ? () => _showBookingModal(venue)
                            : null,
                        icon: const Icon(Icons.book_online),
                        label: const Text('Reservar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getSportIcon(String sport) {
    switch (sport.toLowerCase()) {
      case 'fútbol':
      case 'fútsal':
        return Icons.sports_soccer;
      case 'básquet':
        return Icons.sports_basketball;
      case 'vóley':
        return Icons.sports_volleyball;
      case 'tenis':
        return Icons.sports_tennis;
      default:
        return Icons.sports;
    }
  }

  void _bookSlot(Venue venue, TimeSlot slot) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Confirmar Reserva'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cancha: ${venue.name}'),
            Text('Fecha: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}'),
            Text('Horario: ${slot.startTime} - ${slot.endTime}'),
            Text('Precio: S/ ${slot.price}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _confirmBooking(venue, slot);
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void _confirmBooking(Venue venue, TimeSlot slot) {
    // Aquí iría la lógica de reserva
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('¡Reserva confirmada exitosamente!'),
        backgroundColor: Color(0xFF97FB57),
      ),
    );
  }

  void _showVenueDetails(Venue venue) {
    // Mostrar detalles completos de la cancha
  }

  void _showBookingModal(Venue venue) {
    // Mostrar modal de reserva completo
  }
}