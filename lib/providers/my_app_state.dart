import 'package:flutter/foundation.dart';
import 'package:naftapp/models/carga.dart';
import 'package:naftapp/helpers/db_helper.dart';

class MyAppState extends ChangeNotifier {
  final List<Carga> _cargas = [];
  final DBHelper _dbHelper = DBHelper();

  List<Carga> get cargas => List.unmodifiable(_cargas);

  MyAppState() {
    _loadCargas();
  }

  Future<int?> obtenerUltimoPrecio() async {
    final cargas = await _dbHelper.getCargas();
    if (cargas.isNotEmpty) {
      return cargas.last.precio;
    }
    return null;
  }

  Future<void> agregarCarga(Carga carga) async {
    try {
      final id = await _dbHelper.insertCarga(carga);

      final cargaConId = Carga(
        id: id,
        fecha: carga.fecha,
        kmS: carga.kmS,
        monto: carga.monto,
        precio: carga.precio,
      );

      _cargas.add(cargaConId);
      _cargas.sort((a, b) => b.fecha.compareTo(a.fecha));
      _asignarCargasSiguientes();
      notifyListeners();
    } catch (e) {
      print('Error adding carga: $e');
      rethrow;
    }
  }

  Future<void> eliminarCarga(Carga carga) async {
    await _dbHelper.deleteCarga(carga.id!);
    _cargas.removeWhere((c) => c.id == carga.id);
    _asignarCargasSiguientes();
    notifyListeners();
  }

  Future<void> _loadCargas() async {
    final cargasDesdeDB = await _dbHelper.getCargas();
    cargasDesdeDB.sort((a, b) => b.fecha.compareTo(a.fecha));
    _cargas.addAll(cargasDesdeDB);
    _asignarCargasSiguientes();
    notifyListeners();
  }

  void _asignarCargasSiguientes() {
    for (int i = 0; i < _cargas.length - 1; i++) {
      _cargas[i] = Carga(
        id: _cargas[i].id,
        fecha: _cargas[i].fecha,
        kmS: _cargas[i].kmS,
        monto: _cargas[i].monto,
        precio: _cargas[i].precio,
        cargaSiguiente: _cargas[i + 1],
      );
    }
    if (_cargas.isNotEmpty) {
      _cargas[_cargas.length - 1] = Carga(
        id: _cargas.last.id,
        fecha: _cargas.last.fecha,
        kmS: _cargas.last.kmS,
        monto: _cargas.last.monto,
        precio: _cargas.last.precio,
        cargaSiguiente: null,
      );
    }
  }
}
