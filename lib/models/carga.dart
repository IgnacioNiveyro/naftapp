class Carga {
  final int? id; // ID puede ser null cuando aún no se guarda en DB
  final DateTime fecha;
  final String kmS;
  final String monto;

  Carga({
    this.id,
    required this.fecha,
    required this.kmS,
    required this.monto,
  });

  // Para guardar en DB
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fecha': fecha.toIso8601String(),
      'kmS': kmS,
      'monto': monto,
    };
  }

  // Para leer desde DB
  factory Carga.fromMap(Map<String, dynamic> map) {
    return Carga(
      id: map['id'],
      fecha: DateTime.parse(map['fecha']),
      kmS: map['kmS'],
      monto: map['monto'],
    );
  }
}
