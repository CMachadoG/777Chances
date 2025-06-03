import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/resultado_service.dart';
import '../models/resultado_model.dart';
import '../constants.dart';

class ResultadosScreen extends StatefulWidget {
  const ResultadosScreen({super.key});

  @override
  State<ResultadosScreen> createState() => _ResultadosScreenState();
}

class _ResultadosScreenState extends State<ResultadosScreen> {
  final ResultadoService service = ResultadoService();
  DateTime fechaSeleccionada = DateTime.now();
  List<Resultado> resultados = [];
  bool cargando = false;
  String? error;

  @override
  void initState() {
    super.initState();
    _cargarResultados();
  }

  Future<void> _cargarResultados() async {
    setState(() {
      cargando = true;
      error = null;
    });
    try {
      final fechaFormateada =
          DateFormat('dd/MM/yyyy').format(fechaSeleccionada);
      final data = await service.obtenerResultados(fechaFormateada);
      setState(() {
        resultados = data;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    } finally {
      setState(() {
        cargando = false;
      });
    }
  }

  Future<void> _seleccionarFecha() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: fechaSeleccionada,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        fechaSeleccionada = picked;
      });
      _cargarResultados();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorPrincipal,
      ),
      body: Column(
        children: [
          barraSuperior(context, 0.09, "RESULTADOS", 40, corner: "R"),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: _seleccionarFecha,
              icon: const Icon(Icons.calendar_today),
              label: Text(DateFormat('dd/MM/yyyy').format(fechaSeleccionada)),
            ),
          ),
          if (cargando)
            const Center(child: CircularProgressIndicator())
          else if (error != null)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text("Error: $error",
                  style: const TextStyle(color: Colors.red)),
            )
          else
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints:
                            BoxConstraints(minWidth: constraints.maxWidth),
                        child: DataTable(
                          columnSpacing: 10,
                          headingRowColor:
                              MaterialStateProperty.all(colorPrincipal),
                          headingTextStyle: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                          columns: const [
                            DataColumn(
                              label: Center(
                                child: Text('Lotería',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                            DataColumn(
                              label: Center(
                                child: Text('Fecha',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                            DataColumn(
                              label: Center(
                                child: Text('Número',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                          rows: resultados.map((r) {
                            return DataRow(
                              cells: [
                                DataCell(Text(r.loteria.trim(),
                                    style: const TextStyle(fontSize: 18))),
                                DataCell(Text(
                                    DateFormat('dd/MM/yyyy')
                                        .format(DateTime.parse(r.fecha)),
                                    style: const TextStyle(fontSize: 18))),
                                DataCell(Text(r.numero,
                                    style: const TextStyle(fontSize: 18))),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
