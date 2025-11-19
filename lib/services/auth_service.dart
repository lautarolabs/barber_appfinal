// lib/services/auth_service.dart

class AuthService {
  // Credenciales de administrador simuladas
  static const String _adminUsername = 'admin';
  static const String _adminPassword = '123'; // ¡En producción, nunca guardes contraseñas así!

  // Simula el proceso de inicio de sesión
  Future<bool> login({
    required String username,
    required String password,
  }) async {
    // Simula una latencia de red
    await Future.delayed(const Duration(milliseconds: 1000)); 

    if (username == _adminUsername && password == _adminPassword) {
      return true; // Login exitoso
    } else {
      return false; // Credenciales inválidas
    }
  }
}