import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:naftapp/models/carga.dart';
import 'package:intl/intl.dart'; // Añadido para formateo de fechas

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
        fecha TEXT NOT NULL, /* Mantenemos TEXT pero almacenaremos ISO8601 para compatibilidad */
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
    final DateFormat parser = DateFormat('dd/MM/yyyy');
    
    final List<Map<String, dynamic>> cargasIniciales = [
      {'fecha': _convertirFechaAIso(parser.parse('02/01/2025'), DateTime.now()), 'kmS': 8673, 'monto': 7000, 'precio': 1296},
      {'fecha': _convertirFechaAIso(parser.parse('22/01/2025'), DateTime.now()), 'kmS': 8855, 'monto': 7000, 'precio': 1273},
      {'fecha': _convertirFechaAIso(parser.parse('09/02/2025'), DateTime.now()), 'kmS': 9000, 'monto': 5000, 'precio': 1282},
      {'fecha': _convertirFechaAIso(parser.parse('23/02/2025'), DateTime.now()), 'kmS': 9165, 'monto': 11100, 'precio': 1306},
      {'fecha': _convertirFechaAIso(parser.parse('03/03/2025'), DateTime.now()), 'kmS': 9424, 'monto': 8800, 'precio': 1354},
      {'fecha': _convertirFechaAIso(parser.parse('10/03/2025'), DateTime.now()), 'kmS': 9709, 'monto': 7000, 'precio': 1346},
      {'fecha': _convertirFechaAIso(parser.parse('28/03/2025'), DateTime.now()), 'kmS': 9833, 'monto': 9600, 'precio': 1548},
      {'fecha': _convertirFechaAIso(parser.parse('05/04/2025'), DateTime.now()), 'kmS': 10151, 'monto': 5000, 'precio': 1389},
      {'fecha': _convertirFechaAIso(parser.parse('12/04/2025'), DateTime.now()), 'kmS': 10248, 'monto': 5000, 'precio': 1389},
      {'fecha': _convertirFechaAIso(parser.parse('27/04/2025'), DateTime.now()), 'kmS': 10421, 'monto': 6300, 'precio': 1370},
      {'fecha': _convertirFechaAIso(parser.parse('01/05/2025'), DateTime.now()), 'kmS': 10481, 'monto': 7500, 'precio': 1361},
      {'fecha': _convertirFechaAIso(parser.parse('01/05/2025'), DateTime.now().add(Duration(hours: 5))), 'kmS': 10696, 'monto': 6539, 'precio': 1271},
    ];
    
    // Insertar cada carga inicial
    for (final cargaData in cargasIniciales) {
      await db.insert('cargas', cargaData);
    }
  }

  // Convertir una fecha en formato dd/MM/yyyy a ISO8601 con hora actual
  String _convertirFechaAIso(DateTime fecha, DateTime horaActual) {
    return DateTime(
      fecha.year,
      fecha.month,
      fecha.day,
      horaActual.hour,
      horaActual.minute,
      horaActual.second,
    ).toIso8601String();
  }

  Future<int> insertCarga(Carga carga) async {
    try {
      final db = await database;
      
      // Ahora guardamos la fecha completa en formato ISO8601
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