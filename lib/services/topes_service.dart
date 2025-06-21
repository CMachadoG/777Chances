import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';

class TopeService {
  Future<Map<String, dynamic>> validarTope({
    required List<double> loteriaIds,
    required String numero,
    required int apuestaNumero,
    required int apuestaCombinado,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    const uri = url;
    final urlApi = Uri.https(uri, '/api/juego/tope');

    final body = jsonEncode({
      'LoteriaId': loteriaIds,
      'numero': numero,
      'ApuestaNumero': apuestaNumero,
      'ApuestaCombinado': apuestaCombinado,
    });

    final response = await http.post(urlApi,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: body);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al validar tope');
    }
  }
}
