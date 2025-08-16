import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/inscription_model.dart';
import '../payment/payment_screen.dart';

class InscriptionDetailScreen extends StatelessWidget {
  final InscriptionModel inscription;
  final Function(InscriptionModel)? onPaymentSuccess;

  const InscriptionDetailScreen({
    super.key,
    required this.inscription,
    this.onPaymentSuccess,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Inscripción'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Descargando comprobante...'),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            _buildInfoSection(context, dateFormat, timeFormat),
            if (inscription.isPaid) _buildPaymentSection(context, dateFormat),
            _buildActionsSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            inscription.eventName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildStatusBadge(),
              const SizedBox(width: 12),
              _buildPaymentBadge(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color backgroundColor;
    String text;

    switch (inscription.status) {
      case 'confirmed':
        backgroundColor = Colors.green;
        text = 'Confirmado';
        break;
      case 'pending':
        backgroundColor = Colors.orange;
        text = 'Pendiente';
        break;
      case 'cancelled':
        backgroundColor = Colors.red;
        text = 'Cancelado';
        break;
      default:
        backgroundColor = Colors.grey;
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
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildPaymentBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: inscription.isPaid ? Colors.green : Colors.orange,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            inscription.isPaid ? Icons.check : Icons.pending,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            inscription.isPaid ? 'Pagado' : 'Pago pendiente',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, DateFormat dateFormat, DateFormat timeFormat) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Información de la Inscripción',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.confirmation_number,
            'ID de Inscripción',
            inscription.id,
          ),
          _buildInfoRow(
            Icons.calendar_today,
            'Fecha de Inscripción',
            dateFormat.format(inscription.inscriptionDate),
          ),
          _buildInfoRow(
            Icons.attach_money,
            'Monto',
            'S/ ${inscription.amount.toStringAsFixed(2)}',
          ),
          if (inscription.teamId != null)
            _buildInfoRow(
              Icons.group,
              'Equipo',
              'Equipo #${inscription.teamId}',
            ),
        ],
      ),
    );
  }

  Widget _buildPaymentSection(BuildContext context, DateFormat dateFormat) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Información de Pago',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.payment,
            'Método de Pago',
            inscription.paymentMethod ?? 'No especificado',
          ),
          if (inscription.paymentDate != null)
            _buildInfoRow(
              Icons.date_range,
              'Fecha de Pago',
              dateFormat.format(inscription.paymentDate!),
            ),
          if (inscription.transactionId != null)
            _buildInfoRow(
              Icons.receipt,
              'ID de Transacción',
              inscription.transactionId!,
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          if (inscription.isPending) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentScreen(
                        inscription: inscription,
                        onPaymentSuccess: (updatedInscription) {
                          onPaymentSuccess?.call(updatedInscription);
                        },
                      ),
                    ),
                  );
                  
                  if (result == true && context.mounted) {
                    Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.payment),
                label: const Text('Realizar Pago'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (inscription.isPaid) ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Descargando comprobante de pago...'),
                    ),
                  );
                },
                icon: const Icon(Icons.download),
                label: const Text('Descargar Comprobante'),
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (inscription.status != 'cancelled' && inscription.isPending) ...[
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () {
                  _showCancelDialog(context);
                },
                icon: const Icon(Icons.cancel, color: Colors.red),
                label: const Text(
                  'Cancelar Inscripción',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancelar Inscripción'),
          content: const Text(
            '¿Estás seguro de que quieres cancelar esta inscripción? Esta acción no se puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('No, mantener'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Inscripción cancelada'),
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