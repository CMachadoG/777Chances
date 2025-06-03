import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';

class smsService {
  Future<Map<String, dynamic>> enviarSms(int ticket) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    const uri = url;
    final urlApi = Uri.https(uri, '/api/juego/enviamensaje');

    final body = jsonEncode({
      'VentaId': ticket,
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
      throw Exception('Error al enviar mensaje');
    }
  }
}
