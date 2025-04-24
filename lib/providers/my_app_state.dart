import 'package:flutter/foundation.dart';
import 'package:naftapp/models/carga.dart';
import 'package:naftapp/helpers/db_helper.dart';

class MyAppState extends ChangeNotifier {
  final List<Carga> _cargas = [];
  int? _precioSuperShell;
  List<Carga> get cargas => List.unmodifiable(_cargas);
  int? get precioSuperShell => _precioSuperShell;
  
  MyAppState() {
    _loadCargas();
    _loadPrecioSuperShell();
  }

  Future<void> _loadPrecioSuperShell() async {
    final dbHelper = DBHelper();
    _precioSuperShell = await dbHelper.getPrecioSuperShell();
    notifyListeners(); // Notificamos para que los widgets escuchando el estado se actualicen
  }

  // Añadimos este método para obtener el precio cuando sea necesario
  Future<int?> fetchPrecioSuperShell() async {
    if (_precioSuperShell == null) {
      await _loadPrecioSuperShell(); // Si aún no se ha cargado, lo cargamos
    }
    return _precioSuperShell;
  }

  Future<void> agregarCarga(Carga carga) async {
    final dbHelper = DBHelper();
    final id = await dbHelper.insertCarga(carga);

    final cargaConId = Carga(
      id: id,
      fecha: carga.fecha,
      kmS: carga.kmS,
      monto: carga.monto,
      precio: carga.precio,
    );

    _cargas.add(cargaConId);
    notifyListeners();
  }

  Future<void> _loadCargas() async {
    final cargasDesdeDB = await DBHelper().getCargas();
    _cargas.addAll(cargasDesdeDB);
    notifyListeners();
  }

  Future<void> eliminarCarga(Carga carga) async {
    final dbHelper = DBHelper();
    await dbHelper.deleteCarga(carga.id!);
    _cargas.removeWhere((c) => c.id == carga.id);
    notifyListeners();
  }

  Future<void> setPrecioSuperShell(int precio) async {
    final dbHelper = DBHelper();
    await dbHelper.updatePrecioSuperShell(precio);
    _precioSuperShell = precio;
    notifyListeners();
  }
}
