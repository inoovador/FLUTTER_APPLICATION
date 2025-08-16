import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'create_tournament_screen.dart';
import 'payment_settings_screen.dart';
import 'tournament_detail_organizer_screen.dart';
import '../../models/tournament_model.dart';

class OrganizerDashboardScreen extends StatefulWidget {
  const OrganizerDashboardScreen({super.key});

  @override
  State<OrganizerDashboardScreen> createState() => _OrganizerDashboardScreenState();
}

class _OrganizerDashboardScreenState extends State<OrganizerDashboardScreen> {
  int _selectedIndex = 0;

  // Datos de ejemplo del organizador
  final String organizerName = "Academia Deportiva Juan";
  final String organizerYape = "932744546";
  
  // Torneos de ejemplo
  final List<TournamentModel> _tournaments = [
    TournamentModel(
      id: '1',
      organizerId: 'org1',
      organizerName: 'Academia Deportiva Juan',
      organizerYape: '932744546',
      name: 'Copa Verano 2024',
      description: 'Torneo relámpago de fútbol 7',
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
      description: 'Liga competitiva para jóvenes talentos',
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
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(_getAppBarTitle()),
          ],
        ),
        backgroundColor: const Color(0xFF121212),
        actions: [
          if (_selectedIndex == 0)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateTournamentScreen(),
                  ),
                );
              },
            ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF97FB57),
        unselectedItemColor: const Color(0xFF909090),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Torneos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Estadísticas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payment),
            label: 'Finanzas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Configuración',
          ),
        ],
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Mis Torneos';
      case 1:
        return 'Estadísticas';
      case 2:
        return 'Finanzas';
      case 3:
        return 'Configuración';
      default:
        return 'Dashboard Organizador';
    }
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildTournamentsTab();
      case 1:
        return _buildStatisticsTab();
      case 2:
        return _buildFinancesTab();
      case 3:
        return _buildSettingsTab();
      default:
        return const SizedBox();
    }
  }

  Widget _buildTournamentsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Resumen
          Row(
            children: [
              _buildSummaryCard(
                'Torneos Activos',
                _tournaments.where((t) => t.status == 'published').length.toString(),
                Icons.event_available,
                const Color(0xFF97FB57),
              ),
              const SizedBox(width: 12),
              _buildSummaryCard(
                'Total Inscritos',
                _tournaments.fold(0, (sum, t) => sum + t.registeredTeams).toString(),
                Icons.group,
                const Color(0xFF4ECDC4),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Lista de torneos
          Text(
            'Torneos Activos',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          
          ..._tournaments.map((tournament) => _buildTournamentCard(tournament)),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: const Color(0xFF909090),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTournamentCard(TournamentModel tournament) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final progress = tournament.registrationProgress;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TournamentDetailOrganizerScreen(
                tournament: tournament,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                        const SizedBox(height: 4),
                        Text(
                          '${tournament.sportDisplay} - ${tournament.categoryDisplay}',
                          style: TextStyle(
                            color: const Color(0xFF909090),
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
                      'Activo',
                      style: TextStyle(
                        color: const Color(0xFF97FB57),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
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
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.location_on, size: 16, color: Color(0xFF909090)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      tournament.location,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Progreso de inscripciones
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Equipos inscritos',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF909090)),
                      ),
                      Text(
                        '${tournament.registeredTeams}/${tournament.maxTeams}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: const Color(0xFF909090).withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      progress > 0.8 ? const Color(0xFFFF6B6B) : const Color(0xFF97FB57),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Ingresos estimados
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF97FB57).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Ingresos estimados:',
                      style: TextStyle(fontSize: 14),
                    ),
                    Text(
                      'S/ ${(tournament.registeredTeams * tournament.pricePerPlayer * 11).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF97FB57),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Estadísticas generales
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resumen General',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  _buildStatRow('Total de torneos organizados', '15'),
                  _buildStatRow('Jugadores totales', '1,245'),
                  _buildStatRow('Ingresos totales', 'S/ 62,250'),
                  _buildStatRow('Calificación promedio', '4.8 ⭐'),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Estadísticas del mes
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Este Mes',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  _buildStatRow('Torneos activos', '2'),
                  _buildStatRow('Nuevas inscripciones', '156'),
                  _buildStatRow('Ingresos del mes', 'S/ 7,800'),
                  _buildStatRow('Tasa de ocupación', '75%'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Balance
          Card(
            color: Colors.deepPurple,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Balance Disponible',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'S/ 5,670.00',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.deepPurple,
                    ),
                    child: const Text('Retirar Fondos'),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Últimas transacciones
          Text(
            'Últimas Transacciones',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          
          _buildTransactionItem(
            'Inscripción - Copa Verano',
            'Juan Pérez',
            50.0,
            DateTime.now().subtract(const Duration(hours: 2)),
          ),
          _buildTransactionItem(
            'Inscripción - Copa Verano',
            'María García',
            50.0,
            DateTime.now().subtract(const Duration(hours: 5)),
          ),
          _buildTransactionItem(
            'Inscripción - Liga Sub-17',
            'Carlos López',
            75.0,
            DateTime.now().subtract(const Duration(days: 1)),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(String title, String subtitle, double amount, DateTime date) {
    final dateFormat = DateFormat('dd/MM HH:mm');
    
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green[100],
          child: Icon(Icons.add, color: Colors.green[800]),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '+ S/ ${amount.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              dateFormat.format(date),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Información del organizador
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Información del Organizador',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.business),
                  title: const Text('Nombre del Negocio'),
                  subtitle: Text(organizerName),
                  contentPadding: EdgeInsets.zero,
                ),
                ListTile(
                  leading: const Icon(Icons.phone),
                  title: const Text('Yape'),
                  subtitle: Text(organizerYape),
                  contentPadding: EdgeInsets.zero,
                ),
                ListTile(
                  leading: const Icon(Icons.verified),
                  title: const Text('Estado'),
                  subtitle: const Text('Verificado'),
                  trailing: Icon(
                    Icons.check_circle,
                    color: Colors.green[600],
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Opciones
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.payment),
                title: const Text('Métodos de Pago'),
                subtitle: const Text('Configurar Yape, Plin, Bancos'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PaymentSettingsScreen(),
                    ),
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('Notificaciones'),
                subtitle: const Text('Configurar alertas'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {},
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.help),
                title: const Text('Ayuda y Soporte'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}