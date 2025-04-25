import 'package:flutter/material.dart';
import 'package:naftapp/models/carga.dart';
import 'package:provider/provider.dart';
import 'package:naftapp/providers/my_app_state.dart';

class GeneratorPage extends StatefulWidget {
  @override
  State<GeneratorPage> createState() => _GeneratorPageState();
}

class _GeneratorPageState extends State<GeneratorPage> {
  final _formKey = GlobalKey<FormState>();
  final FocusNode _focusNodeVacio = FocusNode();

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
    _focusNodeVacio.dispose();
    super.dispose();
  }

  Future<void> _clearFields() async {
    FocusManager.instance.primaryFocus?.unfocus();
    await Future.delayed(Duration(milliseconds: 50));
    if (!mounted) return;

    _kmSController.clear();
    _montoController.clear();
    _fechaController.clear();
    _precioController.clear();

    setState(() {
      fechaActualChecked = true;
      selectedDate = null;
      kmSValue = '';
      montoValue = '';
      precioValue = '';
    });
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
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
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
                  const Text('Usar fecha actual'),
                ],
              ),
              TextFormField(
                controller: _precioController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Precio NAFTA *',
                  hintText: 'Ingrese precio por litro',
                  border: OutlineInputBorder(),
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
              ),
              const SizedBox(height: 20),
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
              TextFormField(
                controller: _kmSController,
                decoration: const InputDecoration(
                  labelText: 'Kilómetros vehículo *',
                  hintText: 'Ingrese los km de su vehículo',	
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Este campo es obligatorio';
                  }
                  return null;
                },
                onChanged: (value) => kmSValue = value,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _montoController,
                decoration: const InputDecoration(
                  labelText: 'Monto *',
                  hintText: 'Ingrese monto a cargar',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Este campo es obligatorio';
                  }
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Ingrese un monto válido';
                  }
                  return null;
                },
                onChanged: (value) => montoValue = value,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    FocusScope.of(context).unfocus();
                    await Future.delayed(Duration(milliseconds: 100));

                    DateTime fecha = fechaActualChecked
                        ? DateTime.now()
                        : selectedDate ?? DateTime.now();

                    double litros = double.parse(montoValue) / int.parse(precioValue);

                    bool confirmado = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Confirmar datos'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Fecha: ${fecha.toLocal().toString().split(' ')[0]}'),
                            Text('KM: $kmSValue'),
                            Text('Monto: \$$montoValue'),
                            Text('Precio por litro: \$$precioValue'),
                            Text('Litros: ${litros.toStringAsFixed(2)}'),
                            const SizedBox(height: 20),
                            const Text('¿Confirmar estos datos?'),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Confirmar'),
                          ),
                        ],
                      ),
                    );

                    FocusScope.of(context).requestFocus(_focusNodeVacio);

                    if (confirmado == true && mounted) {
                      final nuevaCarga = Carga(
                        fecha: fecha,
                        kmS: kmSValue,
                        monto: montoValue,
                        precio: int.parse(precioValue),
                      );

                      try {
                        await context.read<MyAppState>().agregarCarga(nuevaCarga);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Datos agregados correctamente')),
                          );
                          await _clearFields();
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error al guardar: ${e.toString()}')),
                          );
                        }
                      }
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Agregar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
