import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'services/tournament_service.dart';
import 'services/payment_service.dart';
import 'services/security/security_service.dart';
import 'services/security/encryption_service.dart';
import 'services/security/audit_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home_simple.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  
  // Inicializar servicios de seguridad - versión optimizada
  try {
    final encryptionService = EncryptionService();
    encryptionService.initialize();
    
    final securityService = SecurityService();
    await securityService.initialize();
    
    final auditService = AuditService();
    await auditService.initialize();
  } catch (e) {
    debugPrint('Error inicializando servicios de seguridad: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        ChangeNotifierProvider<TournamentService>(create: (_) => TournamentService()),
        ChangeNotifierProvider<PaymentService>(create: (_) => PaymentService()),
        // StreamProvider(
        //   create: (context) => context.read<AuthService>().authStateChanges,
        //   initialData: null,
        // ),
      ],
      child: MaterialApp(
        title: 'Torneo App',
        theme: ThemeData(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF97FB57), // Verde neón
            secondary: Color(0xFF97FB57),
            surface: Color(0xFF121212), // Negro
            onPrimary: Color(0xFF121212),
            onSecondary: Color(0xFF121212),
            onSurface: Color(0xFFF6F2F2), // Gris claro
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFF121212),
          // AppBar
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
            backgroundColor: Color(0xFF121212),
            foregroundColor: Color(0xFF97FB57),
          ),
          // Botones elevados
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF97FB57),
              foregroundColor: const Color(0xFF121212),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          // Botones outlined
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF97FB57),
              side: const BorderSide(
                color: Color(0xFF97FB57),
                width: 2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
          // Cards
          cardTheme: CardThemeData(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: const Color(0xFF909090).withOpacity(0.2),
                width: 1,
              ),
            ),
            color: const Color(0xFF1A1A1A),
          ),
          // Input Decoration
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFF1A1A1A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(
                color: Color(0xFF909090),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(
                color: const Color(0xFF909090).withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(
                color: Color(0xFF97FB57),
                width: 2,
              ),
            ),
            labelStyle: const TextStyle(color: Color(0xFF909090)),
            hintStyle: TextStyle(color: const Color(0xFF909090).withOpacity(0.5)),
          ),
          // Bottom Navigation
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Color(0xFF1A1A1A),
            selectedItemColor: Color(0xFF97FB57),
            unselectedItemColor: Color(0xFF909090),
          ),
          // Texto
          textTheme: const TextTheme(
            headlineLarge: TextStyle(color: Color(0xFFF6F2F2)),
            headlineMedium: TextStyle(color: Color(0xFFF6F2F2)),
            headlineSmall: TextStyle(color: Color(0xFFF6F2F2)),
            titleLarge: TextStyle(color: Color(0xFFF6F2F2)),
            titleMedium: TextStyle(color: Color(0xFFF6F2F2)),
            titleSmall: TextStyle(color: Color(0xFFF6F2F2)),
            bodyLarge: TextStyle(color: Color(0xFFF6F2F2)),
            bodyMedium: TextStyle(color: Color(0xFFF6F2F2)),
            bodySmall: TextStyle(color: Color(0xFF909090)),
          ),
        ),
        darkTheme: ThemeData(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF97FB57),
            secondary: Color(0xFF97FB57),
            surface: Color(0xFF121212),
            onPrimary: Color(0xFF121212),
            onSecondary: Color(0xFF121212),
            onSurface: Color(0xFFF6F2F2),
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFF121212),
        ),
        themeMode: ThemeMode.dark, // Forzar tema oscuro
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // final firebaseUser = context.watch<User?>();
    final firebaseUser = null; // Temporal sin Firebase

    if (firebaseUser != null) {
      return const SimpleHomeScreen(); // HomeScreen();
    }
    return const LoginScreen();
  }
}