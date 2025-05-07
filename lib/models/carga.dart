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
    // Parsear fecha - soporta tanto formato ISO como dd/mm/yyyy
    DateTime parsedDate;
    try {
      // Primero intentamos formato ISO
      parsedDate = DateTime.parse(map['fecha']);
    } catch (e) {
      // Si falla, intentamos formato dd/mm/yyyy
      final parts = map['fecha'].split('/');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        parsedDate = DateTime(year, month, day);
      } else {
        throw FormatException('Invalid date format ${map["fecha"]}');
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