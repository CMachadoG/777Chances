import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../providers/venta_provider.dart';

class VentasScreen extends StatefulWidget {
  const VentasScreen({super.key});

  @override
  State<VentasScreen> createState() => _VentasScreenState();
}

class _VentasScreenState extends State<VentasScreen> {
  DateTime fechaDesde = DateTime.now().subtract(Duration(days: 1));
  DateTime fechaHasta = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _consultarVentas();
    });
  }

  Future<void> _seleccionarFecha({required bool esInicio}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: esInicio ? fechaDesde : fechaHasta,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (esInicio) {
          fechaDesde = picked;
        } else {
          fechaHasta = picked;
        }
      });
      _consultarVentas();
    }
  }

  String _formatearMoneda(double valor) {
    return NumberFormat.currency(
            locale: 'es_CO', symbol: '\$', decimalDigits: 0)
        .format(valor);
  }

  void _consultarVentas() {
    final desde = DateFormat('dd/MM/yyyy').format(fechaDesde);
    final hasta = DateFormat('dd/MM/yyyy').format(fechaHasta);
    Provider.of<VentasProvider>(context, listen: false)
        .fetchVentas(desde, hasta);
  }

  String _formatear(DateTime fecha) => DateFormat('dd/MM/yyyy').format(fecha);

  Widget _etiqueta(String texto, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(5)),
      child: Text(texto, style: const TextStyle(color: Colors.white)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ventasProv = context.watch<VentasProvider>();
    final ventas = ventasProv.ventas?.detalle ?? [];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorPrincipal,
        iconTheme: const IconThemeData(color: colorFondoField),
      ),
      drawer: drawerMenu(context),
      body: Column(
        children: [
          barraSuperior(context, 0.09, "VENTAS", 40, corner: "R"),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _selectorFecha("Desde", fechaDesde,
                    () => _seleccionarFecha(esInicio: true)),
                _selectorFecha("Hasta", fechaHasta,
                    () => _seleccionarFecha(esInicio: false)),
              ],
            ),
          ),
          if (ventasProv.loading)
            const Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            )
          else if (ventasProv.error == null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              color: Colors.grey.shade100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      "V. Bruta    ${_formatearMoneda(ventasProv.ventas?.ventaBruta ?? 0)}",
                      style: const TextStyle(
                          color: Colors.green,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  Text(
                      "V. Neta     ${_formatearMoneda(ventasProv.ventas?.ventaNeta ?? 0)}",
                      style: const TextStyle(
                          color: Colors.red,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  Text(
                      "Ganancia    ${_formatearMoneda(ventasProv.ventas?.ganancia ?? 0)}",
                      style: const TextStyle(
                          color: Colors.green,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            )
          else if (ventasProv.ventas == null ||
              ventasProv.ventas!.detalle.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text("No hay ventas registradas para esta fecha.",
                  style: TextStyle(fontSize: 20, color: Colors.black54)),
            ),
          if (ventasProv.error != null)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text("Error: ${ventasProv.error}",
                  style: const TextStyle(color: Colors.red)),
            ),
          if (!ventasProv.loading)
            Expanded(
              child: ListView.builder(
                itemCount: ventas.length,
                itemBuilder: (context, index) {
                  final venta = ventas[index];
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(
                          color: colorGrisSecundario, width: 0.5),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _etiqueta(venta.fechaVenta, colorComplementario),
                              _etiqueta(
                                  "# venta ${venta.tiqueta}", Colors.green),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Text("APUESTA",
                              style: TextStyle(
                                  color: colorPrincipal,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 5),
                          Text("Valor: ${_formatearMoneda(venta.valorApuesta)}",
                              style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w500)),
                          if (venta.cliente.trim().isNotEmpty)
                            Text("Cliente: ${venta.cliente}",
                                style: const TextStyle(color: Colors.black87)),
                          const SizedBox(height: 5),
                          Text(venta.detalle,
                              style: const TextStyle(color: Colors.black54)),
                        ],
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

  Widget _selectorFecha(String label, DateTime fecha, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: colorPrincipal,
                fontSize: 18)),
        ElevatedButton.icon(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            elevation: 0,
            side: const BorderSide(color: colorPrincipal),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          icon:
              const Icon(Icons.calendar_today, size: 18, color: colorPrincipal),
          label: Text(_formatear(fecha), style: const TextStyle(fontSize: 18)),
        ),
      ],
    );
  }
}
