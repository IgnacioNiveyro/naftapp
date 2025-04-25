import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:naftapp/providers/my_app_state.dart';  // Asegúrate de importar MyAppState si es necesario

class CargasRealizadasPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var cargas = context.watch<MyAppState>().cargas;

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
          subtitle: Text('Fecha: ${carga.fecha.toLocal().toString().split(' ')[0]}'),
          trailing: _buildDeleteButton(context, carga),
        ),
      );

      // Si hay una carga posterior (no es la última), mostrar el mensaje
      if (i + 1 < cargas.length) {
        final cargaSiguiente = cargas[i + 1];
        final litrosActuales = double.parse(carga.monto) / carga.precio;
        final kmsActual = int.tryParse(carga.kmS) ?? 0;
        final kmsSiguiente = int.tryParse(cargaSiguiente.kmS) ?? 0;
        final dias = cargaSiguiente.fecha.difference(carga.fecha).inDays;

        // Agregar el mensaje entre las cargas
        items.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              '→ Los ${litrosActuales.toStringAsFixed(2)} litros cargados el ${carga.fecha.toLocal().toString().split(' ')[0]} '
              'te rindieron $dias días y ${kmsSiguiente - kmsActual} km.',
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
