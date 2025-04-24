import 'package:flutter/material.dart';
import 'package:naftapp/models/carga.dart';
import 'package:provider/provider.dart';
import 'package:naftapp/providers/my_app_state.dart';

class GeneratorPage extends StatefulWidget {
  @override
  State<GeneratorPage> createState() => _GeneratorPageState();
}

class _GeneratorPageState extends State<GeneratorPage> {
  bool fechaActualChecked = true;
  DateTime? selectedDate;
  String kmSValue = '';
  String montoValue = '';
  final TextEditingController _kmSController = TextEditingController();
  final TextEditingController _montoController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();
  final FocusNode _kmSFocusNode = FocusNode();
  final FocusNode _montoFocusNode = FocusNode();
  final TextEditingController _precioSuperShellController = TextEditingController();

  int? precioSuperActual;

  @override
  void initState() {
    super.initState();
    // Llamamos a fetchPrecioSuperShell para obtener el valor del precio
    _loadPrecio();
  }

  void _loadPrecio() async {
    final precio = await context.read<MyAppState>().fetchPrecioSuperShell();
    if (precio != null) {
      setState(() {
        precioSuperActual = precio;
        _precioSuperShellController.text = precio.toString();
      });
    }
  }

  @override
  void dispose() {
    _kmSController.dispose();
    _montoController.dispose();
    _fechaController.dispose();
    _kmSFocusNode.dispose();
    _montoFocusNode.dispose();
    _precioSuperShellController.dispose();
    super.dispose();
  }

  void _clearFields() {
    setState(() {
      fechaActualChecked = true;
      selectedDate = null;
      kmSValue = '';
      montoValue = '';
      _kmSController.clear();
      _montoController.clear();
      _fechaController.clear();
    });

    _kmSFocusNode.unfocus();
    _montoFocusNode.unfocus();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _fechaController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Checkbox Fecha actual
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
          TextField(
            controller: _precioSuperShellController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Precio SUPER - SHELL',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) async {
              final nuevoPrecio = int.tryParse(value);
              if (nuevoPrecio != null) {
                await context.read<MyAppState>().setPrecioSuperShell(nuevoPrecio);
                setState(() {
                  precioSuperActual = nuevoPrecio;
                });
              }
            },
          ),
          const SizedBox(height: 20),

          // Selector de fecha solo si el checkbox está desmarcado
          if (!fechaActualChecked) ...[
            TextField(
              controller: _fechaController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Fecha',
                border: OutlineInputBorder(),
              ),
              onTap: () => _selectDate(context),
            ),
            const SizedBox(height: 20),
          ],

          // Campo KM/S
          TextField(
            controller: _kmSController,
            focusNode: _kmSFocusNode,
            decoration: const InputDecoration(
              labelText: 'KM/S vehículo',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {
                kmSValue = value;
              });
            },
          ),
          const SizedBox(height: 20),

          // Campo Monto
          TextField(
            controller: _montoController,
            focusNode: _montoFocusNode,
            decoration: const InputDecoration(
              labelText: 'Monto',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {
                montoValue = value;
              });
            },
          ),
          const SizedBox(height: 30),

          // Botón Agregar
          ElevatedButton(
            onPressed: () async {
              DateTime fecha = fechaActualChecked
                  ? DateTime.now()
                  : selectedDate ?? DateTime.now();

              final nuevaCarga = Carga(
                fecha: fecha,
                kmS: kmSValue,
                monto: montoValue,
                precio: precioSuperActual ?? 0,
              );

              await context.read<MyAppState>().agregarCarga(nuevaCarga);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Datos agregados correctamente')),
              );

              _clearFields();
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }
}
