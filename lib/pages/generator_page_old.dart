import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:naftapp/models/carga.dart';
import 'package:provider/provider.dart';
import 'package:naftapp/providers/my_app_state.dart';

class GeneratorPage extends StatefulWidget {
  @override
  State<GeneratorPage> createState() => _GeneratorPageState();
}

class _GeneratorPageState extends State<GeneratorPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Focus nodes específicos para cada campo
  final _precioFocusNode = FocusNode();
  final _kmsFocusNode = FocusNode();
  final _montoFocusNode = FocusNode();

  bool fechaActualChecked = true;
  DateTime? selectedDate;
  String kmSValue = '';
  String montoValue = '';
  String precioValue = '';

  final TextEditingController _kmSController = TextEditingController();
  final TextEditingController _montoController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Asegurar que el sistema esté listo para mostrar el teclado
    //SystemChannels.textInput.invokeMethod('TextInput.show');
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarUltimoPrecio();
    });
  }

  Future<void> _cargarUltimoPrecio() async {
    final ultimoPrecio = await context.read<MyAppState>().obtenerUltimoPrecio();
    if (ultimoPrecio != null && mounted) {
      _precioController.text = ultimoPrecio.toString();
      precioValue = ultimoPrecio.toString();
    }
  }

  @override
  void dispose() {
    _kmSController.dispose();
    _montoController.dispose();
    _fechaController.dispose();
    _precioController.dispose();
    _precioFocusNode.dispose();
    _kmsFocusNode.dispose();
    _montoFocusNode.dispose();
    super.dispose();
  }

  Future<void> _clearFields() async {
    // No usar unfocus aquí para mantener el teclado abierto
    await Future.delayed(Duration(milliseconds: 50));
    if (!mounted) return;

    _kmSController.clear();
    _montoController.clear();
    _fechaController.clear();
    // No limpiar el precio

    setState(() {
      fechaActualChecked = true;
      selectedDate = null;
      kmSValue = '';
      montoValue = '';
      // No limpiar precioValue
    });
    
    // Dar foco al primer campo para la siguiente entrada
    _kmsFocusNode.requestFocus();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate && mounted) {
      setState(() {
        selectedDate = picked;
        _fechaController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      // Usar resizeToAvoidBottomInset para manejar el teclado adecuadamente
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        // Asegurar que el contenido se desplace cuando aparece el teclado
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Text('Usar fecha actual', style: theme.textTheme.bodyMedium),
                    Checkbox(
                      value: fechaActualChecked,
                      onChanged: (bool? value) {
                        setState(() {
                          fechaActualChecked = value ?? true;
                          if (fechaActualChecked) {
                            _fechaController.clear();
                            selectedDate = null;
                          }
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                GestureDetector(
                  // Asegurar que el toque en este área active el teclado
                  onTap: () {
                    _precioFocusNode.requestFocus();
                  },
                  child: TextFormField(
                    controller: _precioController,
                    focusNode: _precioFocusNode,
                    keyboardType: TextInputType.number,
                    // Asegurar que se muestre el teclado numérico
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'Precio NAFTA por litro*',
                      hintText: 'Ingrese precio por litro',
                      border: const OutlineInputBorder(),
                      prefixText: '\$ ',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Este campo es obligatorio';
                      }
                      if (int.tryParse(value) == null || int.parse(value) <= 0) {
                        return 'Ingrese un precio válido';
                      }
                      return null;
                    },
                    onChanged: (value) => precioValue = value,
                    onTap: () {
                      // Forzar la apertura del teclado en el tap
                      _precioFocusNode.requestFocus();
                    },
                    onEditingComplete: () {
                      // Pasar al siguiente campo al completar
                      FocusScope.of(context).requestFocus(_kmsFocusNode);
                    },
                  ),
                ),
                const SizedBox(height: 25),
                if (!fechaActualChecked) ...[
                  TextFormField(
                    controller: _fechaController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Fecha *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Seleccione una fecha';
                      }
                      return null;
                    },
                    onTap: () => _selectDate(context),
                  ),
                  const SizedBox(height: 20),
                ],
                GestureDetector(
                  onTap: () {
                    _kmsFocusNode.requestFocus();
                  },
                  child: TextFormField(
                    controller: _kmSController,
                    focusNode: _kmsFocusNode,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Kilómetros vehículo *',
                      hintText: 'Ingrese los km de su vehículo',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Este campo es obligatorio';
                      } else if (int.tryParse(value) == null) {
                        return 'Los kilómetros del vehículo deben ser un número';
                      }
                      return null;
                    },
                    onChanged: (value) => kmSValue = value,
                    onTap: () {
                      _kmsFocusNode.requestFocus();
                    },
                    onEditingComplete: () {
                      FocusScope.of(context).requestFocus(_montoFocusNode);
                    },
                  ),
                ),
                const SizedBox(height: 25),
                GestureDetector(
                  onTap: () {
                    _montoFocusNode.requestFocus();
                  },
                  child: TextFormField(
                    controller: _montoController,
                    focusNode: _montoFocusNode,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: 'Monto *',
                      hintText: 'Ingrese monto a cargar',
                      prefixText: '\$ ',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Este campo es obligatorio';
                      }
                      if (double.tryParse(value) == null ||
                          double.parse(value) <= 0) {
                        return 'Ingrese un monto válido';
                      }
                      return null;
                    },
                    onChanged: (value) => montoValue = value,
                    onTap: () {
                      _montoFocusNode.requestFocus();
                    },
                  ),
                ),
                const SizedBox(height: 25),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // No usar unfocus aquí para mantener el teclado abierto si hay error
                      await Future.delayed(Duration(milliseconds: 100));

                      DateTime fecha = fechaActualChecked
                          ? DateTime.now()
                          : selectedDate ?? DateTime.now();

                      double litros =
                          (int.tryParse(montoValue) ?? 0) / (int.tryParse(precioValue) ?? 1);

                      bool confirmado = await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Confirmar datos',
                              style: theme.textTheme.titleLarge),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Fecha: ${fecha.toLocal().toString().split(' ')[0]}'),
                              Text('KM: $kmSValue'),
                              Text('Monto: \$$montoValue'),
                              Text('Precio por litro: \$$precioValue'),
                              Text('Litros: ${litros.toStringAsFixed(2)}'),
                              const SizedBox(height: 25),
                              Text('¿Confirmar estos datos?',
                                  style: theme.textTheme.bodyMedium),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: Text('Cancelar',
                                  style: TextStyle(color: colorScheme.error)),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: Text('Confirmar',
                                  style: TextStyle(color: colorScheme.primary)),
                            ),
                          ],
                        ),
                      );

                      if (confirmado == true && mounted) {
                        final nuevaCarga = Carga(
                          fecha: fecha,
                          kmS: int.tryParse(kmSValue) ?? 0,
                          monto: int.tryParse(montoValue) ?? 0,
                          precio: int.tryParse(precioValue) ?? 0,
                        );

                        try {
                          final cargas =
                              List<Carga>.from(context.read<MyAppState>().cargas);
                          cargas.add(nuevaCarga);
                          cargas.sort((a, b) =>
                              b.fecha.compareTo(a.fecha)); // Más reciente arriba

                          final index = cargas.indexOf(nuevaCarga);

                          bool kmValido = true;
                          final nuevoKm = nuevaCarga.kmS;

                          if (index == 0 && cargas.length > 1) {
                            final siguienteKm =
                                cargas[index + 1].kmS;
                            if (nuevoKm < siguienteKm) kmValido = false;
                          } else if (index == cargas.length - 1 &&
                              cargas.length > 1) {
                            final anteriorKm =
                                cargas[index - 1].kmS;
                            if (nuevoKm > anteriorKm) kmValido = false;
                          } else if (index > 0 && index < cargas.length - 1) {
                            final anteriorKm =
                                cargas[index - 1].kmS;
                            final siguienteKm =
                                cargas[index + 1].kmS;
                            if (!(siguienteKm <= nuevoKm &&
                                nuevoKm <= anteriorKm)) kmValido = false;
                          }

                          if (!kmValido) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Error: Los kilómetros no son consistentes con las otras cargas.'),
                                backgroundColor: colorScheme.error,
                              ),
                            );
                            return;
                          }

                          await context.read<MyAppState>().agregarCarga(nuevaCarga);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Datos agregados correctamente'),
                                backgroundColor: colorScheme.primaryContainer,
                              ),
                            );
                            await _clearFields();
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('Error al guardar: ${e.toString()}'),
                                backgroundColor: colorScheme.error,
                              ),
                            );
                          }
                        }
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                  ),
                  child: Text('Agregar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}