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
  }

  Future<void> insertCarga(Carga carga) async {
    final db = await database;
    await db.insert(
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
      );
    });
  }
}
