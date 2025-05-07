import 'package:flutter/material.dart';

/// Widget para mostrar un campo de selección de fecha
class DateSelectorWidget extends StatelessWidget {
  final TextEditingController fechaController;
  final VoidCallback selectDate;

  const DateSelectorWidget({
    Key? key,
    required this.fechaController,
    required this.selectDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: fechaController,
      readOnly: true,
      decoration: const InputDecoration(
        labelText: 'Fecha *',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.calendar_today),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Seleccione una fecha';
        }
        return null;
      },
      onTap: selectDate,
    );
  }
}
