import 'dart:convert';

import 'package:chances/helpers/shared_preferences_helpers.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../constants.dart';
import '../models/juego_model.dart';
import '../models/loteria_model.dart';

class JuegoService {
  Future<Map<String, String>> crearVenta(
      {required String cliente,
      required String celular,
      required List<Map<String, dynamic>> juegos,
      required List<Loteria> sorteos}) async {
    final token = await getToken();
    final vendedorId = await getUsuarioId();

    final fechaFormateada =
        DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());

    final List<DetalleJuego> detalles = [];

    for (var juego in juegos) {
      for (var sorteo in sorteos) {
        detalles.add(
          DetalleJuego(
            loteriaId: (sorteo.loteriaId),
            numero: juego['numero'],
            combinado: juego['combinado'] ?? false,
            apuestaNumero: juego['apuesta'],
            apuestaCombinado: juego['combinadoApuesta'] ?? '0',
          ),
        );
      }
    }

    Juego venta = Juego(
      fecha: fechaFormateada,
      cliente: cliente,
      celular: celular,
      vendedorId: vendedorId,
      detalles: detalles,
    );

    final urlApi = Uri.https(url, '/api/juego/grabajuego');

    final response = await http.post(
      urlApi,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: venta.toJson(),
    );
    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(
          'Error al crear venta: ${data['Mensaje'] ?? 'Desconocido'}');
    } else {
      String numeroJuego = data['NumeroJuego'] ?? '';
      String mensaje = data['Mensaje'] ?? '';
      return {
        'numeroJuego': numeroJuego,
        'mensaje': mensaje,
      };
    }
  }
}
