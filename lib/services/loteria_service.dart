import 'package:http/http.dart' as http;
import 'dart:convert';

import '../constants.dart';
import '../models/loteria_model.dart';

const urlapi = url;

class LoteriaApiService {
  /// Obtiene la lista de loterías.
  /// [token] → token **Bearer** que te entrega el login.
  Future<List<Loteria>> fetchLoterias(String token) async {
    final uri = Uri.https(url, 'api/juego/loterias'); // ENDPOINT real

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return loteriaFromJson(response.body); // helper de tu modelo
    } else if (response.statusCode == 401) {
      throw Exception('Token expirado o inválido (401)');
    } else {
      final msg = jsonDecode(response.body)['Message'] ?? 'error';
      throw Exception('Error ${response.statusCode}: $msg');
    }
  }
}
