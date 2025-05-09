import 'package:intl/intl.dart';

class Carga {
  final int? id;
  final DateTime fecha;
  final int kmS;
  final int monto;
  final int precio;
  final Carga? cargaSiguiente; // No se guarda en DB, solo para lógica en memoria

  Carga({
    this.id,
    required this.fecha,
    required this.kmS,
    required this.monto,
    required this.precio,
    this.cargaSiguiente,
  });

  /// Calcula el rendimiento con respecto a la carga siguiente, si está disponible
  int? get rendimiento {
    if (cargaSiguiente != null) {
      return cargaSiguiente!.kmS - kmS;
    }
    return null; // o 0, según lo que prefieras
  }

  // Getter para obtener la fecha formateada
  String get fechaFormateada {
    final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');
    return formatter.format(fecha);
  }

  // Getter para obtener solo la fecha sin hora
  String get soloFecha {
    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(fecha);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fecha': fecha.toIso8601String(),
      'kmS': kmS,
      'monto': monto,
      'precio': precio,
    };
  }

  factory Carga.fromMap(Map<String, dynamic> map) {
    DateTime parsedDate;
    
    try {
      // Intentamos formato ISO8601 (que incluye fecha y hora)
      parsedDate = DateTime.parse(map['fecha']);
    } catch (e) {
      // Para manejar casos donde la fecha está en formato dd/MM/yyyy
      try {
        final parts = map['fecha'].split('/');
        if (parts.length == 3) {
          final day = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final year = int.parse(parts[2]);
          // Asignamos la hora actual
          final now = DateTime.now();
          parsedDate = DateTime(year, month, day, now.hour, now.minute, now.second);
        } else {
          throw FormatException('Invalid date format ${map["fecha"]}');
        }
      } catch (e) {
        // Si todo falla, usamos la fecha actual
        print('Error parsing date: ${map["fecha"]}. Using current date.');
        parsedDate = DateTime.now();
      }
    }

    return Carga(
      id: map['id'],
      fecha: parsedDate,
      kmS: map['kmS'],
      monto: map['monto'],
      precio: map['precio'],
    );
  }
}