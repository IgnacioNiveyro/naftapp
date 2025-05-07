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

    await deleteDatabase(path); /** Borra la bd cada vez q inicio la app */

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
        kmS INTEGER NOT NULL,
        monto INTEGER NOT NULL,
        precio INTEGER NOT NULL
      )
    ''');
    
    // Cargar datos iniciales
    await _cargarDatosIniciales(db);
  }
  
  Future<void> _cargarDatosIniciales(Database db) async {
    // Lista de cargas iniciales [fecha, km, monto, precio]
    final List<Map<String, dynamic>> cargasIniciales = [
      {'fecha': '02/01/2025', 'kmS': 8673, 'monto': 7000, 'precio': 1296},
      {'fecha': '22/01/2025', 'kmS': 8855, 'monto': 7000, 'precio': 1273},
      {'fecha': '09/02/2025', 'kmS': 9000, 'monto': 5000, 'precio': 1282},
      {'fecha': '23/02/2025', 'kmS': 9165, 'monto': 11100, 'precio': 1306},
      {'fecha': '03/03/2025', 'kmS': 9424, 'monto': 8800, 'precio': 1354},
      {'fecha': '10/03/2025', 'kmS': 9709, 'monto': 7000, 'precio': 1346},
      {'fecha': '28/03/2025', 'kmS': 9833, 'monto': 9600, 'precio': 1548},
      {'fecha': '05/04/2025', 'kmS': 10151, 'monto': 5000, 'precio': 1389},
      {'fecha': '12/04/2025', 'kmS': 10248, 'monto': 5000, 'precio': 1389},
      {'fecha': '27/04/2025', 'kmS': 10421, 'monto': 6300, 'precio': 1370},
      {'fecha': '01/05/2025', 'kmS': 10481, 'monto': 7500, 'precio': 1361},
      {'fecha': '01/05/2025', 'kmS': 10696, 'monto': 6539, 'precio': 1271},
    ];
    
    // Insertar cada carga inicial
    for (final cargaData in cargasIniciales) {
      await db.insert('cargas', cargaData);
    }
  }

  Future<int> insertCarga(Carga carga) async {
    try {
      final db = await database;
      // Modificado para guardar fecha en formato dd/mm/yyyy
      final dia = carga.fecha.day.toString().padLeft(2, '0');
      final mes = carga.fecha.month.toString().padLeft(2, '0');
      final anio = carga.fecha.year.toString();
      
      return await db.insert(
        'cargas',
        {
          'fecha': '$dia/$mes/$anio',
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