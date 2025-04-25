import 'package:flutter/foundation.dart';
import 'package:naftapp/models/carga.dart';
import 'package:naftapp/helpers/db_helper.dart';

class MyAppState extends ChangeNotifier {
  final List<Carga> _cargas = [];
  List<Carga> get cargas => List.unmodifiable(_cargas);
  
  MyAppState() {
    _loadCargas();
  }

 Future<void> agregarCarga(Carga carga) async {
  try {
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
  } catch (e) {
    print('Error adding carga: $e');
    rethrow;
  }
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
}
