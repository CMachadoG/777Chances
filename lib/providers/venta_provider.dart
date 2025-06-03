import 'package:chances/services/venta_service.dart';
import 'package:flutter/material.dart';
import '../models/venta_model.dart';

class VentasProvider extends ChangeNotifier {
  final VentasService _service = VentasService();

  VentasResponse? _ventas;
  bool _loading = false;
  String? _error;

  VentasResponse? get ventas => _ventas;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> fetchVentas(String desde, String hasta) async {
    _loading = true;
    _error = null;
    _ventas = null;
    notifyListeners();

    try {
      _ventas = await _service.getVentas(desde, hasta);
    } catch (e) {
      _ventas = null; // Limpiar ventas anteriores
      _error = e.toString();
    }

    _loading = false;
    notifyListeners();
  }
}
