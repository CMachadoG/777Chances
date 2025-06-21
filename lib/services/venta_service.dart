import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/venta_model.dart';

class VentasService {
  Future<VentasResponse> getVentas(String fechaInicio, String fechaFin) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final vendedorId = prefs.getString('usuarioId');

    if (token == null || vendedorId == null) {
      throw Exception('Token o VendedorId no encontrados');
    }

    final url = Uri.parse('https://api.777chan.com/api/ventas/vendedor');

    final Map<String, dynamic> body = {
      "FechaInicial": fechaInicio,
      "FechaFinal": fechaFin,
      "VendedorId": vendedorId,
    };

    final String encodedBody = jsonEncode(body);

    final Map<String, String> headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final response = await http.post(
      url,
      headers: headers,
      body: encodedBody,
    );



    if (response.statusCode == 200) {
      return VentasResponse.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 500) {
      throw Exception('No hay ventas registradas en este intervalo de tiempo');
    } else {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  }
}
