class EstacionServicio {
  final int? id;
  final String nombre;
  final int superPrecio;
  final int premium;
  final int diesel;
  final int gasoil;
  final int gas;

  EstacionServicio({
    this.id,
    required this.nombre,
    required this.superPrecio,
    required this.premium,
    required this.diesel,
    required this.gasoil,
    required this.gas,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'super': superPrecio,
      'premium': premium,
      'diesel': diesel,
      'gasoil': gasoil,
      'gas': gas,
    };
  }

  factory EstacionServicio.fromMap(Map<String, dynamic> map) {
    return EstacionServicio(
      id: map['id'],
      nombre: map['nombre'],
      superPrecio: map['super'],
      premium: map['premium'],
      diesel: map['diesel'],
      gasoil: map['gasoil'],
      gas: map['gas'],
    );
  }
}
