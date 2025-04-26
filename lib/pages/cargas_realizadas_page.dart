import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:naftapp/providers/my_app_state.dart';

class CargasRealizadasPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var cargas = context.watch<MyAppState>().cargas;
    final dateFormat = DateFormat('dd/MM/yyyy'); // 👈 Formateador

    if (cargas.isEmpty) {
      return Center(child: Text('No hay cargas realizadas.'));
    }

    List<Widget> items = [];
    for (int i = 0; i < cargas.length; i++) {
      final carga = cargas[i];
      final litros = double.parse(carga.monto) / carga.precio;

      // Agregar carga actual
      items.add(
        ListTile(
          leading: const Icon(Icons.local_gas_station),
          title: Text(
              'KM: ${carga.kmS} - Monto: \$${carga.monto} - Precio: \$${carga.precio} - Litros: ${litros.toStringAsFixed(2)}'),
          subtitle: Text('Fecha: ${dateFormat.format(carga.fecha)}'), // 👈 Fecha formateada
          trailing: _buildDeleteButton(context, carga),
        ),
      );

      // Si hay una carga POSTERIOR (no es la última), calcular rendimiento
      if (i + 1 < cargas.length) {
        final cargaPosterior = cargas[i + 1];
        final litrosPosteriores = double.parse(cargaPosterior.monto) / cargaPosterior.precio;
        final kmsActual = int.tryParse(carga.kmS) ?? 0;
        final kmsPosterior = int.tryParse(cargaPosterior.kmS) ?? 0;
        final fechaActual = DateUtils.dateOnly(carga.fecha);
        final fechaPosterior = DateUtils.dateOnly(cargaPosterior.fecha);
        final dias = fechaActual.difference(fechaPosterior).inDays;
        final kmsRecorridos = kmsActual - kmsPosterior;

        // 👇 Diferenciar primer mensaje
        final mensaje = i == 0
          ? 'Tu última carga de ${litrosPosteriores.toStringAsFixed(2)} litros del día ${dateFormat.format(cargaPosterior.fecha)} '
            'te rindió $dias días y $kmsRecorridos km.'
          : '→ Los ${litrosPosteriores.toStringAsFixed(2)} litros cargados el ${dateFormat.format(cargaPosterior.fecha)} '
            'te rindieron $dias días y $kmsRecorridos km.';

        items.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              mensaje,
              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.green[700]),
            ),
          ),
        );
      }
    }

    return ListView(
      children: items,
    );
  }

  Widget _buildDeleteButton(BuildContext context, carga) {
    return IconButton(
      icon: const Icon(Icons.delete, color: Colors.red),
      onPressed: () async {
        final confirmacion = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirmar eliminación'),
            content: const Text('¿Desea eliminar la carga?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Sí'),
              ),
            ],
          ),
        );

        if (confirmacion == true) {
          context.read<MyAppState>().eliminarCarga(carga);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Carga eliminada')),
          );
        }
      },
    );
  }
}
