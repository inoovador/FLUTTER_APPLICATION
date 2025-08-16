// Servicio temporal sin Firebase
import 'dart:developer' as developer;
import '../models/user_model.dart';

class AuthService {
  Stream<dynamic> get authStateChanges => Stream.value(null);
  
  dynamic get currentUser => null;

  Future<UserModel?> getCurrentUserData() async {
    return null;
  }

  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    // Simulación temporal
    return null;
  }

  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    // Simulación temporal
    return null;
  }

  Future<void> signOut() async {
    // Simulación temporal
  }

  Future<void> resetPassword(String email) async {
    // Simulación temporal
  }
}