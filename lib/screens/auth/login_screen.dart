import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import '../../services/auth_service.dart';
import '../home_screen.dart';
import 'register_screen.dart';
import '../organizer/organizer_dashboard_screen.dart';
import '../../services/security/security_service.dart';
import '../../services/security/encryption_service.dart';
import '../../services/security/audit_service.dart';
import '../../middleware/security_middleware.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  
  // Servicios de seguridad
  final SecurityService _securityService = SecurityService();
  final AuditService _auditService = AuditService();
  final SecurityMiddleware _securityMiddleware = SecurityMiddleware();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Verificar intentos de login
      await _securityService.canAttemptLogin(_emailController.text.trim());
      
      // Validar y sanitizar inputs con middleware de seguridad
      final result = await _securityMiddleware.validateAndProcess<bool>(
        input: {
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
          'deviceId': 'device_${DateTime.now().millisecondsSinceEpoch}',
        },
        processor: (sanitizedInput) async {
          // Registrar intento de login en auditoría
          await _auditService.logEvent(
            type: AuditEventType.login,
            userId: sanitizedInput['email'],
            action: 'login_attempt',
            data: {
              'timestamp': DateTime.now().toIso8601String(),
              'ip': '192.168.1.1', // En producción obtener IP real
            },
          );
          
          // Aquí iría la autenticación real con Firebase
          // final authService = Provider.of<AuthService>(context, listen: false);
          // await authService.signIn(
          //   email: sanitizedInput['email'],
          //   password: sanitizedInput['password'],
          // );
          
          // Simulación temporal
          await Future.delayed(const Duration(seconds: 1));
          
          // Limpiar intentos fallidos tras login exitoso
          _securityService.clearFailedAttempts(sanitizedInput['email']);
          
          // Registrar login exitoso
          await _auditService.logEvent(
            type: AuditEventType.login,
            userId: sanitizedInput['email'],
            action: 'login_success',
            severity: AuditSeverity.info,
          );
          
          return true;
        },
        userId: _emailController.text.trim(),
        action: 'user_login',
      );
      
      if (result && mounted) {
        // Crear sesión segura
        final sessionId = _securityService.createSecureSession(
          _emailController.text.trim(),
          'device_${DateTime.now().millisecondsSinceEpoch}',
        );
        
        // Navegar a home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      // Registrar intento fallido
      _securityService.recordFailedLogin(_emailController.text.trim());
      
      await _auditService.logEvent(
        type: AuditEventType.login,
        userId: _emailController.text.trim(),
        action: 'login_failed',
        data: {'error': e.toString()},
        severity: AuditSeverity.warning,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: const Color(0xFFFF6B6B),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF97FB57).withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'TORNEOS APP',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: const Color(0xFF97FB57),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tu plataforma deportiva',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFF909090),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Correo electrónico',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => 
                        _securityMiddleware.secureTextValidator(value, 'email'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: const Icon(Icons.lock),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                    ),
                    validator: (value) => 
                        _securityMiddleware.secureTextValidator(value, 'password'),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // TODO: Implementar recuperación de contraseña
                      },
                      child: const Text('¿Olvidaste tu contraseña?'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text(
                            'Iniciar Sesión',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('¿No tienes cuenta? '),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: const Text('Regístrate'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Botón temporal para organizadores
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const OrganizerDashboardScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.business),
                    label: const Text('Soy Organizador'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}