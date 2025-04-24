import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:naftapp/models/carga.dart';
import 'package:naftapp/models/estacion_servicio.dart';
class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;

  DBHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    return _database ??= await _initDB();
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'cargas.db');

    //await deleteDatabase(path); /** Borra la bd cada vez q inicio la app */

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE cargas(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fecha TEXT NOT NULL,
        kmS TEXT NOT NULL,
        monto TEXT NOT NULL
      )
    ''');
    await db.execute('''
    CREATE TABLE estaciones_servicio(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nombre TEXT NOT NULL,
      super INTEGER,
      premium INTEGER,
      diesel INTEGER,
      gasoil INTEGER,
      gas INTEGER
    )
  ''');
/** LUEGO BORRAR, SOLO PARA PRUEBAS */
    await db.insert(
      'estaciones_servicio',
      {
        'nombre': 'SHELL',
        'super': 1361,
        'premium': 1626,
        'diesel': 1374,
        'gasoil': 0,
        'gas': 0,
      },
    );


  }

  Future<int> insertCarga(Carga carga) async {
    final db = await database;
    return await db.insert(
      'cargas',
      {
        'fecha': carga.fecha.toIso8601String(),
        'kmS': carga.kmS,
        'monto': carga.monto,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Carga>> getCargas() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('cargas');

    return List.generate(maps.length, (i) {
      return Carga(
        fecha: DateTime.parse(maps[i]['fecha']),
        kmS: maps[i]['kmS'],
        monto: maps[i]['monto'],
        precio: maps[i]['precio'],
      );
    });
  }

  Future<void> deleteCarga(int id) async {
    final db = await database;
    await db.delete(
      'cargas',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> insertEstacion(EstacionServicio estacion) async {
  final db = await database;
  return await db.insert(
    'estaciones_servicio',
    estacion.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Future<List<EstacionServicio>> getEstaciones() async {
  final db = await database;
  final List<Map<String, dynamic>> maps = await db.query('estaciones_servicio');

  return List.generate(maps.length, (i) {
    return EstacionServicio.fromMap(maps[i]);
  });
}

Future<int?> getPrecioSuperShell() async {
  final db = await database;
  final result = await db.query(
    'estaciones_servicio',
    where: 'nombre = ?',
    whereArgs: ['SHELL'],
    limit: 1,
  );

  if (result.isNotEmpty) {
    return result.first['super'] as int;
  }
  return null;
}

Future<void> updatePrecioSuperShell(int nuevoPrecio) async {
  final db = await database;
  await db.update(
    'estaciones_servicio',
    {'super': nuevoPrecio},
    where: 'nombre = ?',
    whereArgs: ['SHELL'],
  );
}

}
