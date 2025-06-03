import 'package:chances/helpers/shared_preferences_helpers.dart';
import 'package:flutter/material.dart';
import '../models/loteria_model.dart';
import '../services/loteria_service.dart';

class LoteriaProvider extends ChangeNotifier {
  LoteriaProvider(this._api);

  final LoteriaApiService _api;

  List<Loteria> _loterias = [];
  List<Loteria> get loterias => _loterias;

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  /// Carga loterías usando el token guardado tras el login
  Future<void> cargarLoterias() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await getToken();

      _loterias = await _api.fetchLoterias(token!);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Limpia las loterías y fuerza recarga
  Future<void> refresh() async {
    _loterias = [];
    await cargarLoterias();
  }
}
