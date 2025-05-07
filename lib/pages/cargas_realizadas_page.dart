import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:naftapp/providers/my_app_state.dart';

class CargasRealizadasPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var cargas = context.watch<MyAppState>().cargas;
    final dateFormat = DateFormat('dd/MM/yyyy');
    final theme = Theme.of(context);

    if (cargas.isEmpty) {
      return Center(
        child: Text(
          'No hay cargas realizadas.',
          style: theme.textTheme.bodyLarge,
        ),
      );
    }

    List<Widget> items = [];
    for (int i = 0; i < cargas.length; i++) {
      final carga = cargas[i];
      final litros = carga.monto / carga.precio;

      items.add(
        Card(
          color: theme.colorScheme.surfaceVariant,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Carga ${dateFormat.format(carga.fecha)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _buildDeleteButton(context, carga),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'KM: ${carga.kmS} - Monto: \$${carga.monto}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Precio: \$${carga.precio}/L - Litros: ${litros.toStringAsFixed(2)}L',
                  style: theme.textTheme.bodyMedium,
                ),
                if (i > 0) ...[
                  const SizedBox(height: 12),
                  _buildRendimientoText(context, cargas[i - 1].kmS, carga.kmS),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return ListView(children: items);
  }

  Widget _buildRendimientoText(
    BuildContext context,
    int kmCargaAnterior,
    int kmCargaActual,
  ) {
    final kmAnterior = kmCargaAnterior;
    final kmActual = kmCargaActual;
    final diferenciaKm = kmAnterior - kmActual;
    final theme = Theme.of(context);
    final isPositivo = diferenciaKm > 0;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: 'Kilometros recorridos: ',
              style: theme.textTheme.bodyMedium,
            ),
            TextSpan(
              text: '$diferenciaKm km',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isPositivo
                    ? theme.colorScheme.primary
                    : theme.colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context, carga) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.centerRight,
      child: IconButton(
        icon: Icon(Icons.delete, color: theme.colorScheme.primary),
        onPressed: () async {
          final confirmacion = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Confirmar eliminación'),
              content: const Text('¿Desea eliminar esta carga de combustible?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(
                    'Eliminar',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),
              ],
            ),
          );

          if (confirmacion == true) {
            context.read<MyAppState>().eliminarCarga(carga);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Carga eliminada correctamente'),
                backgroundColor: theme.colorScheme.inverseSurface,
              ),
            );
          }
        },
      ),
    );
  }
}
