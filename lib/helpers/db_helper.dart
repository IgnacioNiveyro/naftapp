import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:naftapp/models/carga.dart';

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
        monto TEXT NOT NULL,
        precio INTEGER NOT NULL
      )
    ''');
  }

Future<int> insertCarga(Carga carga) async {
  try {
    final db = await database;
    return await db.insert(
      'cargas',
      {
        'fecha': carga.fecha.toIso8601String(),
        'kmS': carga.kmS,
        'monto': carga.monto,
        'precio': carga.precio,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  } catch (e) {
    print('Error inserting carga: $e');
    rethrow;
  }
}


  Future<List<Carga>> getCargas() async {
  final db = await database;
  final List<Map<String, dynamic>> maps = await db.query('cargas');
  return maps.map((map) => Carga.fromMap(map)).toList();
}


  Future<void> deleteCarga(int id) async {
    final db = await database;
    await db.delete(
      'cargas',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

}
