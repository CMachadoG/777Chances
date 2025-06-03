class DetalleVenta {
  final String fechaVenta;
  final String tiqueta;
  final double valorApuesta;
  final String cliente;
  final String detalle;

  DetalleVenta({
    required this.fechaVenta,
    required this.tiqueta,
    required this.valorApuesta,
    required this.cliente,
    required this.detalle,
  });

  factory DetalleVenta.fromJson(Map<String, dynamic> json) => DetalleVenta(
        fechaVenta: json['FechaVEnta'],
        tiqueta: json['Tiqueta'],
        valorApuesta: json['ValorApuesta'],
        cliente: json['Cliente'],
        detalle: json['Detalle'],
      );
}

class VentasResponse {
  final String fechaInicial;
  final String fechaFinal;
  final double ventaBruta;
  final double ventaNeta;
  final double ganancia;
  final List<DetalleVenta> detalle;

  VentasResponse({
    required this.fechaInicial,
    required this.fechaFinal,
    required this.ventaBruta,
    required this.ventaNeta,
    required this.ganancia,
    required this.detalle,
  });

  factory VentasResponse.fromJson(Map<String, dynamic> json) => VentasResponse(
        fechaInicial: json['FechaInicial'],
        fechaFinal: json['FechaFinal'],
        ventaBruta: json['VentaBruta'],
        ventaNeta: json['VentaNeta'],
        ganancia: json['Ganancia'],
        detalle: (json['detalle'] as List)
            .map((item) => DetalleVenta.fromJson(item))
            .toList(),
      );
}
