import 'package:flutter/material.dart';
import 'package:naftapp/pages/generator/widgets/dialogo_confirmacion.dart';
import 'package:naftapp/models/carga.dart';
import 'package:provider/provider.dart';
import 'package:naftapp/providers/my_app_state.dart';
import 'package:intl/intl.dart';

/// Controlador para la página de generación de cargas de combustible
/// Maneja la lógica de negocio y el estado de la UI
class GeneratorController {
  final BuildContext context;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  
  // Controladores para los campos de texto
  final TextEditingController fechaController = TextEditingController();
  final TextEditingController precioController = TextEditingController();
  final TextEditingController kmSController = TextEditingController();
  final TextEditingController montoController = TextEditingController();
  
  // Nodos de foco para controlar el teclado
  final FocusNode precioFocusNode = FocusNode(canRequestFocus: false);
  final FocusNode kmsFocusNode = FocusNode(canRequestFocus: false);
  final FocusNode montoFocusNode = FocusNode(canRequestFocus: false);
  
  // Estado de la UI
  bool fechaActualChecked = true;
  DateTime selectedDate = DateTime.now();
  
  // Valores numéricos parseados
  double precioValue = 0.0;
  double kmSValue = 0.0;
  double montoValue = 0.0;

  GeneratorController({required this.context});

  void initialize() {
    // Inicializar la fecha en el controlador con formato que incluye hora
    final now = DateTime.now();
    final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');
    final formattedDate = formatter.format(now);
    fechaController.text = formattedDate;
    
    // Configurar los focus nodes para que no requieran foco automáticamente
    precioFocusNode.canRequestFocus = true;
    kmsFocusNode.canRequestFocus = true;
    montoFocusNode.canRequestFocus = true;
    
    // Cargar el último precio utilizado
    _cargarUltimoPrecio();
  }

  Future<void> _cargarUltimoPrecio() async {
    final ultimoPrecio = await Provider.of<MyAppState>(context, listen: false).obtenerUltimoPrecio();
    if (ultimoPrecio != null) {
      precioController.text = ultimoPrecio.toString();
      precioValue = ultimoPrecio.toDouble();
    }
  }

  void dispose() {
    // Liberar recursos
    fechaController.dispose();
    precioController.dispose();
    kmSController.dispose();
    montoController.dispose();
    
    precioFocusNode.dispose();
    kmsFocusNode.dispose();
    montoFocusNode.dispose();
  }

  void setFechaActual(bool? value) {
    if (value != null) {
      fechaActualChecked = value;
      if (value) {
        selectedDate = DateTime.now();
        final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');
        fechaController.text = formatter.format(selectedDate);
      }
    }
  }

  Future<void> selectDate(BuildContext context) async {
    // Mostrar selector de fecha
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    
    if (pickedDate != null) {
      // Mostrar selector de hora
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedDate),
      );
      
      if (pickedTime != null) {
        // Combinar fecha y hora seleccionadas
        selectedDate = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        
        // Actualizar el texto del controlador
        final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');
        fechaController.text = formatter.format(selectedDate);
        
        // IMPORTANTE: Marcar como fecha personalizada cuando se selecciona una fecha
        fechaActualChecked = false;
      }
    }
  }

  void setPrecioValue(String value) {
    precioValue = double.tryParse(value) ?? 0.0;
  }

  void setKmSValue(String value) {
    kmSValue = double.tryParse(value) ?? 0.0;
  }

  void setMontoValue(String value) {
    montoValue = double.tryParse(value) ?? 0.0;
  }

  // Verificar que los kilómetros sean consistentes con las cargas existentes
  Future<bool> _verificarKilometros(int nuevoKm) async {
    final myAppState = Provider.of<MyAppState>(context, listen: false);
    final cargas = List<Carga>.from(myAppState.cargas);
    
    // Crear nueva carga temporal para simular la inserción
    final nuevaCarga = Carga(
      fecha: selectedDate, // Usar la fecha seleccionada independientemente
      kmS: nuevoKm,
      monto: montoValue.toInt(),
      precio: precioValue.toInt(),
    );
    
    // Añadir temporalmente la nueva carga y ordenar
    cargas.add(nuevaCarga);
    cargas.sort((a, b) => b.fecha.compareTo(a.fecha)); // Más reciente arriba
    
    final index = cargas.indexOf(nuevaCarga);
    bool kmValido = true;
    
    if (index == 0 && cargas.length > 1) {
      // Es la carga más reciente
      final siguienteKm = cargas[index + 1].kmS;
      if (nuevoKm < siguienteKm) kmValido = false;
    } else if (index == cargas.length - 1 && cargas.length > 1) {
      // Es la carga más antigua
      final anteriorKm = cargas[index - 1].kmS;
      if (nuevoKm > anteriorKm) kmValido = false;
    } else if (index > 0 && index < cargas.length - 1) {
      // Es una carga intermedia
      final anteriorKm = cargas[index - 1].kmS;
      final siguienteKm = cargas[index + 1].kmS;
      if (!(siguienteKm <= nuevoKm && nuevoKm <= anteriorKm)) kmValido = false;
    }
    
    return kmValido;
  }

  Future<void> _limpiarCampos() async {
    // Mantener el precio pero limpiar los demás campos
    kmSController.clear();
    montoController.clear();
    
    // Resetear valores
    kmSValue = 0.0;
    montoValue = 0.0;
    
    // Restablecer la fecha actual
    selectedDate = DateTime.now();
    final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');
    fechaController.text = formatter.format(selectedDate);
    fechaActualChecked = true; // Restablecer a fecha actual después de guardar
    
    // Asegurarse de que ningún campo reciba el foco después de limpiar
    precioFocusNode.canRequestFocus = false;
    kmsFocusNode.canRequestFocus = false;
    montoFocusNode.canRequestFocus = false;
    
    // Programar una reactivación posterior de la capacidad de foco
    Future.delayed(Duration(milliseconds: 300), () {
      if (mounted()) {
        precioFocusNode.canRequestFocus = true;
        kmsFocusNode.canRequestFocus = true;
        montoFocusNode.canRequestFocus = true;
      }
    });
  }

  // Verifica si el controlador aún está activo (no ha sido desechado)
  bool mounted() {
    try {
      return context.mounted;
    } catch (e) {
      return false;
    }
  }

  void procesarFormulario() async {
    // Quitar el foco para cerrar el teclado
    FocusScope.of(context).unfocus();
    
    // Deshabilitar temporalmente la capacidad de foco en los campos
    precioFocusNode.canRequestFocus = false;
    kmsFocusNode.canRequestFocus = false;
    montoFocusNode.canRequestFocus = false;
    
    if (formKey.currentState?.validate() ?? false) {
      // Calcular litros
      final litros = montoValue / precioValue;
      
      // CORREGIDO: Usar siempre selectedDate en lugar de condicional
      final fecha = selectedDate;
      
      // Mostrar diálogo de confirmación
      final confirmed = await showConfirmationDialog(
        context: context,
        fecha: fecha,
        kmSValue: kmSController.text,
        montoValue: montoController.text,
        precioValue: precioController.text,
        litros: litros,
      );
      
      if (confirmed == true) {
        // Verificar que los kilómetros sean consistentes
        final kmSInt = kmSValue.toInt();
        final kmValido = await _verificarKilometros(kmSInt);
        
        if (!kmValido) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: Los kilómetros no son consistentes con las otras cargas.'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
          
          // Reactivar la capacidad de foco después de mostrar el error
          _reactivarFocos();
          return;
        }
        
        // Crear el objeto carga - CORREGIDO: Usar selectedDate
        final nuevaCarga = Carga(
          fecha: fecha,
          kmS: kmSInt,
          monto: montoValue.toInt(),
          precio: precioValue.toInt(),
        );
        
        try {
          // Guardar en la base de datos
          await Provider.of<MyAppState>(context, listen: false).agregarCarga(nuevaCarga);
          
          // Limpiar los campos después de guardar
          await _limpiarCampos();
          
          // Mostrar mensaje de éxito
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Datos guardados correctamente'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
        } catch (e) {
          // Mostrar error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al guardar: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
          
          // Reactivar la capacidad de foco después de mostrar el error
          _reactivarFocos();
        }
      } else {
        // Si el usuario cancela, reactivar los focos después de un breve retraso
        _reactivarFocos();
      }
    } else {
      // Si la validación falla, reactivar los focos después de un breve retraso
      _reactivarFocos();
    }
  }
  
  // Método auxiliar para reactivar la capacidad de foco después de un retraso
  void _reactivarFocos() {
    // Reactivar después de un breve retraso para evitar que se enfoque inmediatamente
    Future.delayed(Duration(milliseconds: 300), () {
      if (mounted()) {
        precioFocusNode.canRequestFocus = true;
        kmsFocusNode.canRequestFocus = true;
        montoFocusNode.canRequestFocus = true;
      }
    });
  }
}