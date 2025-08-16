import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PaymentSettingsScreen extends StatefulWidget {
  const PaymentSettingsScreen({super.key});

  @override
  State<PaymentSettingsScreen> createState() => _PaymentSettingsScreenState();
}

class _PaymentSettingsScreenState extends State<PaymentSettingsScreen> {
  // Controladores Yape
  final _yapeNumberController = TextEditingController();
  final _yapeNameController = TextEditingController();
  
  // Controladores Plin
  final _plinNumberController = TextEditingController();
  
  // Controladores Banco
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _cciController = TextEditingController();
  String _accountType = 'ahorros';
  
  // Estados de habilitación
  bool _yapeEnabled = false;
  bool _plinEnabled = false;
  bool _bankEnabled = false;
  
  @override
  void dispose() {
    _yapeNumberController.dispose();
    _yapeNameController.dispose();
    _plinNumberController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _cciController.dispose();
    super.dispose();
  }
  
  void _saveSettings() {
    // Validar que al menos un método esté configurado
    if (!_yapeEnabled && !_plinEnabled && !_bankEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes configurar al menos un método de pago'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // TODO: Guardar en base de datos
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Métodos de pago actualizados'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurar Métodos de Pago'),
        actions: [
          TextButton(
            onPressed: _saveSettings,
            child: const Text(
              'Guardar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información importante
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Información Importante',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Los jugadores pagarán directamente a estas cuentas. Asegúrate de que la información sea correcta.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // YAPE
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF722E82),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'YAPE',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Switch(
                          value: _yapeEnabled,
                          onChanged: (value) {
                            setState(() {
                              _yapeEnabled = value;
                            });
                          },
                          activeColor: const Color(0xFF722E82),
                        ),
                      ],
                    ),
                    
                    if (_yapeEnabled) ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _yapeNumberController,
                        keyboardType: TextInputType.phone,
                        maxLength: 9,
                        decoration: const InputDecoration(
                          labelText: 'Número de Yape',
                          hintText: '999888777',
                          prefixIcon: Icon(Icons.phone),
                          border: OutlineInputBorder(),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _yapeNameController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre en Yape',
                          hintText: 'Como aparece en la app',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // PLIN
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.teal,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'PLIN',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Switch(
                          value: _plinEnabled,
                          onChanged: (value) {
                            setState(() {
                              _plinEnabled = value;
                            });
                          },
                          activeColor: Colors.teal,
                        ),
                      ],
                    ),
                    
                    if (_plinEnabled) ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _plinNumberController,
                        keyboardType: TextInputType.phone,
                        maxLength: 9,
                        decoration: const InputDecoration(
                          labelText: 'Número de Plin',
                          hintText: '999888777',
                          prefixIcon: Icon(Icons.phone),
                          border: OutlineInputBorder(),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // TRANSFERENCIA BANCARIA
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.account_balance, color: Colors.blue),
                        const SizedBox(width: 8),
                        const Text(
                          'Transferencia Bancaria',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        Switch(
                          value: _bankEnabled,
                          onChanged: (value) {
                            setState(() {
                              _bankEnabled = value;
                            });
                          },
                        ),
                      ],
                    ),
                    
                    if (_bankEnabled) ...[
                      const SizedBox(height: 16),
                      
                      // Banco
                      DropdownButtonFormField<String>(
                        value: _bankNameController.text.isEmpty ? null : _bankNameController.text,
                        decoration: const InputDecoration(
                          labelText: 'Banco',
                          prefixIcon: Icon(Icons.account_balance),
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'BCP', child: Text('BCP')),
                          DropdownMenuItem(value: 'BBVA', child: Text('BBVA')),
                          DropdownMenuItem(value: 'Interbank', child: Text('Interbank')),
                          DropdownMenuItem(value: 'Scotiabank', child: Text('Scotiabank')),
                          DropdownMenuItem(value: 'BanBif', child: Text('BanBif')),
                        ],
                        onChanged: (value) {
                          _bankNameController.text = value ?? '';
                        },
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Tipo de cuenta
                      Row(
                        children: [
                          const Text('Tipo de cuenta:'),
                          const SizedBox(width: 16),
                          Radio<String>(
                            value: 'ahorros',
                            groupValue: _accountType,
                            onChanged: (value) {
                              setState(() {
                                _accountType = value!;
                              });
                            },
                          ),
                          const Text('Ahorros'),
                          const SizedBox(width: 16),
                          Radio<String>(
                            value: 'corriente',
                            groupValue: _accountType,
                            onChanged: (value) {
                              setState(() {
                                _accountType = value!;
                              });
                            },
                          ),
                          const Text('Corriente'),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      TextFormField(
                        controller: _accountNumberController,
                        decoration: const InputDecoration(
                          labelText: 'Número de Cuenta',
                          hintText: '191-1234567-0-89',
                          prefixIcon: Icon(Icons.credit_card),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      TextFormField(
                        controller: _cciController,
                        maxLength: 20,
                        decoration: const InputDecoration(
                          labelText: 'CCI (Código Interbancario)',
                          hintText: '00219100123456789012',
                          prefixIcon: Icon(Icons.numbers),
                          border: OutlineInputBorder(),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Resumen de comisiones
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.monetization_on, color: Colors.amber.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Comisiones de la Plataforma',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Por cada inscripción, se aplicará una comisión del 10% sobre el monto total.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.amber.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ejemplo: Si cobras S/ 50, recibirás S/ 45',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade900,
                    ),
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