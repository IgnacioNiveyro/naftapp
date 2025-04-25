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

    return ListView.builder(
      itemCount: cargas.length,
      itemBuilder: (context, index) {
        final carga = cargas[index];
        return ListTile(
          leading: const Icon(Icons.local_gas_station),
          title: Text('KM: ${carga.kmS} - Monto: \$${carga.monto} - Precio: \$${carga.precio} - Litros: ${(double.parse(carga.monto) / carga.precio).toStringAsFixed(2)}'),
          subtitle:
              Text('Fecha: ${carga.fecha.toLocal().toString().split(' ')[0]}'),
          trailing: IconButton(
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
          ),
        );
      },
    );
  }
}
