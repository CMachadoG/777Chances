class Resultado {
  final String fecha;
  final String loteria;
  final String numero;

  Resultado({
    required this.fecha,
    required this.loteria,
    required this.numero,
  });

  factory Resultado.fromJson(Map<String, dynamic> json) {
    return Resultado(
      fecha: json['Fecha'],
      loteria: json['Loteria'].trim(),
      numero: json['Numero'],
    );
  }
}
