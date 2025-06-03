import 'package:chances/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class ContactosScreen extends StatefulWidget {
  const ContactosScreen({super.key});

  @override
  State<ContactosScreen> createState() => _ContactosScreenState();
}

class _ContactosScreenState extends State<ContactosScreen> {
  List<Contact> contactos = [];
  List<Contact> contactosFiltrados = [];
  bool cargando = true;
  String busqueda = '';

  @override
  void initState() {
    super.initState();
    cargarContactos();
  }

  Future<void> cargarContactos() async {
    if (await FlutterContacts.requestPermission()) {
      final lista = await FlutterContacts.getContacts(withProperties: true);
      final conTelefono = lista.where((c) => c.phones.isNotEmpty).toList();
      setState(() {
        contactos = conTelefono;
        contactosFiltrados = conTelefono;
        cargando = false;
      });
    } else {
      setState(() => cargando = false);
    }
  }

  void filtrarContactos(String valor) {
    setState(() {
      busqueda = valor;
      contactosFiltrados = contactos
          .where(
              (c) => c.displayName.toLowerCase().contains(valor.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorFondoField,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: colorPrincipal,
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                barraSuperior(context, 0.07, "Contactos", 40, corner: "R"),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Buscar contacto',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: filtrarContactos,
                  ),
                ),
                Expanded(
                  child: contactosFiltrados.isEmpty
                      ? const Center(child: Text('No se encontraron contactos'))
                      : ListView.builder(
                          itemCount: contactosFiltrados.length,
                          itemBuilder: (_, index) {
                            final c = contactosFiltrados[index];
                            final numero = c.phones.first.number
                                .replaceAll(RegExp(r'\D'), '');
                            return ListTile(
                              title: Text(c.displayName),
                              subtitle: Text(numero),
                              onTap: () {
                                String limpio = numero;
                                if (limpio.startsWith('57') &&
                                    limpio.length > 10) {
                                  limpio = limpio.substring(2);
                                }
                                Navigator.pop(context, limpio);
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
