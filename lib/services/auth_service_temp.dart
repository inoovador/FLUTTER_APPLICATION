// Servicio temporal sin Firebase
class AuthService {
  Stream<dynamic> get authStateChanges => Stream.value(null);
  
  dynamic get currentUser => null;

  Future<dynamic> getCurrentUserData() async {
    return null;
  }

  Future<dynamic> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    // Simulación temporal
    return null;
  }

  Future<dynamic> signIn({
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