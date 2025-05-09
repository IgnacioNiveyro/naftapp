import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Muestra un diálogo de confirmación con los datos ingresados antes de guardarlos
Future<bool?> showConfirmationDialog({
  required BuildContext context,
  required DateTime fecha,
  required String kmSValue,
  required String montoValue,
  required String precioValue,
  required double litros,
}) async {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  
  // Formatter para mostrar fecha y hora
  final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');
  final String fechaFormateada = formatter.format(fecha);
  
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Confirmar datos', style: theme.textTheme.titleLarge),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Fecha: $fechaFormateada'),
          Text('KM: $kmSValue'),
          Text('Monto: \$$montoValue'),
          Text('Precio por litro: \$$precioValue'),
          Text('Litros: ${litros.toStringAsFixed(2)}'),
          const SizedBox(height: 25),
          Text('¿Confirmar estos datos?', style: theme.textTheme.bodyMedium),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text('Cancelar', style: TextStyle(color: colorScheme.error)),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text('Confirmar', style: TextStyle(color: colorScheme.primary)),
        ),
      ],
    ),
  );
}