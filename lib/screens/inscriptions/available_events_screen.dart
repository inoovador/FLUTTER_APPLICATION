import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/event_model.dart';
import 'event_registration_screen.dart';

class AvailableEventsScreen extends StatefulWidget {
  const AvailableEventsScreen({super.key});

  @override
  State<AvailableEventsScreen> createState() => AvailableEventsScreenState();
}

class AvailableEventsScreenState extends State<AvailableEventsScreen> {
  final List<EventModel> _events = _generateMockEvents();
  String _selectedCategory = 'Todos';

  static List<EventModel> _generateMockEvents() {
    return [
      EventModel(
        id: '1',
        name: 'Torneo de Verano 2024',
        description: 'El torneo más esperado del año con premios increíbles',
        startDate: DateTime.now().add(const Duration(days: 30)),
        endDate: DateTime.now().add(const Duration(days: 35)),
        registrationDeadline: DateTime.now().add(const Duration(days: 20)),
        price: 50.0,
        maxParticipants: 32,
        currentParticipants: 24,
        location: 'Estadio Municipal',
        imageUrl: '',
        status: 'upcoming',
        categories: ['Amateur', 'Senior'],
      ),
      EventModel(
        id: '2',
        name: 'Copa Relámpago',
        description: 'Torneo rápido de un día, mucha acción garantizada',
        startDate: DateTime.now().add(const Duration(days: 7)),
        endDate: DateTime.now().add(const Duration(days: 7)),
        registrationDeadline: DateTime.now().add(const Duration(days: 5)),
        price: 30.0,
        maxParticipants: 16,
        currentParticipants: 12,
        location: 'Canchas Norte',
        imageUrl: '',
        status: 'upcoming',
        categories: ['Amateur'],
      ),
      EventModel(
        id: '3',
        name: 'Liga Amateur 2024',
        description: 'Liga completa con sistema de todos contra todos',
        startDate: DateTime.now().add(const Duration(days: 45)),
        endDate: DateTime.now().add(const Duration(days: 120)),
        registrationDeadline: DateTime.now().add(const Duration(days: 30)),
        price: 75.0,
        maxParticipants: 20,
        currentParticipants: 20,
        location: 'Varios',
        imageUrl: '',
        status: 'upcoming',
        categories: ['Amateur', 'Profesional'],
      ),
      EventModel(
        id: '4',
        name: 'Torneo Juvenil Sub-18',
        description: 'Competencia exclusiva para jóvenes talentos',
        startDate: DateTime.now().add(const Duration(days: 15)),
        endDate: DateTime.now().add(const Duration(days: 17)),
        registrationDeadline: DateTime.now().add(const Duration(days: 10)),
        price: 25.0,
        maxParticipants: 24,
        currentParticipants: 18,
        location: 'Centro Deportivo',
        imageUrl: '',
        status: 'upcoming',
        categories: ['Juvenil'],
      ),
    ];
  }

  List<String> get _categories {
    final categories = {'Todos'};
    for (var event in _events) {
      categories.addAll(event.categories);
    }
    return categories.toList()..sort();
  }

  List<EventModel> get _filteredEvents {
    if (_selectedCategory == 'Todos') {
      return _events;
    }
    return _events
        .where((event) => event.categories.contains(_selectedCategory))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eventos Disponibles'),
      ),
      body: Column(
        children: [
          _buildCategoryFilter(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredEvents.length,
              itemBuilder: (context, index) {
                return _buildEventCard(_filteredEvents[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                });
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEventCard(EventModel event) {
    final dateFormat = DateFormat('dd MMM yyyy');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventRegistrationScreen(event: event),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  event.imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: const Icon(Icons.sports_soccer, size: 80),
                    );
                  },
                ),
              )
            else
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.6),
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.sports_soccer,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          event.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (event.isFull)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'LLENO',
                            style: TextStyle(
                              color: Colors.red[800],
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${dateFormat.format(event.startDate)} - ${dateFormat.format(event.endDate)}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        event.location,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            'S/ ${event.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const Text(
                            ' / jugador',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.people, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            '${event.currentParticipants}/${event.maxParticipants}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (event.isRegistrationOpen) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.timer, size: 16, color: Colors.orange[600]),
                        const SizedBox(width: 4),
                        Text(
                          'Inscripciones hasta ${dateFormat.format(event.registrationDeadline)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: event.categories.map((category) {
                      return Chip(
                        label: Text(
                          category,
                          style: const TextStyle(fontSize: 12),
                        ),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}