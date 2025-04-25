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
  int precioValue = 0;
  final TextEditingController _kmSController = TextEditingController();
  final TextEditingController _montoController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();
  final FocusNode _kmSFocusNode = FocusNode();
  final FocusNode _montoFocusNode = FocusNode();
  final TextEditingController _precioSuperShellController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _kmSController.dispose();
    _montoController.dispose();
    _fechaController.dispose();
    _kmSFocusNode.dispose();
    _montoFocusNode.dispose();
    super.dispose();
  }

  void _clearFields() {
    setState(() {
      fechaActualChecked = true;
      selectedDate = null;
      kmSValue = '';
      montoValue = '';
      precioValue = 0;
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
              labelText: 'Precio NAFTA',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                precioValue = int.tryParse(value) ?? 0;
              });
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
              if (kmSValue.isEmpty || montoValue.isEmpty || precioValue <= 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Complete todos los campos correctamente')),
    );
    return;
  }
              DateTime fecha = fechaActualChecked
                  ? DateTime.now()
                  : selectedDate ?? DateTime.now();

              final nuevaCarga = Carga(
                fecha: fecha,
                kmS: kmSValue,
                monto: montoValue,
                precio: precioValue,
              );
               try {
    await context.read<MyAppState>().agregarCarga(nuevaCarga);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Datos agregados correctamente')),
    );
    _clearFields();
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al guardar: ${e.toString()}')),
    );
  }
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
