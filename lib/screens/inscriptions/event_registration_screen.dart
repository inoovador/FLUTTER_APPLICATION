import 'package:flutter/material.dart';
import '../../models/event_model.dart';
import '../../models/inscription_model.dart';
import '../payment/payment_screen.dart';

class EventRegistrationScreen extends StatelessWidget {
  final EventModel event;
  
  const EventRegistrationScreen({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(event.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detalles del Evento',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Text(event.description),
                    const SizedBox(height: 16),
                    _buildDetailRow('Ubicación', event.location),
                    _buildDetailRow('Precio', 'S/ ${event.price.toStringAsFixed(2)}'),
                    _buildDetailRow('Cupos disponibles', '${event.spotsAvailable}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: event.isRegistrationOpen
                    ? () => _handleRegistration(context)
                    : null,
                child: Text(
                  event.isRegistrationOpen
                      ? 'Inscribirse Ahora'
                      : event.isFull
                          ? 'Sin Cupos'
                          : 'Inscripciones Cerradas',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _handleRegistration(BuildContext context) {
    // Crear inscripción temporal
    final inscription = InscriptionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'user1',
      eventId: event.id,
      eventName: event.name,
      inscriptionDate: DateTime.now(),
      status: 'pending',
      paymentStatus: 'pending',
      amount: event.price,
    );
    
    // Navegar a pago
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          inscription: inscription,
          organizerName: 'Torneos Deportivos',
          organizerYape: '932744546',
          onPaymentSuccess: (updatedInscription) {
            Navigator.pop(context);
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('¡Inscripción exitosa!'),
                backgroundColor: Colors.green,
              ),
            );
          },
        ),
      ),
    );
  }
}