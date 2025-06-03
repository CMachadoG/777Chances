import 'package:chances/view/inicial_view.dart';
import 'package:chances/view/resultados_view.dart';
import 'package:chances/view/ventas_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

const colorPrincipal = Color(0xff4d7b30);
const colorFondoField = Color(0xfff7f7f7);
const colorGrisSecundario = Color(0xff619074);
const colorComplementario = Color(0xff5e307b);
const url = 'api.777chan.com';

SizedBox barraSuperior(
    BuildContext context, double height, String texto, double fontSize,
    {String corner = "L"}) {
  final screenHeight = MediaQuery.of(context).size.height * height;
  return SizedBox(
    height: screenHeight,
    child: Container(
      decoration: BoxDecoration(
        color: colorPrincipal,
        borderRadius: corner == 'R'
            ? const BorderRadius.only(bottomRight: Radius.circular(50.0))
            : const BorderRadius.only(bottomLeft: Radius.circular(50.0)),
      ),
      child: Center(
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 16.0), // Padding opcional
          child: Text(
            texto,
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize,
              fontFamily: "Inder",
              fontWeight: FontWeight.normal,
            ),
            overflow: TextOverflow
                .ellipsis, // Agrega puntos suspensivos si el texto es largo
            softWrap:
                true, // Permite que el texto se ajuste en varias líneas si es necesario
          ),
        ),
      ),
    ),
  );
}

Widget drawerMenu(BuildContext context) {
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        const DrawerHeader(
          decoration: BoxDecoration(
            color: colorPrincipal,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.person, color: Colors.white, size: 50),
              SizedBox(height: 10),
              Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ],
          ),
        ),
        ListTile(
          leading: const Icon(Icons.home),
          title: const Text('Inicio'),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const InicialScreen(),
              ),
            ); // Cierra el Drawer
          },
        ),
        ListTile(
          leading: const Icon(Icons.insights),
          title: const Text('Ventas'),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const VentasScreen(),
              ),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.receipt),
          title: const Text('Resultados'),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ResultadosScreen()),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.exit_to_app),
          title: const Text('Salir'),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamedAndRemoveUntil(
              context,
              'login',
                  (Route<dynamic> route) => false,
            );
          },
        ),
      ],
    ),
  );
}

class MonedaInputFormatter extends TextInputFormatter {
  //ARREGLAR EL QUE NO SE BORRA CORRECTAMENTE
  final NumberFormat formatoMoneda;

  MonedaInputFormatter({required this.formatoMoneda});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    String textoLimpio = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    if (textoLimpio.length <
        oldValue.text.replaceAll(RegExp(r'[^\d]'), '').length) {
      return newValue;
    }

    if (textoLimpio.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    final numero = int.parse(textoLimpio);

    final textoFormateado = formatoMoneda.format(numero);

    final desplazamientoCursor = textoFormateado.length - textoLimpio.length;
    final nuevaPosicionCursor =
        (newValue.selection.baseOffset + desplazamientoCursor)
            .clamp(0, textoFormateado.length);

    return TextEditingValue(
      text: textoFormateado,
      selection: TextSelection.collapsed(offset: nuevaPosicionCursor),
    );
  }
}
