import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/tournament_model.dart';

class TournamentDetailOrganizerScreen extends StatefulWidget {
  final TournamentModel tournament;
  
  const TournamentDetailOrganizerScreen({
    super.key,
    required this.tournament,
  });

  @override
  State<TournamentDetailOrganizerScreen> createState() => _TournamentDetailOrganizerScreenState();
}

class _TournamentDetailOrganizerScreenState extends State<TournamentDetailOrganizerScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Lista de inscritos de ejemplo
  final List<Map<String, dynamic>> _registrations = [
    {
      'teamName': 'Los Galácticos',
      'captain': 'Pedro Martínez',
      'phone': '987654321',
      'players': 11,
      'paymentStatus': 'paid',
      'paymentDate': DateTime.now().subtract(const Duration(days: 1)),
      'amount': 550.0,
    },
    {
      'teamName': 'Real Juventud',
      'captain': 'Carlos Rodríguez',
      'phone': '912345678',
      'players': 11,
      'paymentStatus': 'paid',
      'paymentDate': DateTime.now().subtract(const Duration(days: 2)),
      'amount': 550.0,
    },
    {
      'teamName': 'Deportivo Unidos',
      'captain': 'Luis Fernández',
      'phone': '923456789',
      'players': 11,
      'paymentStatus': 'pending',
      'paymentDate': null,
      'amount': 550.0,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tournament.name),
        backgroundColor: Colors.deepPurple,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Información'),
            Tab(text: 'Inscritos'),
            Tab(text: 'Finanzas'),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  // TODO: Editar torneo
                  break;
                case 'cancel':
                  _showCancelDialog();
                  break;
                case 'share':
                  // TODO: Compartir torneo
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Text('Editar torneo'),
              ),
              const PopupMenuItem(
                value: 'share',
                child: Text('Compartir'),
              ),
              const PopupMenuItem(
                value: 'cancel',
                child: Text('Cancelar torneo'),
              ),
            ],
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInfoTab(),
          _buildRegistrationsTab(),
          _buildFinancesTab(),
        ],
      ),
    );
  }

  Widget _buildInfoTab() {
    final dateFormat = DateFormat('EEEE, dd \'de\' MMMM \'de\' yyyy', 'es');
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Estado del torneo
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Estado del Torneo',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Activo',
                          style: TextStyle(
                            color: Colors.green[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Progreso de inscripciones
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Equipos inscritos'),
                          Text(
                            '${widget.tournament.registeredTeams}/${widget.tournament.maxTeams}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: widget.tournament.registrationProgress,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          widget.tournament.registrationProgress > 0.8 
                              ? Colors.orange 
                              : Colors.green,
                        ),
                      ),
                      if (widget.tournament.registrationProgress > 0.8)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '¡Casi lleno! Solo ${widget.tournament.maxTeams - widget.tournament.registeredTeams} cupos disponibles',
                            style: TextStyle(
                              color: Colors.orange[700],
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Detalles del torneo
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detalles del Torneo',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  
                  _buildDetailRow(
                    Icons.sports_soccer,
                    'Deporte',
                    '${widget.tournament.sportDisplay} - ${widget.tournament.categoryDisplay}',
                  ),
                  _buildDetailRow(
                    Icons.calendar_today,
                    'Fecha',
                    dateFormat.format(widget.tournament.date),
                  ),
                  _buildDetailRow(
                    Icons.access_time,
                    'Hora',
                    '8:00 AM - 6:00 PM',
                  ),
                  _buildDetailRow(
                    Icons.location_on,
                    'Ubicación',
                    widget.tournament.location,
                  ),
                  _buildDetailRow(
                    Icons.attach_money,
                    'Precio por jugador',
                    'S/ ${widget.tournament.pricePerPlayer.toStringAsFixed(2)}',
                  ),
                  _buildDetailRow(
                    Icons.group,
                    'Jugadores por equipo',
                    '11 jugadores',
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Código QR para compartir
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Compartir Torneo',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.qr_code_2,
                        size: 150,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Código del torneo: ${widget.tournament.id}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.share),
                        label: const Text('Compartir'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.download),
                        label: const Text('Descargar QR'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegistrationsTab() {
    final paidRegistrations = _registrations.where((r) => r['paymentStatus'] == 'paid').toList();
    final pendingRegistrations = _registrations.where((r) => r['paymentStatus'] == 'pending').toList();
    
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: Colors.grey[100],
            child: TabBar(
              labelColor: Colors.deepPurple,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.deepPurple,
              tabs: [
                Tab(text: 'Confirmados (${paidRegistrations.length})'),
                Tab(text: 'Pendientes (${pendingRegistrations.length})'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildRegistrationsList(paidRegistrations),
                _buildRegistrationsList(pendingRegistrations),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegistrationsList(List<Map<String, dynamic>> registrations) {
    if (registrations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No hay inscripciones',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: registrations.length,
      itemBuilder: (context, index) {
        final registration = registrations[index];
        return _buildRegistrationCard(registration);
      },
    );
  }

  Widget _buildRegistrationCard(Map<String, dynamic> registration) {
    final isPaid = registration['paymentStatus'] == 'paid';
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: isPaid ? Colors.green[100] : Colors.orange[100],
          child: Icon(
            isPaid ? Icons.check : Icons.pending,
            color: isPaid ? Colors.green[800] : Colors.orange[800],
          ),
        ),
        title: Text(
          registration['teamName'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Capitán: ${registration['captain']}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'S/ ${registration['amount'].toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isPaid ? Colors.green : Colors.orange,
              ),
            ),
            if (isPaid && registration['paymentDate'] != null)
              Text(
                dateFormat.format(registration['paymentDate']),
                style: const TextStyle(fontSize: 10),
              ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Teléfono: ${registration['phone']}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        Text(
                          'Jugadores: ${registration['players']}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    if (!isPaid)
                      Row(
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              _showConfirmPaymentDialog(registration);
                            },
                            icon: const Icon(Icons.check, size: 18),
                            label: const Text('Confirmar Pago'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.green,
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.message),
                            color: Colors.blue,
                            tooltip: 'Enviar recordatorio',
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
    );
  }

  Widget _buildFinancesTab() {
    final totalRevenue = _registrations
        .where((r) => r['paymentStatus'] == 'paid')
        .fold(0.0, (sum, r) => sum + r['amount']);
    final pendingRevenue = _registrations
        .where((r) => r['paymentStatus'] == 'pending')
        .fold(0.0, (sum, r) => sum + r['amount']);
    final commission = totalRevenue * 0.1; // 10% de comisión
    final netRevenue = totalRevenue - commission;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Resumen financiero
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resumen Financiero',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  
                  _buildFinanceRow(
                    'Ingresos confirmados',
                    'S/ ${totalRevenue.toStringAsFixed(2)}',
                    Colors.green,
                  ),
                  _buildFinanceRow(
                    'Pagos pendientes',
                    'S/ ${pendingRevenue.toStringAsFixed(2)}',
                    Colors.orange,
                  ),
                  const Divider(height: 24),
                  _buildFinanceRow(
                    'Total esperado',
                    'S/ ${(totalRevenue + pendingRevenue).toStringAsFixed(2)}',
                    Colors.blue,
                    isBold: true,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Desglose de comisiones
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Desglose de Comisiones',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  
                  _buildFinanceRow(
                    'Ingresos brutos',
                    'S/ ${totalRevenue.toStringAsFixed(2)}',
                    null,
                  ),
                  _buildFinanceRow(
                    'Comisión plataforma (10%)',
                    '- S/ ${commission.toStringAsFixed(2)}',
                    Colors.red,
                  ),
                  const Divider(height: 24),
                  _buildFinanceRow(
                    'Ingreso neto',
                    'S/ ${netRevenue.toStringAsFixed(2)}',
                    Colors.green,
                    isBold: true,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Métodos de cobro
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Métodos de Cobro Configurados',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF722E82).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.phone_android,
                        color: Color(0xFF722E82),
                      ),
                    ),
                    title: const Text('Yape'),
                    subtitle: Text(widget.tournament.organizerYape),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinanceRow(String label, String value, Color? color, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showConfirmPaymentDialog(Map<String, dynamic> registration) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Pago'),
          content: Text(
            '¿Confirmar el pago de S/ ${registration['amount'].toStringAsFixed(2)} del equipo ${registration['teamName']}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: Actualizar estado del pago
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pago confirmado exitosamente'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancelar Torneo'),
          content: const Text(
            '¿Estás seguro de que quieres cancelar este torneo? Se notificará a todos los inscritos y se procesarán los reembolsos.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('No, mantener'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Cancelar torneo
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Torneo cancelado'),
                    backgroundColor: Colors.red,
                  ),
                );
                Navigator.of(context).pop();
              },
              child: const Text(
                'Sí, cancelar',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}