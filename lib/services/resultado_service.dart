import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import '../models/resultado_model.dart';

class ResultadoService {
  Future<List<Resultado>> obtenerResultados(String fecha) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    const uri = url;
    final urlApi = Uri.https(uri, '/api/resultados/getresultados');
    final response = await http.post(
      urlApi,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({"Fecha": fecha}),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Resultado.fromJson(e)).toList();
    } else {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  }
}
