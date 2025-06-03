import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chances/constants.dart';
import 'package:chances/services/api_service.dart'; // aquí tienes tu interceptor

class LoginService {
  Future<void> login(String username, String password) async {
    final uri = Uri.https(url, 'api/login/authenticate');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'Username': username, 'Password': password}),
    );

    if (response.statusCode == 200) {
      // Procesar y guardar token y otros datos
      final json = jsonDecode(response.body);
      final token = json['Token'];
      final userId = json['UsuarioId'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setString('usuarioId', userId);

      configureInterceptor(token);
    } else if (response.statusCode == 401) {
      throw Exception('Credenciales incorrectas');
    } else {
      throw Exception('Error inesperado (${response.statusCode})');
    }
  }
}
