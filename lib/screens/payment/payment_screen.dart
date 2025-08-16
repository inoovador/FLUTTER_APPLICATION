import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
// import 'package:qr_flutter/qr_flutter.dart';
import '../../models/inscription_model.dart';
import '../../services/payment_service.dart';
import 'payment_history_screen.dart';

class PaymentScreen extends StatefulWidget {
  final InscriptionModel inscription;
  final Function(InscriptionModel)? onPaymentSuccess;
  final String? organizerName;
  final String? organizerYape;
  
  const PaymentScreen({
    super.key,
    required this.inscription,
    this.onPaymentSuccess,
    this.organizerName,
    this.organizerYape,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _phoneController = TextEditingController();
  final _operationController = TextEditingController();
  
  bool _isProcessing = false;
  String _selectedPaymentMethod = 'yape';
  bool _saveCard = false;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _phoneController.dispose();
    _operationController.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    final paymentService = Provider.of<PaymentService>(context, listen: false);
    
    // Validar formulario según método de pago
    if ((_selectedPaymentMethod == 'visa' || _selectedPaymentMethod == 'mastercard') && 
        !_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isProcessing = true);

    try {
      Payment? payment;
      
      switch (_selectedPaymentMethod) {
        case 'yape':
          payment = await paymentService.processYapePayment(
            tournamentId: widget.inscription.eventId,
            amount: widget.inscription.amount,
            phoneNumber: _phoneController.text.isNotEmpty ? _phoneController.text : '987654321',
          );
          break;
          
        case 'visa':
        case 'mastercard':
          payment = await paymentService.processCardPayment(
            tournamentId: widget.inscription.eventId,
            amount: widget.inscription.amount,
            cardNumber: _cardNumberController.text,
            cardHolder: _cardHolderController.text,
            expiryDate: _expiryController.text,
            cvv: _cvvController.text,
            saveCard: _saveCard,
          );
          break;
          
        case 'plin':
          payment = await paymentService.processPlinPayment(
            tournamentId: widget.inscription.eventId,
            amount: widget.inscription.amount,
            phoneNumber: _phoneController.text.isNotEmpty ? _phoneController.text : '987654321',
          );
          break;
      }
      
      if (payment != null && mounted) {
        // Actualizar el estado de la inscripción
        final updatedInscription = InscriptionModel(
          id: widget.inscription.id,
          userId: widget.inscription.userId,
          eventId: widget.inscription.eventId,
          eventName: widget.inscription.eventName,
          inscriptionDate: widget.inscription.inscriptionDate,
          status: 'confirmed',
          paymentStatus: payment.status == 'completed' ? 'paid' : 'pending',
          amount: widget.inscription.amount,
          paymentDate: DateTime.now(),
          paymentMethod: _selectedPaymentMethod,
          teamId: widget.inscription.teamId,
          transactionId: payment.transactionId,
        );
        
        // Llamar al callback si existe
        widget.onPaymentSuccess?.call(updatedInscription);
        
        // Mostrar diálogo de éxito
        _showSuccessDialog(payment);
      } else {
        throw Exception('Error al procesar el pago');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al procesar el pago: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
  
  void _showSuccessDialog(Payment payment) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: Icon(
          payment.status == 'completed' ? Icons.check_circle : Icons.schedule,
          color: payment.status == 'completed' ? const Color(0xFF97FB57) : Colors.orange,
          size: 64,
        ),
        title: Text(payment.status == 'completed' ? '¡Pago Exitoso!' : 'Pago Pendiente'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              payment.status == 'completed' 
                ? 'Tu pago de S/ ${payment.amount.toStringAsFixed(2)} ha sido procesado correctamente.'
                : 'Tu pago de S/ ${payment.amount.toStringAsFixed(2)} está siendo procesado.',
            ),
            const SizedBox(height: 16),
            if (payment.transactionId != null)
              Text(
                'ID: ${payment.transactionId}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Cerrar diálogo
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PaymentHistoryScreen(),
                ),
              );
            },
            child: const Text('Ver Historial'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Cerrar diálogo
              Navigator.of(context).pop(true); // Volver con resultado exitoso
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Realizar Pago'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PaymentHistoryScreen(),
                ),
              );
            },
            tooltip: 'Historial de Pagos',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resumen del pago
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resumen del Pago',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Evento:'),
                        Expanded(
                          child: Text(
                            widget.inscription.eventName,
                            textAlign: TextAlign.right,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Monto a pagar:'),
                        Text(
                          'S/ ${widget.inscription.amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF97FB57),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Métodos de pago
            Text(
              'Método de Pago',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            // Opciones de pago
            _buildPaymentMethodOption(
              'yape',
              'Yape',
              Icons.qr_code,
              color: const Color(0xFF722E82),
            ),
            _buildPaymentMethodOption(
              'visa',
              'Visa',
              Icons.credit_card,
              color: const Color(0xFF1A1F71),
            ),
            _buildPaymentMethodOption(
              'mastercard',
              'Mastercard',
              Icons.credit_card,
              color: const Color(0xFFEB001B),
            ),
            _buildPaymentMethodOption(
              'plin',
              'Plin',
              Icons.phone_android,
              color: const Color(0xFF00B4D8),
            ),
            _buildPaymentMethodOption(
              'transfer',
              'Transferencia Bancaria',
              Icons.account_balance,
            ),
            
            const SizedBox(height: 24),

            // Formulario según método seleccionado
            if (_selectedPaymentMethod == 'yape') ...[
              _buildYapePaymentForm(),
            ] else if (_selectedPaymentMethod == 'plin') ...[
              _buildPlinPaymentForm(),
            ] else if (_selectedPaymentMethod == 'visa' || _selectedPaymentMethod == 'mastercard') ...[
              _buildCardPaymentForm(),
            ] else ...[
              _buildTransferInfo(),
            ],

            const SizedBox(height: 32),

            // Botón de pago
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF97FB57),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isProcessing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        _getPaymentButtonText(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodOption(String value, String title, IconData icon, {Color? color}) {
    return Card(
      child: RadioListTile<String>(
        value: value,
        groupValue: _selectedPaymentMethod,
        onChanged: (newValue) {
          setState(() => _selectedPaymentMethod = newValue!);
        },
        title: Row(
          children: [
            Text(title),
            const SizedBox(width: 8),
            if (value == 'yape')
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF722E82),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'YAPE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        secondary: _buildPaymentLogo(value, icon, color),
      ),
    );
  }
  
  String _getPaymentButtonText() {
    switch (_selectedPaymentMethod) {
      case 'yape':
        return 'Confirmar Pago Yape S/ ${widget.inscription.amount.toStringAsFixed(2)}';
      case 'plin':
        return 'Confirmar Pago Plin S/ ${widget.inscription.amount.toStringAsFixed(2)}';
      case 'visa':
      case 'mastercard':
        return 'Pagar con Tarjeta S/ ${widget.inscription.amount.toStringAsFixed(2)}';
      default:
        return 'Confirmar Pago S/ ${widget.inscription.amount.toStringAsFixed(2)}';
    }
  }
  
  Widget _buildPaymentLogo(String method, IconData icon, Color? color) {
    // En producción, aquí usarías Image.asset con los logos reales
    switch (method) {
      case 'yape':
        return Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF722E82),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Text(
              'Y',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      case 'visa':
        return Container(
          width: 50,
          height: 30,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1F71),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Center(
            child: Text(
              'VISA',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      case 'mastercard':
        return Container(
          width: 50,
          height: 30,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: 8,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEB001B),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                right: 8,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF79E1B),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        );
      case 'plin':
        return Container(
          width: 50,
          height: 30,
          decoration: BoxDecoration(
            color: const Color(0xFF00B4D8),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Center(
            child: Text(
              'PLIN',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      default:
        return Icon(icon, color: color);
    }
  }

  Widget _buildCardPaymentForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _selectedPaymentMethod == 'visa' ? 'Información de Tarjeta Visa' : 'Información de Tarjeta Mastercard',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          
          // Número de tarjeta
          TextFormField(
            controller: _cardNumberController,
            decoration: const InputDecoration(
              labelText: 'Número de Tarjeta',
              hintText: '1234 5678 9012 3456',
              prefixIcon: Icon(Icons.credit_card),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              _CardNumberFormatter(),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa el número de tarjeta';
              }
              if (value.replaceAll(' ', '').length != 16) {
                return 'El número de tarjeta debe tener 16 dígitos';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Nombre del titular
          TextFormField(
            controller: _cardHolderController,
            decoration: const InputDecoration(
              labelText: 'Nombre del Titular',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.characters,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa el nombre del titular';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Fecha de vencimiento y CVV
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _expiryController,
                  decoration: const InputDecoration(
                    labelText: 'MM/AA',
                    hintText: '12/25',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    _ExpiryDateFormatter(),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Requerido';
                    }
                    if (value.length != 5) {
                      return 'Formato MM/AA';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _cvvController,
                  decoration: const InputDecoration(
                    labelText: 'CVV',
                    hintText: '123',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Requerido';
                    }
                    if (value.length < 3) {
                      return 'Mínimo 3 dígitos';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Guardar tarjeta
          CheckboxListTile(
            value: _saveCard,
            onChanged: (value) => setState(() => _saveCard = value ?? false),
            title: const Text('Guardar tarjeta para próximos pagos'),
            subtitle: const Text(
              'Tu información estará segura y encriptada',
              style: TextStyle(fontSize: 12),
            ),
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ],
      ),
    );
  }

  Widget _buildYapePaymentForm() {
    return Form(
      key: GlobalKey<FormState>(), // Formulario separado para Yape
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF722E82),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'YAPE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Pago rápido y seguro',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // QR Code real de Yape
        Center(
          child: Container(
            width: 250,
            height: 250,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF722E82), width: 2),
            ),
            child: FutureBuilder<Widget>(
              future: _buildQRImage(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF722E82),
                    ),
                  );
                }
                
                if (snapshot.hasError) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 60,
                        color: const Color(0xFFFF6B6B),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Error al generar QR',
                        style: const TextStyle(color: Color(0xFFFF6B6B)),
                      ),
                    ],
                  );
                }
                
                return snapshot.data ?? const SizedBox();
              },
            ),
          ),
        ),
        const SizedBox(height: 20),
        
        // Información de Yape
        Card(
          color: const Color(0xFF722E82).withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'O yapeanos directamente:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                _buildInfoRow('Número:', widget.organizerYape ?? '932 744 546'),
                _buildInfoRow('Nombre:', widget.organizerName ?? 'Torneos Deportivos SAC'),
                _buildInfoRow('Monto:', 'S/ ${widget.inscription.amount.toStringAsFixed(2)}'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.yellow.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info, color: Colors.orange),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Después de yapear, presiona "Confirmar Pago"',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Campo para número de teléfono
        TextFormField(
          controller: _phoneController,
          decoration: const InputDecoration(
            labelText: 'Tu número de teléfono (opcional)',
            hintText: 'Ej: 987654321',
            prefixIcon: Icon(Icons.phone),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        
        // Campo para ingresar número de operación
        TextFormField(
          controller: _operationController,
          decoration: const InputDecoration(
            labelText: 'Número de operación Yape (opcional)',
            hintText: 'Ej: 00123456',
            prefixIcon: Icon(Icons.confirmation_number),
            border: OutlineInputBorder(),
          ),
        ),
      ],
    ),
    );
  }
  
  Widget _buildPlinPaymentForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF00B4D8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'PLIN',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Pago rápido con Plin',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        const SizedBox(height: 20),
        
        Card(
          color: const Color(0xFF00B4D8).withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Realiza tu pago por Plin:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                _buildInfoRow('Número:', '987654321'),
                _buildInfoRow('Nombre:', 'TORNEOS APP SAC'),
                _buildInfoRow('Monto:', 'S/ ${widget.inscription.amount.toStringAsFixed(2)}'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Después de hacer tu Plin, presiona "Confirmar Pago"',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Campo para número de teléfono
        TextFormField(
          controller: _phoneController,
          decoration: const InputDecoration(
            labelText: 'Tu número de teléfono (opcional)',
            hintText: 'Ej: 987654321',
            prefixIcon: Icon(Icons.phone),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        
        // Campo para ingresar número de operación
        TextFormField(
          controller: _operationController,
          decoration: const InputDecoration(
            labelText: 'Número de operación Plin (opcional)',
            hintText: 'Ej: OP123456789',
            prefixIcon: Icon(Icons.confirmation_number),
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildTransferInfo() {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información para Transferencia',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Banco:', 'BCP - Banco de Crédito del Perú'),
            _buildInfoRow('Cuenta Corriente:', '191-2345678-0-12'),
            _buildInfoRow('CCI:', '002-191-002345678012-95'),
            _buildInfoRow('Beneficiario:', 'Torneos Deportivos SAC'),
            _buildInfoRow('RUC:', '20123456789'),
            _buildInfoRow('Referencia:', 'INS-${widget.inscription.id}'),
            const SizedBox(height: 16),
            const Text(
              'Importante: Después de realizar la transferencia, tu pago será verificado en un plazo de 24 horas.',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
  
  String _generateYapeString() {
    // Formato de Yape: Número*Nombre*Monto
    final phoneNumber = widget.organizerYape ?? '932744546';
    final recipientName = widget.organizerName ?? 'Torneos Deportivos SAC';
    final amount = widget.inscription.amount.toStringAsFixed(2);
    
    // Formato usado por Yape para generar QR
    return '$phoneNumber*$recipientName*$amount';
  }
  
  Future<Widget> _buildQRImage() async {
    try {
      final yapeData = _generateYapeString();
      // Usar API gratuita de qr-server.com para generar QR
      final qrUrl = Uri.encodeFull('https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=$yapeData');
      
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              qrUrl,
              width: 180,
              height: 180,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const SizedBox(
                  width: 180,
                  height: 180,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF722E82),
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.qr_code_2,
                      size: 120,
                      color: const Color(0xFF722E82),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Escanea el QR',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF722E82),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Escanea con Yape',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF722E82),
            ),
          ),
          Text(
            'S/ ${widget.inscription.amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    } catch (e) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.qr_code_2,
            size: 120,
            color: const Color(0xFF722E82),
          ),
          const SizedBox(height: 8),
          const Text(
            'Yapea al número:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF722E82),
            ),
          ),
          const Text(
            '932 744 546',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    }
  }
}

// Formateador para número de tarjeta
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if ((i + 1) % 4 == 0 && i + 1 != text.length) {
        buffer.write(' ');
      }
    }
    
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.toString().length),
    );
  }
}

// Formateador para fecha de vencimiento
class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll('/', '');
    final buffer = StringBuffer();
    
    for (int i = 0; i < text.length && i < 4; i++) {
      buffer.write(text[i]);
      if (i == 1 && text.length > 2) {
        buffer.write('/');
      }
    }
    
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.toString().length),
    );
  }
}