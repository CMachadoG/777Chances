import 'dart:convert';

class Juego {
  final String fecha;
  final String cliente;
  final String celular;
  final String? vendedorId;
  final List<DetalleJuego> detalles;

  Juego({
    required this.fecha,
    required this.cliente,
    required this.celular,
    required this.vendedorId,
    required this.detalles,
  });

  // Convierte un objeto VentaModel a un mapa para enviarlo como cuerpo de la solicitud
  Map<String, dynamic> toMap() {
    return {
      'Fecha': fecha,
      'cliente': cliente,
      'celular': celular,
      'VerdedorId': vendedorId,
      'Detalles': detalles.map((detalle) => detalle.toMap()).toList(),
    };
  }

  // Convierte un objeto VentaModel a JSON
  String toJson() => jsonEncode(toMap());

  // Constructor para crear una instancia desde un mapa (JSON)
  factory Juego.fromJson(Map<String, dynamic> json) {
    return Juego(
      fecha: json['Fecha'],
      cliente: json['cliente'],
      celular: json['celular'],
      vendedorId: json['VerdedorId'],
      detalles: List<DetalleJuego>.from(
        json['Detalles'].map((detalle) => DetalleJuego.fromJson(detalle)),
      ),
    );
  }
}

class DetalleJuego {
  final String loteriaId;
  final String numero;
  final bool combinado;
  final String apuestaNumero;
  final String apuestaCombinado;

  DetalleJuego({
    required this.loteriaId,
    required this.numero,
    required this.combinado,
    required this.apuestaNumero,
    required this.apuestaCombinado,
  });

  // Convierte un objeto DetalleVentaModel a un mapa
  Map<String, dynamic> toMap() {
    return {
      'loteriaId': loteriaId,
      'numero': numero,
      'combinado': combinado,
      'ApuestaNumero': apuestaNumero,
      'ApuestaCombinado': apuestaCombinado,
    };
  }

  // Convierte un objeto DetalleVentaModel a JSON
  String toJson() => jsonEncode(toMap());

  // Constructor para crear una instancia desde un mapa (JSON)
  factory DetalleJuego.fromJson(Map<String, dynamic> json) {
    return DetalleJuego(
      loteriaId: json['loteriaId'],
      numero: json['numero'],
      combinado: json['combinado'],
      apuestaNumero: json['ApuestaNumero'],
      apuestaCombinado: json['ApuestaCombinado'],
    );
  }
}
