import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/tournament_model.dart';
import '../../models/inscription_model.dart';
import '../payment/payment_screen.dart';

class TournamentDetailPlayerScreen extends StatelessWidget {
  final TournamentModel tournament;
  
  const TournamentDetailPlayerScreen({
    super.key,
    required this.tournament,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, dd \'de\' MMMM \'de\' yyyy', 'es');
    final daysUntil = tournament.date.difference(DateTime.now()).inDays;
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar con imagen
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                tournament.name,
                style: const TextStyle(
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3.0,
                      color: Colors.black54,
                    ),
                  ],
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getSportColor(tournament.sport),
                      _getSportColor(tournament.sport).withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        _getSportIcon(tournament.sport),
                        size: 150,
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                    Positioned(
                      bottom: 60,
                      left: 16,
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
                            color: _getSportColor(tournament.sport),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Contenido
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card de información principal
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Organizador
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.grey[200],
                                child: Icon(
                                  Icons.business,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Organizado por',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      tournament.organizerName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.verified,
                                color: Colors.green[600],
                              ),
                            ],
                          ),
                          
                          const Divider(height: 24),
                          
                          // Descripción
                          Text(
                            'Acerca del torneo',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            tournament.description,
                            style: TextStyle(
                              color: Colors.grey[700],
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Detalles del evento
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Detalles del Evento',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),
                          
                          _buildDetailItem(
                            Icons.calendar_today,
                            'Fecha',
                            dateFormat.format(tournament.date),
                            subtitle: 'En $daysUntil días',
                          ),
                          _buildDetailItem(
                            Icons.access_time,
                            'Horario',
                            '8:00 AM - 6:00 PM',
                            subtitle: 'Horario tentativo',
                          ),
                          _buildDetailItem(
                            Icons.location_on,
                            'Ubicación',
                            tournament.location,
                            isLast: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Información de inscripción
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Inscripción',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),
                          
                          // Precio
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Precio por jugador',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'S/ ${tournament.pricePerPlayer.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text(
                                      'Total equipo (11 jugadores)',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      'S/ ${(tournament.pricePerPlayer * 11).toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Disponibilidad
                          Row(
                            children: [
                              Icon(
                                Icons.group,
                                color: tournament.registrationProgress > 0.8
                                    ? Colors.orange
                                    : Colors.blue,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${tournament.registeredTeams} de ${tournament.maxTeams} equipos inscritos',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    LinearProgressIndicator(
                                      value: tournament.registrationProgress,
                                      backgroundColor: Colors.grey[300],
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        tournament.registrationProgress > 0.8
                                            ? Colors.orange
                                            : Colors.blue,
                                      ),
                                    ),
                                    if (tournament.registrationProgress > 0.8)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          '¡Últimos ${tournament.maxTeams - tournament.registeredTeams} cupos!',
                                          style: TextStyle(
                                            color: Colors.orange[700],
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Métodos de pago aceptados
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Métodos de Pago Aceptados',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            runSpacing: 8,
                            children: [
                              _buildPaymentMethodChip('Yape', const Color(0xFF722E82)),
                              _buildPaymentMethodChip('Visa', Colors.blue),
                              _buildPaymentMethodChip('Mastercard', Colors.orange),
                              _buildPaymentMethodChip('Transferencia', Colors.grey),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      
      // Botón flotante de inscripción
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(0, -2),
                blurRadius: 8,
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: tournament.hasAvailableSpots
                ? () => _handleInscription(context)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              tournament.hasAvailableSpots
                  ? 'Inscribir mi Equipo'
                  : 'Sin Cupos Disponibles',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(
    IconData icon,
    String label,
    String value, {
    String? subtitle,
    bool isLast = false,
  }) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        if (!isLast) const Divider(height: 24),
      ],
    );
  }

  Widget _buildPaymentMethodChip(String label, Color color) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(fontSize: 12),
      ),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color.withOpacity(0.3)),
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  void _handleInscription(BuildContext context) {
    // Crear inscripción temporal
    final inscription = InscriptionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'user1',
      eventId: tournament.id,
      eventName: tournament.name,
      inscriptionDate: DateTime.now(),
      status: 'pending',
      paymentStatus: 'pending',
      amount: tournament.pricePerPlayer * 11, // Precio por equipo completo
    );
    
    // Navegar directo a pago con datos del organizador
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          inscription: inscription,
          organizerName: tournament.organizerName,
          organizerYape: tournament.organizerYape,
          onPaymentSuccess: (updatedInscription) {
            // Mostrar confirmación
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('¡Inscripción exitosa! El organizador confirmará tu pago.'),
                backgroundColor: Colors.green,
              ),
            );
            // Volver a inicio
            Navigator.popUntil(context, (route) => route.isFirst);
          },
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