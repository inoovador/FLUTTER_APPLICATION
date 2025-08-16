import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/inscription_model.dart';
import 'inscription_detail_screen.dart';
import 'available_events_screen.dart';
import '../payment/payment_screen.dart';

class InscriptionsListScreen extends StatefulWidget {
  const InscriptionsListScreen({super.key});

  @override
  State<InscriptionsListScreen> createState() => InscriptionsListScreenState();
}

class InscriptionsListScreenState extends State<InscriptionsListScreen> {
  List<InscriptionModel> _inscriptions = _generateMockInscriptions();

  void _updateInscription(InscriptionModel updatedInscription) {
    setState(() {
      final index = _inscriptions.indexWhere((i) => i.id == updatedInscription.id);
      if (index != -1) {
        _inscriptions[index] = updatedInscription;
      }
    });
  }

  static List<InscriptionModel> _generateMockInscriptions() {
    return [
      InscriptionModel(
        id: '1',
        userId: 'user1',
        eventId: 'event1',
        eventName: 'Torneo de Verano 2024',
        inscriptionDate: DateTime.now().subtract(const Duration(days: 5)),
        status: 'confirmed',
        paymentStatus: 'paid',
        amount: 50.0,
        paymentDate: DateTime.now().subtract(const Duration(days: 4)),
        paymentMethod: 'tarjeta',
      ),
      InscriptionModel(
        id: '2',
        userId: 'user1',
        eventId: 'event2',
        eventName: 'Copa Relámpago',
        inscriptionDate: DateTime.now().subtract(const Duration(days: 2)),
        status: 'pending',
        paymentStatus: 'pending',
        amount: 30.0,
      ),
      InscriptionModel(
        id: '3',
        userId: 'user1',
        eventId: 'event3',
        eventName: 'Liga Amateur 2024',
        inscriptionDate: DateTime.now().subtract(const Duration(days: 10)),
        status: 'confirmed',
        paymentStatus: 'paid',
        amount: 75.0,
        paymentDate: DateTime.now().subtract(const Duration(days: 9)),
        paymentMethod: 'transferencia',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _inscriptions.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _inscriptions.length,
              itemBuilder: (context, index) {
                final inscription = _inscriptions[index];
                return _buildInscriptionCard(inscription);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AvailableEventsScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Nueva Inscripción'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No tienes inscripciones',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Inscríbete a un torneo para empezar',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInscriptionCard(InscriptionModel inscription) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InscriptionDetailScreen(
                inscription: inscription,
                onPaymentSuccess: _updateInscription,
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
                    child: Text(
                      inscription.eventName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildStatusChip(inscription),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Inscrito el ${dateFormat.format(inscription.inscriptionDate)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
                      Text(
                        'S/ ${inscription.amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  _buildPaymentStatus(inscription),
                ],
              ),
              if (inscription.isPending) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentScreen(
                            inscription: inscription,
                            onPaymentSuccess: _updateInscription,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('Pagar Ahora'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(InscriptionModel inscription) {
    Color backgroundColor;
    Color textColor;
    String text;

    switch (inscription.status) {
      case 'confirmed':
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        text = 'Confirmado';
        break;
      case 'pending':
        backgroundColor = Colors.orange[100]!;
        textColor = Colors.orange[800]!;
        text = 'Pendiente';
        break;
      case 'cancelled':
        backgroundColor = Colors.red[100]!;
        textColor = Colors.red[800]!;
        text = 'Cancelado';
        break;
      default:
        backgroundColor = Colors.grey[100]!;
        textColor = Colors.grey[800]!;
        text = inscription.status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildPaymentStatus(InscriptionModel inscription) {
    if (inscription.isPaid) {
      return Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green[600], size: 20),
          const SizedBox(width: 4),
          Text(
            'Pagado',
            style: TextStyle(
              color: Colors.green[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Icon(Icons.pending, color: Colors.orange[600], size: 20),
          const SizedBox(width: 4),
          Text(
            'Pago pendiente',
            style: TextStyle(
              color: Colors.orange[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }
  }
}