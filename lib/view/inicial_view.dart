import 'package:flutter/material.dart';
import 'package:chances/view/juego_view.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../models/loteria_model.dart';
import '../providers/loteria_provider.dart';
import 'dart:convert';
import 'dart:typed_data';

class InicialScreen extends StatefulWidget {
  const InicialScreen({super.key});

  @override
  InicialScreenState createState() => InicialScreenState();
}

class InicialScreenState extends State<InicialScreen> {
  List<Loteria> sorteosSeleccionados = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reiniciarPantalla();
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<LoteriaProvider>();
    if (prov.error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Inicio')),
        body: Center(child: Text('Error: ${prov.error}')),
      );
    }
    final sorteos = prov.loterias;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorPrincipal,
        iconTheme: const IconThemeData(color: colorFondoField),
      ),
      drawer: drawerMenu(context),
      body: Column(
        children: [
          barraSuperior(context, 0.10, "INICIO", 40, corner: "R"),
          Expanded(
            child: ListView.separated(
              itemCount: sorteos.length,
              itemBuilder: (_, index) {
                final sorteo = sorteos[index];
                final isSelected = sorteosSeleccionados.contains(sorteo);
                Uint8List bytes = base64Decode(sorteo.imagenString);
                return ListTile(
                  leading: Image.memory(
                    bytes,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                  tileColor: isSelected ? colorPrincipal : colorFondoField,
                  title: Text(
                    sorteo.nombre,
                    style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500),
                  ),
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        sorteosSeleccionados.remove(sorteo);
                      } else {
                        sorteosSeleccionados.add(sorteo);
                      }
                    });
                  },
                  trailing: isSelected
                      ? const Icon(Icons.check, color: Colors.white)
                      : null,
                );
              },
              separatorBuilder: (context, index) => const Divider(
                thickness: 0.3,
                color: colorGrisSecundario,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: sorteosSeleccionados.isNotEmpty
          ? FloatingActionButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => JuegoScreen(
                      sorteosSeleccionados: List.from(sorteosSeleccionados),
                    ),
                  ),
                );
                _reiniciarPantalla(); // Recargar al volver de la pantalla Juego
              },
              backgroundColor: colorPrincipal,
              child: const Icon(Icons.check, color: colorFondoField),
            )
          : null,
    );
  }

  void _reiniciarPantalla() {
    setState(() {
      sorteosSeleccionados.clear();
    });
    // Volver a cargar desde el provider
    context.read<LoteriaProvider>().cargarLoterias();
  }
}
