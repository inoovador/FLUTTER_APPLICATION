import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/tournament_model.dart';
import '../../services/tournament_service.dart';

class AdvancedSearchScreen extends StatefulWidget {
  const AdvancedSearchScreen({super.key});

  @override
  State<AdvancedSearchScreen> createState() => _AdvancedSearchScreenState();
}

class _AdvancedSearchScreenState extends State<AdvancedSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TournamentService _tournamentService = TournamentService();
  
  List<Tournament> _searchResults = [];
  bool _isSearching = false;
  
  // Filtros
  String? _selectedSport;
  String? _selectedCategory;
  String? _selectedLocation;
  RangeValues _priceRange = const RangeValues(0, 500);
  DateTime? _startDate;
  DateTime? _endDate;
  int _maxDistance = 50; // km
  bool _onlyAvailable = true;
  
  final List<String> _sports = [
    'Fútbol',
    'Básquet',
    'Vóley',
    'Tenis',
    'Ping Pong',
    'Fútsal',
  ];
  
  final List<String> _categories = [
    'Principiante',
    'Intermedio',
    'Avanzado',
    'Profesional',
    'Amateur',
    'Juvenil',
  ];
  
  final List<String> _locations = [
    'Lima Norte',
    'Lima Sur', 
    'Lima Este',
    'Lima Centro',
    'Callao',
    'San Isidro',
    'Miraflores',
    'Surco',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    setState(() => _isSearching = true);
    
    try {
      final results = await _tournamentService.searchTournaments(
        query: _searchController.text,
        sport: _selectedSport,
        category: _selectedCategory,
        location: _selectedLocation,
        minPrice: _priceRange.start,
        maxPrice: _priceRange.end,
        startDate: _startDate,
        endDate: _endDate,
        maxDistance: _maxDistance,
        onlyAvailable: _onlyAvailable,
      );
      
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() => _isSearching = false);
      _showError('Error en la búsqueda');
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedSport = null;
      _selectedCategory = null;
      _selectedLocation = null;
      _priceRange = const RangeValues(0, 500);
      _startDate = null;
      _endDate = null;
      _maxDistance = 50;
      _onlyAvailable = true;
      _searchResults.clear();
    });
    _searchController.clear();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFFF6B6B),
      ),
    );
  }

  Future<void> _selectDate(bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
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
    
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Búsqueda Avanzada'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: _clearFilters,
            tooltip: 'Limpiar filtros',
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda principal
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar torneos...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.tune),
                  onPressed: _showFiltersModal,
                ),
                filled: true,
                fillColor: const Color(0xFF1A1A1A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _performSearch(),
            ),
          ),
          
          // Chips de filtros activos
          if (_hasActiveFilters()) _buildActiveFiltersChips(),
          
          // Botón de búsqueda
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _performSearch,
                icon: _isSearching
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF121212),
                        ),
                      )
                    : const Icon(Icons.search),
                label: Text(_isSearching ? 'Buscando...' : 'Buscar'),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Resultados
          Expanded(
            child: _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFiltersChips() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          if (_selectedSport != null)
            _buildFilterChip('Deporte: $_selectedSport', () {
              setState(() => _selectedSport = null);
            }),
          if (_selectedCategory != null)
            _buildFilterChip('Categoría: $_selectedCategory', () {
              setState(() => _selectedCategory = null);
            }),
          if (_selectedLocation != null)
            _buildFilterChip('Ubicación: $_selectedLocation', () {
              setState(() => _selectedLocation = null);
            }),
          if (_startDate != null)
            _buildFilterChip('Desde: ${DateFormat('dd/MM').format(_startDate!)}', () {
              setState(() => _startDate = null);
            }),
          if (_endDate != null)
            _buildFilterChip('Hasta: ${DateFormat('dd/MM').format(_endDate!)}', () {
              setState(() => _endDate = null);
            }),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onRemove) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(label),
        onDeleted: onRemove,
        deleteIcon: const Icon(Icons.close, size: 18),
        backgroundColor: const Color(0xFF97FB57).withOpacity(0.2),
        deleteIconColor: const Color(0xFF97FB57),
        labelStyle: const TextStyle(color: Color(0xFF97FB57)),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty && !_isSearching) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: const Color(0xFF909090).withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Sin resultados',
              style: TextStyle(
                fontSize: 18,
                color: const Color(0xFF909090).withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Intenta ajustar los filtros de búsqueda',
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFF909090).withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final tournament = _searchResults[index];
        return _buildTournamentCard(tournament);
      },
    );
  }

  Widget _buildTournamentCard(Tournament tournament) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          // Navegar a detalles del torneo
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF97FB57).withOpacity(0.8),
                          const Color(0xFF97FB57).withOpacity(0.4),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.sports_soccer,
                      color: Color(0xFF121212),
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tournament.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          tournament.organizerName,
                          style: const TextStyle(
                            color: Color(0xFF909090),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF97FB57).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'S/ ${tournament.pricePerPlayer.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Color(0xFF97FB57),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Color(0xFF909090)),
                  const SizedBox(width: 4),
                  Text(
                    tournament.location,
                    style: const TextStyle(
                      color: Color(0xFF909090),
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.group, size: 16, color: Color(0xFF909090)),
                  const SizedBox(width: 4),
                  Text(
                    '${tournament.maxTeams - tournament.registeredTeams} cupos',
                    style: const TextStyle(
                      color: Color(0xFF909090),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFiltersModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => _buildFiltersContent(scrollController),
      ),
    );
  }

  Widget _buildFiltersContent(ScrollController scrollController) {
    return StatefulBuilder(
      builder: (context, setModalState) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 50,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF909090),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            Text(
              'Filtros de Búsqueda',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            
            Expanded(
              child: ListView(
                controller: scrollController,
                children: [
                  // Deporte
                  _buildFilterSection(
                    'Deporte',
                    DropdownButton<String>(
                      value: _selectedSport,
                      hint: const Text('Seleccionar deporte'),
                      isExpanded: true,
                      dropdownColor: const Color(0xFF2A2A2A),
                      items: _sports.map((sport) {
                        return DropdownMenuItem(
                          value: sport,
                          child: Text(sport),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setModalState(() => _selectedSport = value);
                        setState(() => _selectedSport = value);
                      },
                    ),
                  ),
                  
                  // Categoría
                  _buildFilterSection(
                    'Categoría',
                    DropdownButton<String>(
                      value: _selectedCategory,
                      hint: const Text('Seleccionar categoría'),
                      isExpanded: true,
                      dropdownColor: const Color(0xFF2A2A2A),
                      items: _categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setModalState(() => _selectedCategory = value);
                        setState(() => _selectedCategory = value);
                      },
                    ),
                  ),
                  
                  // Ubicación
                  _buildFilterSection(
                    'Ubicación',
                    DropdownButton<String>(
                      value: _selectedLocation,
                      hint: const Text('Seleccionar ubicación'),
                      isExpanded: true,
                      dropdownColor: const Color(0xFF2A2A2A),
                      items: _locations.map((location) {
                        return DropdownMenuItem(
                          value: location,
                          child: Text(location),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setModalState(() => _selectedLocation = value);
                        setState(() => _selectedLocation = value);
                      },
                    ),
                  ),
                  
                  // Rango de precios
                  _buildFilterSection(
                    'Precio (S/ ${_priceRange.start.round()} - S/ ${_priceRange.end.round()})',
                    RangeSlider(
                      values: _priceRange,
                      min: 0,
                      max: 500,
                      divisions: 10,
                      activeColor: const Color(0xFF97FB57),
                      onChanged: (values) {
                        setModalState(() => _priceRange = values);
                        setState(() => _priceRange = values);
                      },
                    ),
                  ),
                  
                  // Fechas
                  _buildFilterSection(
                    'Fecha de inicio',
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _selectDate(true),
                            icon: const Icon(Icons.calendar_today),
                            label: Text(
                              _startDate != null
                                  ? DateFormat('dd/MM/yyyy').format(_startDate!)
                                  : 'Seleccionar fecha',
                            ),
                          ),
                        ),
                        if (_startDate != null) ...[
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () {
                              setModalState(() => _startDate = null);
                              setState(() => _startDate = null);
                            },
                            icon: const Icon(Icons.clear, color: Color(0xFF909090)),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  _buildFilterSection(
                    'Fecha de fin',
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _selectDate(false),
                            icon: const Icon(Icons.calendar_today),
                            label: Text(
                              _endDate != null
                                  ? DateFormat('dd/MM/yyyy').format(_endDate!)
                                  : 'Seleccionar fecha',
                            ),
                          ),
                        ),
                        if (_endDate != null) ...[
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () {
                              setModalState(() => _endDate = null);
                              setState(() => _endDate = null);
                            },
                            icon: const Icon(Icons.clear, color: Color(0xFF909090)),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // Distancia máxima
                  _buildFilterSection(
                    'Distancia máxima: $_maxDistance km',
                    Slider(
                      value: _maxDistance.toDouble(),
                      min: 5,
                      max: 100,
                      divisions: 19,
                      activeColor: const Color(0xFF97FB57),
                      onChanged: (value) {
                        setModalState(() => _maxDistance = value.round());
                        setState(() => _maxDistance = value.round());
                      },
                    ),
                  ),
                  
                  // Solo disponibles
                  _buildFilterSection(
                    'Opciones adicionales',
                    CheckboxListTile(
                      title: const Text('Solo torneos disponibles'),
                      value: _onlyAvailable,
                      activeColor: const Color(0xFF97FB57),
                      onChanged: (value) {
                        setModalState(() => _onlyAvailable = value ?? true);
                        setState(() => _onlyAvailable = value ?? true);
                      },
                    ),
                  ),
                ],
              ),
            ),
            
            // Botones
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _clearFilters();
                      Navigator.pop(context);
                    },
                    child: const Text('Limpiar'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _performSearch();
                    },
                    child: const Text('Aplicar Filtros'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection(String title, Widget content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          content,
        ],
      ),
    );
  }

  bool _hasActiveFilters() {
    return _selectedSport != null ||
           _selectedCategory != null ||
           _selectedLocation != null ||
           _startDate != null ||
           _endDate != null ||
           _priceRange.start > 0 ||
           _priceRange.end < 500 ||
           _maxDistance < 50 ||
           !_onlyAvailable;
  }
}