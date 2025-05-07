/// Clase utilitaria para centralizar las validaciones de los campos de entrada
class InputValidators {
  /// Valida el campo de precio
  static String? validarPrecio(String? value) {
    if (value == null || value.isEmpty) {
      return 'Este campo es obligatorio';
    }
    if (int.tryParse(value) == null || int.parse(value) <= 0) {
      return 'Ingrese un precio válido';
    }
    return null;
  }
  
  /// Valida el campo de kilómetros
  static String? validarKilometros(String? value) {
    if (value == null || value.isEmpty) {
      return 'Este campo es obligatorio';
    } else if (int.tryParse(value) == null) {
      return 'Los kilómetros del vehículo deben ser un número';
    }
    return null;
  }
  
  /// Valida el campo de monto
  static String? validarMonto(String? value) {
    if (value == null || value.isEmpty) {
      return 'Este campo es obligatorio';
    }
    if (double.tryParse(value) == null || double.parse(value) <= 0) {
      return 'Ingrese un monto válido';
    }
    return null;
  }
}