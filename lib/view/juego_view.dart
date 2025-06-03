import 'package:chances/models/loteria_model.dart';
import 'package:chances/services/juego_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants.dart';
import '../services/smsService.dart';
import '../services/topes_service.dart';
import 'contactos_view.dart';

class JuegoScreen extends StatefulWidget {
  final List<Loteria> sorteosSeleccionados;

  const JuegoScreen({super.key, required this.sorteosSeleccionados});

  @override
  JuegoScreenState createState() => JuegoScreenState();
}

class JuegoScreenState extends State<JuegoScreen> {
  List<Map<String, dynamic>> juegos = [];
  final TextEditingController _telefonoController = TextEditingController();
  final List<TextEditingController> _numeroControllers = [
    TextEditingController()
  ];
  final List<TextEditingController> _apuestaControllers = [
    TextEditingController()
  ];
  final List<TextEditingController> _combinadoControllers = [
    TextEditingController()
  ];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final formatoMoneda =
      NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);
  String hintApuesta = "Apuesta";

  @override
  void dispose() {
    for (var controller in _numeroControllers) {
      controller.dispose();
    }
    for (var controller in _apuestaControllers) {
      controller.dispose();
    }
    for (var controller in _combinadoControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Scaffold.of(context).openDrawer(),
          icon: const Icon(Icons.menu),
        ),
        backgroundColor: colorPrincipal,
        iconTheme: const IconThemeData(color: colorFondoField),
      ),
      drawer: drawerMenu(context),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            barraSuperior(context, 0.04, "", 40, corner: "R"),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _telefonoController,
                        style: const TextStyle(fontSize: 20),
                        selectionControls: materialTextSelectionControls,
                        keyboardType: const TextInputType.numberWithOptions(),
                        decoration: InputDecoration(
                          labelStyle: const TextStyle(
                              color: colorPrincipal, fontSize: 17),
                          labelText: 'Telefono (opcional)',
                          prefixIcon: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  '+57',
                                  style: TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                ),
                              ),
                              VerticalDivider(
                                color: Colors.grey,
                                thickness: 1,
                              ),
                            ],
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                const BorderSide(color: colorFondoField),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                        ),
                        cursorColor: colorPrincipal,
                      )),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 0,
                    child: OutlinedButton(
                      onPressed: () async {
                        final contacto = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ContactosScreen()),
                        );
                        if (contacto != null) {
                          setState(() {
                            _telefonoController.text = contacto;
                          });
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 10),
                        side: const BorderSide(color: colorGrisSecundario),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.contacts, size: 18, color: colorPrincipal),
                          SizedBox(width: 5),
                          Text(
                            'Buscar',
                            style:
                                TextStyle(fontSize: 17, color: colorPrincipal),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            filaJuego(juegos.length, isNueva: true),
            // Fila fija bajo el teléfono
            Expanded(
              child: ListView.builder(
                itemCount: juegos.length,
                itemBuilder: (BuildContext context, int index) {
                  if (index == juegos.length) {
                    // Nueva fila vacía para agregar un nuevo juego
                    return filaJuego(index, isNueva: true);
                  }
                  return filaJuego(index);
                },
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
              child: SizedBox(
                width: screenWidth * 0.8,
                height: screenHeight * 0.07,
                child: ElevatedButton(
                  onPressed: () async {
                    if (!validarFormulario()) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Debe completar los campos')),
                      );
                      return;
                    }

                    final confirm = await mostrarDialogoConfirmarApuesta(
                      context,
                      juegos,
                      widget.sorteosSeleccionados,
                    );

                    if (!mounted || !confirm) return;

                    await procesarVenta(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorPrincipal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    "Apostar ${formatoMoneda.format(totalApuesta())}",
                    style: const TextStyle(color: Colors.white, fontSize: 25),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget filaJuego(int index, {bool isNueva = false}) {
    final numero = inputNumero(index, isNueva);
    final apuesta = inputApuesta(index, isNueva);
    final combinado = inputCombinado(index, isNueva);

    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(child: numero),
          Expanded(child: apuesta),
          Expanded(child: combinado),
          IconButton(
            onPressed: () async {
              if (isNueva) {
                if (_formKey.currentState?.validate() ?? false) {
                  final numero = _numeroControllers.last.text;
                  final apuesta =(int.tryParse(_apuestaControllers.last.text) ?? 0);
                  final combinado = _combinadoControllers.last.text;

                  final puedeGuardar = await validarTopes(
                    numero: numero,
                    apuesta: apuesta,
                    combinadoApuesta: combinado,
                  );

                  if (puedeGuardar) {
                    _guardarJuego(); // Tu función actual para guardar el juego
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Complete todos los campos')),
                  );
                }
              } else if (juegos[index]['isGuardado']) {
                // Eliminar si ya está guardado
                setState(() {
                  juegos.removeAt(index);
                  _numeroControllers.removeAt(index);
                  _apuestaControllers.removeAt(index);
                  _combinadoControllers.removeAt(index);
                });
              } else {
                // Marcar como guardado
                setState(() {
                  juegos[index]['isGuardado'] = true;
                });
              }
            },
            icon: Icon(
              isNueva
                  ? Icons.check
                  : (juegos[index]['isGuardado']
                      ? Icons.backspace
                      : Icons.check),
              color: colorPrincipal,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  TextFormField inputNumero(int index, bool isNueva) {
    return TextFormField(
      controller: isNueva ? _numeroControllers.last : _numeroControllers[index],
      style: const TextStyle(fontSize: 20),
      decoration: const InputDecoration(
        hintText: 'Número',
        hintStyle: TextStyle(fontSize: 20),
        focusColor: colorPrincipal,
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: colorGrisSecundario,
            width: 1.5,
          ),
        ),
      ),
      cursorColor: colorPrincipal,
      keyboardType: TextInputType.number,
      maxLength: 4,
      readOnly: !isNueva && juegos[index]['isGuardado'],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Ingrese un número';
        }
        return null;
      },
    );
  }

  TextFormField inputApuesta(int index, bool isNueva) {
    return TextFormField(
      controller:
          isNueva ? _apuestaControllers.last : _apuestaControllers[index],
      style: const TextStyle(fontSize: 20),
      decoration: const InputDecoration(
        hintStyle: TextStyle(fontSize: 20),
        hintText: 'Apuesta',
        helperText: '',
        focusColor: colorPrincipal,
        prefixIcon: Icon(Icons.attach_money),
        prefixIconColor: colorGrisSecundario,
        prefixIconConstraints: BoxConstraints(maxWidth: 22, maxHeight: 23),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: colorGrisSecundario,
            width: 1.5,
          ),
        ),
      ),
      cursorColor: colorPrincipal,
      keyboardType: TextInputType.number,
      readOnly: !isNueva && juegos[index]['isGuardado'],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Ingrese una cifra';
        }
        return null;
      },
    );
  }

  TextFormField inputCombinado(int index, bool isNueva) {
    return TextFormField(
      controller:
          isNueva ? _combinadoControllers.last : _combinadoControllers[index],
      style: const TextStyle(fontSize: 20),
      decoration: const InputDecoration(
        hintStyle: TextStyle(fontSize: 20),
        hintText: 'Combinado',
        helperText: '',
        focusColor: colorPrincipal,
        prefixIcon: Icon(Icons.attach_money),
        prefixIconColor: colorGrisSecundario,
        prefixIconConstraints: BoxConstraints(maxWidth: 22, maxHeight: 23),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: colorGrisSecundario,
            width: 1.5,
          ),
        ),
      ),
      cursorColor: colorPrincipal,
      keyboardType: TextInputType.number,
      readOnly: !isNueva && juegos[index]['isGuardado'],
    );
  }

  int totalApuesta() {
    int apuesta = 0;
    for (var juego in juegos) {
      int apuestaValor = int.tryParse(juego['apuesta'] ?? '0') ?? 0;
      int combinadoValor = int.tryParse(juego['combinadoApuesta'] ?? '0') ?? 0;

      apuesta += apuestaValor;
      apuesta += combinadoValor;
    }
    return apuesta * widget.sorteosSeleccionados.length;
  }


  bool validarTelefono() {
    String telefono = _telefonoController.text.toString().trim();
    if (telefono.length == 10) {
      if (telefono[0] == '3') {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  bool validarFormulario() {
    if (juegos.isEmpty) {
      return false;
    }
    // Validar filas de juegos
    for (int i = 0; i < juegos.length; i++) {
      if (!juegos[i]['isNueva'] && !juegos[i]['isGuardado']) {
        // Si no es nueva y no está guardada, verificar campos
        if (_numeroControllers[i].text.isEmpty ||
            _apuestaControllers[i].text.isEmpty) {
          return false;
        }
      }
    }
    return true;
  }

  void _guardarJuego() {
    setState(() {
      juegos.add({
        'numero': _numeroControllers.last.text.isEmpty
            ? '0'
            : _numeroControllers.last.text.trim(),
        'apuesta': _apuestaControllers.last.text.isEmpty
            ? '0'
            : _apuestaControllers.last.text,
        'combinado': _combinadoControllers.last.text.isEmpty ? false : true,
        'combinadoApuesta': _combinadoControllers.last.text.isEmpty
            ? '0'
            : _combinadoControllers.last.text,
        'isNueva': false,
        'isGuardado': true,
      });
      _numeroControllers.add(TextEditingController());
      _apuestaControllers.add(TextEditingController());
      _combinadoControllers.add(TextEditingController());
    });
  }

  Future<bool> validarTopes({
    required String numero,
    required int apuesta,
    required String combinadoApuesta,
  }) async {
    try {
      final loteriaIds = widget.sorteosSeleccionados
          .map((e) => double.parse(e.loteriaId))
          .toList();
      final topeService = TopeService();

      final resultado = await topeService.validarTope(
        loteriaIds: loteriaIds,
        numero: numero,
        apuestaNumero: apuesta,
        apuestaCombinado: int.tryParse(combinadoApuesta) ?? 0,
      );

      if (resultado['Status'] == 'Fail') {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Alerta'),
              content: Text(resultado['Mensaje']),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cerrar'),
                ),
              ],
            );
          },
        );
        return false;
      }

      return true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al validar tope')),
      );
      return false;
    }
  }

  void enviarMensaje(int ticket) async {
    if (validarTelefono()) {
      try {
        final smsService service = smsService();
        final resultado = await service.enviarSms(ticket);

        final String status = resultado['Status'] ?? 'Fail';
        final String mensaje = resultado['Mensaje'] ?? 'Respuesta desconocida';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              status == 'OK' ? 'SMS enviado correctamente' : 'Error: $mensaje',
            ),
          ),
        );

        // Esperar 1 segundo antes de navegar
        await Future.delayed(const Duration(seconds: 1));
        Navigator.pushNamedAndRemoveUntil(
          context,
          'inicial',
          (route) => false,
          arguments: true,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El teléfono no es válido')),
      );
    }
  }

  Future<bool> mostrarDialogoConfirmarApuesta(
    BuildContext context,
    List<Map<String, dynamic>> juegos,
    List<Loteria> sorteosSeleccionados,
  ) async {
    final nombresResumen =
        sorteosSeleccionados.map((s) => s.nombre.trim()).join(', ');

    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text(
              'Confirmar Apuesta',
              style:
                  TextStyle(color: colorPrincipal, fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Sorteos seleccionados:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  const SizedBox(height: 5),
                  Text(
                    nombresResumen,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 15),
                  const Text('Juegos realizados:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  const SizedBox(height: 10),
                  ...juegos.map((juego) => ListTile(
                        leading: const Icon(Icons.confirmation_number,
                            color: colorPrincipal),
                        title: Text(
                          'Número: ${juego['numero']}',
                          style: const TextStyle(fontSize: 18),
                        ),
                        subtitle: Text(
                          'Apuesta: ${juego['apuesta']} | Combinado: ${juego['combinadoApuesta']}',
                          style: const TextStyle(fontSize: 18),
                        ),
                      )),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.attach_money,
                        size: 25,
                        color: colorPrincipal,
                      ),
                      Text(
                        'TOTAL: ${formatoMoneda.format(totalApuesta())}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      )
                    ],
                  )
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Editar',
                    style: TextStyle(color: colorPrincipal, fontSize: 16)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Confirmar',
                    style: TextStyle(color: colorPrincipal, fontSize: 16)),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> procesarVenta(BuildContext context) async {
    try {
      final ventaService = JuegoService();
      final resultado = await ventaService.crearVenta(
        cliente: '',
        celular: _telefonoController.text.trim(),
        juegos: juegos,
        sorteos: widget.sorteosSeleccionados,
      );

      if (!mounted) return;

      final mensaje = resultado['mensaje'] ?? 'Apuesta procesada';
      final numeroJuego = resultado['numeroJuego'] ?? 'N/A';

      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(mensaje),
          content: Text(
            'Número de Juego: $numeroJuego',
            style: const TextStyle(fontSize: 18),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Continuar',
                  style: TextStyle(color: colorPrincipal, fontSize: 16)),
            ),
          ],
        ),
      );

      mostrarResumen(context, juegos, widget.sorteosSeleccionados, numeroJuego);
    } catch (e) {
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Error'),
          content:
              const Text('No se pudo subir la apuesta. Intenta nuevamente.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  const Text('Cerrar', style: TextStyle(color: colorPrincipal)),
            ),
          ],
        ),
      );
    }
  }

  Future<void> mostrarResumen(
      BuildContext context,
      List<Map<String, dynamic>> juegos,
      List<Loteria> sorteosSeleccionados,
      String referencia) async {
    // Obtener los nombres para mostrar en el resumen
    String nombresResumen =
        sorteosSeleccionados.map((sorteo) => sorteo.nombre.trim()).join(', ');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Apuesta Realizada \n#$referencia',
            style: const TextStyle(
                color: colorPrincipal, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Sorteos seleccionados:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(height: 5),
              Text(
                nombresResumen,
                style: const TextStyle(color: Colors.black87, fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              const Text(
                'Juegos realizados:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(height: 10),
              ...juegos.map((juego) => ListTile(
                    leading:
                        const Icon(Icons.attach_money, color: colorPrincipal),
                    title: Text(
                      'Número: ${juego['numero']}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    subtitle: Text(
                      'Apuesta: ${juego['apuesta']} | Combinado: ${juego['combinadoApuesta']}',
                      style: const TextStyle(fontSize: 18),
                    ),
                  )),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                enviarMensaje(int.parse(referencia));
              },
              child: const Text(
                'Enviar comprobante',
                style: TextStyle(color: colorPrincipal, fontSize: 16),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  'inicial',
                  (route) => false,
                  arguments: true,
                );
              },
              child: const Text(
                'Cerrar',
                style: TextStyle(color: colorPrincipal, fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }
}
