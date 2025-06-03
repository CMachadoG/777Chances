import 'dart:convert';

List<Loteria> loteriaFromJson(String str) =>
    List<Loteria>.from(json.decode(str).map((x) => Loteria.fromJson(x)));

String loteriaToJson(List<Loteria> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Loteria {
  final String id;
  final String loteriaId;
  final String nombre;
  final String abreviatura;
  final String imagenString;
  final String horaSorteo;

  Loteria(
      {required this.id,
      required this.loteriaId,
      required this.nombre,
      required this.abreviatura,
      required this.imagenString,
      required this.horaSorteo});

  // Factory para convertir el JSON ⇢ objeto
  factory Loteria.fromJson(Map<String, dynamic> json) => Loteria(
      id: json["\u0024id"],
      loteriaId: json['LoteriaId'].toString(),
      nombre: json['LoteriaNombre'],
      abreviatura: json['LoteriaNombreAb'].toString().trim(),
      imagenString: json['Imagen'],
      horaSorteo: json['SorteoHora'].toString());

  Map<String, dynamic> toJson() => {
        "\u0024id": id,
        "LoteriaId": num.parse(loteriaId).toInt(),
        "LoteriaNombre": nombre,
        "LoteriaNombreAb": abreviatura,
        "Imagen": imagenString,
        "SorteoHora": horaSorteo
      };
}
